import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

/// Obtener todas las sesiones de un cliente específico (sin requerir índice)
Future<List<Map<String, dynamic>>> getSesionesByCliente(String clienteId) async {
  List<Map<String, dynamic>> sesiones = [];
  
  QuerySnapshot query = await db
      .collection('sesiones')
      .where('clienteId', isEqualTo: clienteId)
      .get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    sesiones.add({"id": doc.id, ...data});
  }

  // Ordenar manualmente en Dart (no requiere índice de Firestore)
  sesiones.sort((a, b) {
    // Primero ordenar por número de sesión
    final numA = a['numeroSesion'] ?? 0;
    final numB = b['numeroSesion'] ?? 0;
    
    final compNumero = numA.compareTo(numB);
    if (compNumero != 0) return compNumero;
    
    // Luego por fecha si existe
    final fechaA = a['fecha'];
    final fechaB = b['fecha'];
    
    if (fechaA == null && fechaB == null) return 0;
    if (fechaA == null) return 1;
    if (fechaB == null) return -1;
    
    if (fechaA is Timestamp && fechaB is Timestamp) {
      return fechaB.compareTo(fechaA); // Más recientes primero
    }
    
    return 0;
  });

  return sesiones;
}

/// Obtener sesiones por inscripción (sin requerir índice)
Future<List<Map<String, dynamic>>> getSesionesByInscripcion(
  String inscripcionId,
) async {
  List<Map<String, dynamic>> sesiones = [];
  
  QuerySnapshot query = await db
      .collection('sesiones')
      .where('inscripcionId', isEqualTo: inscripcionId)
      .get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    sesiones.add({"id": doc.id, ...data});
  }

  // Ordenar por número de sesión
  sesiones.sort((a, b) {
    final numA = a['numeroSesion'] ?? 0;
    final numB = b['numeroSesion'] ?? 0;
    return numA.compareTo(numB);
  });

  return sesiones;
}

/// Obtener sesión por ID
Future<Map<String, dynamic>?> getSesionById(String id) async {
  DocumentSnapshot doc = await db.collection('sesiones').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;
  return {"id": doc.id, ...data};
}

/// Obtener resumen de sesiones del cliente
Future<Map<String, dynamic>> getResumenSesionesCliente(String clienteId) async {
  final sesiones = await getSesionesByCliente(clienteId);
  
  int totalSesiones = sesiones.length;
  int sesionesCompletadas = sesiones.where((s) => s['estado'] == 'completada').length;
  int sesionesPendientes = sesiones.where((s) => s['estado'] == 'pendiente').length;
  int sesionesProgr = sesiones.where((s) => s['estado'] == 'programada').length;
  int sesionesCanceladas = sesiones.where((s) => s['estado'] == 'cancelada').length;

  return {
    'totalSesiones': totalSesiones,
    'completadas': sesionesCompletadas,
    'pendientes': sesionesPendientes,
    'programadas': sesionesProgr,
    'canceladas': sesionesCanceladas,
    'sesiones': sesiones,
  };
}

/// Programar una sesión (asignar fecha y hora)
Future<void> programarSesion(
  String sesionId, {
  required String fecha,
  required String hora,
}) async {
  try {
    await db.collection('sesiones').doc(sesionId).update({
      'fecha': fecha,
      'hora': hora,
      'estado': 'programada',
    });
    debugPrint('✅ Sesión $sesionId programada para $fecha a las $hora');
  } catch (e) {
    debugPrint('Error al programar sesión: $e');
    rethrow;
  }
}

/// Marcar sesión como completada
Future<void> completarSesion(
  String sesionId, {
  String? notas,
}) async {
  try {
    final updates = {
      'estado': 'completada',
    };
    
    if (notas != null && notas.isNotEmpty) {
      updates['notas'] = notas;
    }
    
    await db.collection('sesiones').doc(sesionId).update(updates);
    debugPrint('✅ Sesión $sesionId marcada como completada');
  } catch (e) {
    debugPrint('Error al completar sesión: $e');
    rethrow;
  }
}

/// Cancelar una sesión
Future<void> cancelarSesion(
  String sesionId, {
  String? motivo,
}) async {
  try {
    final updates = {
      'estado': 'cancelada',
    };
    
    if (motivo != null && motivo.isNotEmpty) {
      updates['notas'] = motivo;
    }
    
    await db.collection('sesiones').doc(sesionId).update(updates);
    debugPrint('✅ Sesión $sesionId cancelada');
  } catch (e) {
    debugPrint('Error al cancelar sesión: $e');
    rethrow;
  }
}

/// Actualizar notas de una sesión
Future<void> actualizarNotasSesion(
  String sesionId,
  String notas,
) async {
  try {
    await db.collection('sesiones').doc(sesionId).update({
      'notas': notas,
    });
    debugPrint('✅ Notas actualizadas para sesión $sesionId');
  } catch (e) {
    debugPrint('Error al actualizar notas: $e');
    rethrow;
  }
}

/// Eliminar una sesión
Future<void> deleteSesion(String id) async {
  try {
    await db.collection('sesiones').doc(id).delete();
    debugPrint('✅ Sesión $id eliminada');
  } catch (e) {
    debugPrint('Error al eliminar sesión: $e');
    rethrow;
  }
}

/// Obtener próximas sesiones programadas (global)
Future<List<Map<String, dynamic>>> getProximasSesiones({int limite = 10}) async {
  List<Map<String, dynamic>> sesiones = [];
  
  QuerySnapshot query = await db
      .collection('sesiones')
      .where('estado', isEqualTo: 'programada')
      .get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    sesiones.add({"id": doc.id, ...data});
  }

  // Ordenar por fecha
  sesiones.sort((a, b) {
    final fechaA = a['fecha'];
    final fechaB = b['fecha'];
    
    if (fechaA == null && fechaB == null) return 0;
    if (fechaA == null) return 1;
    if (fechaB == null) return -1;
    
    if (fechaA is String && fechaB is String) {
      return fechaA.compareTo(fechaB);
    }
    
    return 0;
  });

  return sesiones.take(limite).toList();
}

/// Obtener sesiones por estado
Future<List<Map<String, dynamic>>> getSesionesByEstado(String estado) async {
  List<Map<String, dynamic>> sesiones = [];
  
  QuerySnapshot query = await db
      .collection('sesiones')
      .where('estado', isEqualTo: estado)
      .get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    sesiones.add({"id": doc.id, ...data});
  }

  return sesiones;
}

/// Verificar método de debug
Future<void> verificarSesionesCreadas(String inscripcionId) async {
  try {
    final sesiones = await db
        .collection('sesiones')
        .where('inscripcionId', isEqualTo: inscripcionId)
        .get();
    
    debugPrint('✅ Sesiones encontradas: ${sesiones.docs.length}');
    
    for (var doc in sesiones.docs) {
      final data = doc.data();
      debugPrint('Sesión ${data['numeroSesion']}: ${data['estado']}');
    }
  } catch (e) {
    debugPrint('❌ Error al verificar sesiones: $e');
  }
}

/// Obtener sesiones agrupadas por fecha
Future<Map<String, List<Map<String, dynamic>>>> getSesionesAgrupadasPorFecha() async {
  Map<String, List<Map<String, dynamic>>> sesionesPorFecha = {};
  
  // Obtener solo sesiones programadas o completadas
  QuerySnapshot query = await db
      .collection('sesiones')
      .where('estado', whereIn: ['programada', 'completada'])
      .get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final sesion = {"id": doc.id, ...data};
    
    final fechaRaw = sesion['fecha'];
    String? fecha;
    
    if (fechaRaw != null) {
      if (fechaRaw is Timestamp) {
        fecha = DateFormat('yyyy-MM-dd').format(fechaRaw.toDate());
      } else if (fechaRaw is String && fechaRaw.isNotEmpty) {
        fecha = fechaRaw;
      }
    }
    
    if (fecha != null && fecha.isNotEmpty) {
      if (!sesionesPorFecha.containsKey(fecha)) {
        sesionesPorFecha[fecha] = [];
      }
      sesionesPorFecha[fecha]!.add(sesion);
    }
  }

  // Ordenar sesiones dentro de cada fecha por hora
  sesionesPorFecha.forEach((fecha, sesiones) {
    sesiones.sort((a, b) {
      final horaA = a['hora']?.toString() ?? '';
      final horaB = b['hora']?.toString() ?? '';
      return horaA.compareTo(horaB);
    });
  });

  return sesionesPorFecha;
}

/// Obtener sesiones de un rango de fechas
Future<Map<String, List<Map<String, dynamic>>>> getSesionesPorRango({
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  Map<String, List<Map<String, dynamic>>> sesionesPorFecha = {};
  
  final fechaInicioStr = DateFormat('yyyy-MM-dd').format(fechaInicio);
  final fechaFinStr = DateFormat('yyyy-MM-dd').format(fechaFin);
  
  QuerySnapshot query = await db
      .collection('sesiones')
      .where('estado', whereIn: ['programada', 'completada', 'cancelada'])
      .get();

  for (var doc in query.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final sesion = {"id": doc.id, ...data};
    
    final fechaRaw = sesion['fecha'];
    String? fecha;
    
    if (fechaRaw != null) {
      if (fechaRaw is Timestamp) {
        fecha = DateFormat('yyyy-MM-dd').format(fechaRaw.toDate());
      } else if (fechaRaw is String && fechaRaw.isNotEmpty) {
        fecha = fechaRaw;
      }
    }
    
    if (fecha != null && fecha.isNotEmpty) {
      // Verificar si está en el rango
      if (fecha.compareTo(fechaInicioStr) >= 0 && 
          fecha.compareTo(fechaFinStr) <= 0) {
        if (!sesionesPorFecha.containsKey(fecha)) {
          sesionesPorFecha[fecha] = [];
        }
        sesionesPorFecha[fecha]!.add(sesion);
      }
    }
  }

  // Ordenar sesiones dentro de cada fecha por hora
  sesionesPorFecha.forEach((fecha, sesiones) {
    sesiones.sort((a, b) {
      final horaA = a['hora']?.toString() ?? '';
      final horaB = b['hora']?.toString() ?? '';
      return horaA.compareTo(horaB);
    });
  });

  return sesionesPorFecha;
}

Future<String> getNombreCliente(String clienteId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('clientes')
        .doc(clienteId)
        .get();

    if (!doc.exists) return "Sin nombre";

    final data = doc.data() as Map<String, dynamic>;
    return data['nombre'] ?? "Sin nombre";
  } catch (e) {
    return "Sin nombre";
  }
}

