import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sanku_pro/entities/clientes/services/clientes_firebase_service.dart';
import 'package:sanku_pro/entities/empleados/services/empleados_firebase_service.dart';
import 'package:sanku_pro/entities/paquetes/services/paquetes_firebase_service.dart';
import 'package:sanku_pro/entities/medios_pago/services/medios_pago_firebase_service.dart';
import 'package:sanku_pro/entities/pagos/services/pagos_firebase_service.dart';
import 'package:sanku_pro/entities/sesiones/services/sesiones_firebase_service.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

/// Obtener lista de inscripciones
Future<List> getInscripciones() async {
  List inscripciones = [];
  QuerySnapshot query = await db.collection('inscripciones').get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    inscripciones.add({"id": doc.id, ...data});
  }

  return inscripciones;
}

/// Obtener inscripción completa con todos los detalles relacionados
Future<Map<String, dynamic>?> getInscripcionCompleta(String id) async {
  final doc = await db.collection('inscripciones').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  // Fetch de datos relacionados en paralelo para mejor performance
  final results = await Future.wait([
    getClienteById(data['clienteId']),
    getEmpleadoById(data['empleadoId']),
    getPaqueteById(data['paqueteId']),
    getMedioPagoById(data['medioPagoId']),
  ]);

  // Obtener pagos asociados a esta inscripción
  final pagos = await getPagosByInscripcion(id);

  return {
    "id": doc.id,
    ...data,
    "cliente": results[0],
    "empleado": results[1],
    "paquete": results[2],
    "medioPago": results[3],
    "pagos": pagos,
  };
}

/// Obtener inscripción por ID (solo datos básicos)
Future<Map<String, dynamic>?> getInscripcionById(String id) async {
  DocumentSnapshot doc = await db.collection('inscripciones').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {"id": doc.id, ...data};
}

/// Agregar inscripción y crear sesiones automáticamente
Future<String> addInscripcion(
  Map<String, dynamic> inscripcion, {
  bool generarQR = true,
  String? logoUrl,
}) async {
  try {
    // 1. Obtener datos del paquete para saber cuántas sesiones crear
    final paquete = await getPaqueteById(inscripcion["paqueteId"]);

    if (paquete == null) {
      throw Exception('Paquete no encontrado');
    }

    final numeroSesiones = paquete["numero_sesiones"] ?? 0;
    final duracionSesion = paquete["duracion_sesion"] ?? 60; // en minutos

    // 2. Crear la inscripción
    DocumentReference inscripcionRef = await db.collection('inscripciones').add(
      {
        "clienteId": inscripcion["clienteId"],
        "empleadoId": inscripcion["empleadoId"],
        "paqueteId": inscripcion["paqueteId"],
        "fechaInscripcion":
            inscripcion["fechaInscripcion"] ?? FieldValue.serverTimestamp(),
        "medioPagoId": inscripcion["medioPagoId"],
        "montoCancelado": inscripcion["montoCancelado"] ?? 0.0,
        "estado": "activa", // activa, completada, cancelada
        "creadoEn": FieldValue.serverTimestamp(),
      },
    );

    String inscripcionId = inscripcionRef.id;

    // 3. Crear sesiones automáticamente
    if (numeroSesiones > 0) {
      await _crearSesionesAutomaticas(
        inscripcionId: inscripcionId,
        clienteId: inscripcion["clienteId"],
        empleadoId: inscripcion["empleadoId"],
        paqueteId: inscripcion["paqueteId"],
        numeroSesiones: numeroSesiones,
        duracionMinutos: duracionSesion,
      );
    }

    // 4. Crear el pago automáticamente si hay monto cancelado
    final montoCancelado = inscripcion["montoCancelado"] ?? 0.0;

    if (montoCancelado > 0) {
      final datosPago = {
        "inscripcion_id": inscripcionId,
        "metodo_pago_id": inscripcion["medioPagoId"],
        "monto": montoCancelado,
        "fecha_pago":
            inscripcion["fechaInscripcion"] ?? FieldValue.serverTimestamp(),
        "estado": "completado",
      };

      await addPagoConQR(
        pago: datosPago,
        generarQR: generarQR,
        logoUrl: logoUrl,
        verificarInscripcion: false,
      );
    }

    return inscripcionId;
  } catch (e) {
    debugPrint('Error al agregar inscripción: $e');
    rethrow;
  }
}

/// Crear sesiones automáticamente para una inscripción
Future<void> _crearSesionesAutomaticas({
  required String inscripcionId,
  required String clienteId,
  required String empleadoId,
  required String paqueteId,
  required int numeroSesiones,
  required int duracionMinutos,
}) async {
  try {
    // Crear sesiones en estado "pendiente" sin fecha/hora asignada
    for (int i = 1; i <= numeroSesiones; i++) {
      await db.collection('sesiones').add({
        "inscripcionId": inscripcionId,
        "clienteId": clienteId,
        "empleadoId": empleadoId,
        "paqueteId": paqueteId,
        "numeroSesion": i,
        "duracionMinutos": duracionMinutos,
        "estado": "pendiente", // pendiente, programada, completada, cancelada
        "fecha": null, // Se asignará cuando se programe
        "hora": null, // Se asignará cuando se programe
        "notas": "",
        "creadoEn": FieldValue.serverTimestamp(),
      });
    }

    debugPrint(
      '✅ $numeroSesiones sesiones creadas para inscripción $inscripcionId',
    );
  } catch (e) {
    debugPrint('Error al crear sesiones automáticas: $e');
    rethrow;
  }
}

/// Actualizar inscripción (sin modificar pagos)
Future<void> updateInscripcion(
  String id,
  Map<String, dynamic> inscripcion,
) async {
  await db.collection('inscripciones').doc(id).update({
    "clienteId": inscripcion["clienteId"],
    "empleadoId": inscripcion["empleadoId"],
    "paqueteId": inscripcion["paqueteId"],
    "fechaInicio": inscripcion["fechaInicio"],
    "fechaFin": inscripcion["fechaFin"],
    "medioPagoId": inscripcion["medioPagoId"],
    "montoCancelado": inscripcion["montoCancelado"],
  });
}

/// Actualizar monto cancelado de inscripción y crear nuevo pago si es necesario
Future<void> agregarPagoAInscripcion(
  String inscripcionId,
  double montoPago, {
  String? metodoPagoId,
  bool generarQR = true,
  String? logoUrl,
}) async {
  try {
    // Obtener la inscripción actual
    final inscripcion = await getInscripcionById(inscripcionId);

    if (inscripcion == null) {
      throw Exception('Inscripción no encontrada');
    }

    // Calcular el nuevo monto cancelado
    final montoActual = inscripcion["montoCancelado"] ?? 0.0;
    final nuevoMontoCancelado = montoActual + montoPago;

    // Preparar datos del nuevo pago
    final datosPago = {
      "inscripcion_id": inscripcionId,
      "metodo_pago_id": metodoPagoId ?? inscripcion["medioPagoId"],
      "monto": montoPago,
      "fecha_pago": FieldValue.serverTimestamp(),
      "estado": "completado",
    };

    // Crear el nuevo pago con QR
    await addPagoConQR(pago: datosPago, generarQR: generarQR, logoUrl: logoUrl);

    // Actualizar el monto cancelado en la inscripción
    await db.collection('inscripciones').doc(inscripcionId).update({
      "montoCancelado": nuevoMontoCancelado,
    });
  } catch (e) {
    debugPrint('Error al agregar pago a inscripción: $e');
    rethrow;
  }
}

/// Obtener resumen financiero de una inscripción
Future<Map<String, dynamic>> getResumenFinanciero(String inscripcionId) async {
  try {
    final inscripcion = await getInscripcionCompleta(inscripcionId);

    if (inscripcion == null) {
      throw Exception('Inscripción no encontrada');
    }

    // Obtener el precio del paquete
    final paquete = inscripcion["paquete"] as Map<String, dynamic>?;
    final precioPaquete = paquete?["precio"] ?? 0.0;

    // Obtener total pagado (suma de todos los pagos completados)
    final totalPagado = await getTotalPagadoByInscripcion(inscripcionId);

    // Calcular saldo pendiente
    final saldoPendiente = precioPaquete - totalPagado;

    // Obtener lista de pagos
    final pagos = inscripcion["pagos"] ?? [];

    return {
      "inscripcion_id": inscripcionId,
      "precio_paquete": precioPaquete,
      "total_pagado": totalPagado,
      "saldo_pendiente": saldoPendiente,
      "porcentaje_pagado": precioPaquete > 0
          ? (totalPagado / precioPaquete * 100)
          : 0,
      "esta_pagado_completo": saldoPendiente <= 0,
      "cantidad_pagos": pagos.length,
      "pagos": pagos,
    };
  } catch (e) {
    debugPrint('Error al obtener resumen financiero: $e');
    rethrow;
  }
}

/// Eliminar inscripción, sus pagos y sesiones asociadas
Future<void> deleteInscripcion(String id) async {
  try {
    // 1. Obtener y eliminar todos los pagos asociados
    final pagos = await getPagosByInscripcion(id);
    for (var pago in pagos) {
      await deletePago(pago["id"]);
    }

    // 2. Obtener y eliminar todas las sesiones asociadas
    final sesiones = await getSesionesByInscripcion(id);
    for (var sesion in sesiones) {
      await deleteSesion(sesion["id"]);
    }

    // 3. Eliminar la inscripción
    await db.collection('inscripciones').doc(id).delete();
    
    debugPrint('✅ Inscripción $id eliminada con ${pagos.length} pagos y ${sesiones.length} sesiones');
  } catch (e) {
    debugPrint('Error al eliminar inscripción: $e');
    rethrow;
  }
}

/// Verificar si una inscripción está pagada completamente
Future<bool> estaInscripcionPagada(String inscripcionId) async {
  final resumen = await getResumenFinanciero(inscripcionId);
  return resumen["esta_pagado_completo"] as bool;
}

/// Obtener inscripciones con pagos pendientes
Future<List<Map<String, dynamic>>> getInscripcionesConPendientes() async {
  final inscripciones = await getInscripciones();
  List<Map<String, dynamic>> conPendientes = [];

  for (var inscripcion in inscripciones) {
    final resumen = await getResumenFinanciero(inscripcion["id"]);

    if (!(resumen["esta_pagado_completo"] as bool)) {
      conPendientes.add({...inscripcion, "resumen_financiero": resumen});
    }
  }

  return conPendientes;
}
