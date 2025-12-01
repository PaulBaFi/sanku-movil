import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

FirebaseFirestore db = FirebaseFirestore.instance;

// Obtener lista de pagos
Future<List<Map<String, dynamic>>> getPagos() async {
  List<Map<String, dynamic>> pagos = [];
  CollectionReference collectionReferencePagos = db.collection('pagos');

  QuerySnapshot queryPagos = await collectionReferencePagos.get();

  for (var document in queryPagos.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Obtener datos de la inscripción relacionada si existe
    Map<String, dynamic>? inscripcionData;
    if (data["inscripcion_id"] != null) {
      DocumentSnapshot inscripcionDoc = await db
          .collection('inscripcion')
          .doc(data["inscripcion_id"])
          .get();

      if (inscripcionDoc.exists) {
        inscripcionData = inscripcionDoc.data() as Map<String, dynamic>;
        inscripcionData["id"] = inscripcionDoc.id;
      }
    }

    // Obtener datos del método de pago si existe
    Map<String, dynamic>? metodoPagoData;
    if (data["metodo_pago_id"] != null) {
      DocumentSnapshot metodoPagoDoc = await db
          .collection('metodos_pago')
          .doc(data["metodo_pago_id"])
          .get();

      if (metodoPagoDoc.exists) {
        metodoPagoData = metodoPagoDoc.data() as Map<String, dynamic>;
        metodoPagoData["id"] = metodoPagoDoc.id;
      }
    }

    final pago = <String, dynamic>{
      "id": document.id,
      "inscripcion_id": data["inscripcion_id"],
      "metodo_pago_id": data["metodo_pago_id"],
      "monto": data["monto"],
      "fecha_pago": data["fecha_pago"],
      "estado": data["estado"],
      "qr_code_url": data["qr_code_url"], // URL del QR generado
      "creadoEn": data["creadoEn"],
      "inscripcion": inscripcionData,
      "metodo_pago": metodoPagoData,
    };
    pagos.add(pago);
  }

  return pagos;
}

// Obtener un pago por ID
Future<Map<String, dynamic>?> getPagoById(String id) async {
  DocumentSnapshot doc = await db.collection('pagos').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  // Obtener datos de la inscripción relacionada
  Map<String, dynamic>? inscripcionData;
  if (data["inscripcion_id"] != null) {
    DocumentSnapshot inscripcionDoc = await db
        .collection('inscripcion')
        .doc(data["inscripcion_id"])
        .get();

    if (inscripcionDoc.exists) {
      inscripcionData = inscripcionDoc.data() as Map<String, dynamic>;
      inscripcionData["id"] = inscripcionDoc.id;
    }
  }

  // Obtener datos del método de pago
  Map<String, dynamic>? metodoPagoData;
  if (data["metodo_pago_id"] != null) {
    DocumentSnapshot metodoPagoDoc = await db
        .collection('metodos_pago')
        .doc(data["metodo_pago_id"])
        .get();

    if (metodoPagoDoc.exists) {
      metodoPagoData = metodoPagoDoc.data() as Map<String, dynamic>;
      metodoPagoData["id"] = metodoPagoDoc.id;
    }
  }

  return {
    "id": doc.id,
    "inscripcion_id": data["inscripcion_id"],
    "metodo_pago_id": data["metodo_pago_id"],
    "monto": data["monto"],
    "fecha_pago": data["fecha_pago"],
    "estado": data["estado"],
    "qr_code_url": data["qr_code_url"],
    "creadoEn": data["creadoEn"],
    "inscripcion": inscripcionData,
    "metodo_pago": metodoPagoData,
  };
}

// Obtener pagos por inscripción
Future<List<Map<String, dynamic>>> getPagosByInscripcion(
  String inscripcionId,
) async {
  List<Map<String, dynamic>> pagos = [];

  QuerySnapshot queryPagos = await db
      .collection('pagos')
      .where('inscripcion_id', isEqualTo: inscripcionId)
      .orderBy('fecha_pago', descending: true)
      .get();

  for (var document in queryPagos.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Obtener datos del método de pago
    Map<String, dynamic>? metodoPagoData;
    if (data["metodo_pago_id"] != null) {
      DocumentSnapshot metodoPagoDoc = await db
          .collection('metodos_pago')
          .doc(data["metodo_pago_id"])
          .get();

      if (metodoPagoDoc.exists) {
        metodoPagoData = metodoPagoDoc.data() as Map<String, dynamic>;
        metodoPagoData["id"] = metodoPagoDoc.id;
      }
    }

    final pago = <String, dynamic>{
      "id": document.id,
      "inscripcion_id": data["inscripcion_id"],
      "metodo_pago_id": data["metodo_pago_id"],
      "monto": data["monto"],
      "fecha_pago": data["fecha_pago"],
      "estado": data["estado"],
      "qr_code_url": data["qr_code_url"],
      "creadoEn": data["creadoEn"],
      "metodo_pago": metodoPagoData,
    };
    pagos.add(pago);
  }

  return pagos;
}

// ==================== GENERACIÓN DE QR CODE ====================

/// Genera un código QR usando la API gratuita de GoQR
/// Retorna la URL de la imagen del QR generado
Future<String> generarQRCode(
  String pagoId,
  Map<String, dynamic> datosPago,
) async {
  try { 
    // Crear la data que irá en el QR (formato JSON)
    final qrData = {
      "tipo": "comprobante_pago",
      "pago_id": pagoId,
      "inscripcion_id": datosPago["inscripcion_id"],
      "monto": datosPago["monto"],
      "fecha": datosPago["fecha_pago"]?.toString() ?? "",
      "metodo_pago_id": datosPago["metodo_pago_id"],
      "estado": datosPago["estado"],
    };

    // Convertir a JSON string
    final qrDataString = jsonEncode(qrData);

    // URL encode para la API
    final encodedData = Uri.encodeComponent(qrDataString);

    // API GoQR (gratuita, sin registro)
    final qrUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=$encodedData';

    return qrUrl;
  } catch (e) {
    debugPrint('Error al generar QR: $e');
    throw Exception('No se pudo generar el código QR');
  }
}

/// Genera un código QR personalizado usando QuickChart (más opciones de diseño)
Future<String> generarQRCodePersonalizado({
  required String pagoId,
  required Map<String, dynamic> datosPago,
  String? logoUrl,
  String centerColor = '000000',
  String outerColor = '000000',
}) async {
  try {
    // Crear la data del QR
    final qrData = {
      "tipo": "comprobante_pago",
      "pago_id": pagoId,
      "inscripcion_id": datosPago["inscripcion_id"],
      "monto": datosPago["monto"],
      "fecha": datosPago["fecha_pago"]?.toString() ?? "",
      "metodo_pago_id": datosPago["metodo_pago_id"],
      "estado": datosPago["estado"],
    };

    final qrDataString = jsonEncode(qrData);
    final encodedData = Uri.encodeComponent(qrDataString);

    // QuickChart permite personalización
    String qrUrl = 'https://quickchart.io/qr?text=$encodedData&size=300';

    // Agregar colores personalizados
    qrUrl += '&dark=$centerColor&light=ffffff';

    // Agregar logo si existe (opcional)
    if (logoUrl != null && logoUrl.isNotEmpty) {
      final encodedLogo = Uri.encodeComponent(logoUrl);
      qrUrl += '&centerImageUrl=$encodedLogo&centerImageSizeRatio=0.2';
    }

    return qrUrl;
  } catch (e) {
    debugPrint('Error al generar QR personalizado: $e');
    throw Exception('No se pudo generar el código QR personalizado');
  }
}

/// Descargar el QR como bytes para almacenarlo en Firebase Storage
Future<Uint8List> descargarQRCode(String qrUrl) async {
  try {
    final response = await http.get(Uri.parse(qrUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al descargar QR: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error al descargar QR: $e');
    throw Exception('No se pudo descargar el código QR');
  }
}

// ==================== AGREGAR PAGO CON QR ====================

/// Agregar un pago y generar automáticamente su código QR
Future<String> addPagoConQR({
  required Map<String, dynamic> pago,
  bool generarQR = true,
  String? logoUrl,
  bool verificarInscripcion =
      true, // Nueva opción para controlar la verificación
}) async {
  try {
    // Verificar que la inscripción existe (solo si se solicita)
    if (verificarInscripcion && pago["inscripcion_id"] != null) {
      DocumentSnapshot inscripcionDoc = await db
          .collection('inscripciones')
          .doc(pago["inscripcion_id"])
          .get();

      if (!inscripcionDoc.exists) {
        throw Exception("La inscripción no existe");
      }
    }

    // Verificar que el método de pago existe
    if (pago["metodo_pago_id"] != null) {
      DocumentSnapshot metodoPagoDoc = await db
          .collection('medios_pago')
          .doc(pago["metodo_pago_id"])
          .get();

      if (!metodoPagoDoc.exists) {
        throw Exception("El método de pago no existe");
      }
    }

    // Crear el documento del pago primero (sin QR)
    DocumentReference docRef = await db.collection('pagos').add({
      "inscripcion_id": pago["inscripcion_id"],
      "metodo_pago_id": pago["metodo_pago_id"],
      "monto": pago["monto"],
      "fecha_pago": pago["fecha_pago"] ?? FieldValue.serverTimestamp(),
      "estado": pago["estado"] ?? "completado",
      "qr_code_url": null, // Se actualizará después
      "creadoEn": FieldValue.serverTimestamp(),
    });

    String pagoId = docRef.id;

    // Generar el código QR si está habilitado
    if (generarQR) {
      String qrUrl;

      if (logoUrl != null && logoUrl.isNotEmpty) {
        // Generar QR personalizado con logo
        qrUrl = await generarQRCodePersonalizado(
          pagoId: pagoId,
          datosPago: pago,
          logoUrl: logoUrl,
        );
      } else {
        // Generar QR simple
        qrUrl = await generarQRCode(pagoId, pago);
      }

      // Actualizar el documento con la URL del QR
      await docRef.update({"qr_code_url": qrUrl});
    }

    return pagoId;
  } catch (e) {
    debugPrint('Error al agregar pago con QR: $e');
    rethrow;
  }
}

// ==================== ACTUALIZAR PAGO ====================

Future<void> updatePago(String id, Map<String, dynamic> pago) async {
  Map<String, dynamic> updateData = {};

  if (pago.containsKey("monto")) updateData["monto"] = pago["monto"];
  if (pago.containsKey("fecha_pago")) {
    updateData["fecha_pago"] = pago["fecha_pago"];
  }
  if (pago.containsKey("metodo_pago_id")) {
    updateData["metodo_pago_id"] = pago["metodo_pago_id"];
  }
  if (pago.containsKey("estado")) updateData["estado"] = pago["estado"];

  // Verificar que el método de pago existe si se está actualizando
  if (pago.containsKey("metodo_pago_id") && pago["metodo_pago_id"] != null) {
    DocumentSnapshot metodoPagoDoc = await db
        .collection('metodos_pago')
        .doc(pago["metodo_pago_id"])
        .get();

    if (!metodoPagoDoc.exists) {
      throw Exception("El método de pago no existe");
    }
  }

  if (updateData.isNotEmpty) {
    await db.collection('pagos').doc(id).update(updateData);
  }
}

/// Regenerar el código QR de un pago existente
Future<void> regenerarQRPago(String pagoId, {String? logoUrl}) async {
  try {
    // Obtener los datos del pago
    final pagoData = await getPagoById(pagoId);

    if (pagoData == null) {
      throw Exception('Pago no encontrado');
    }

    // Generar nuevo QR
    String qrUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      qrUrl = await generarQRCodePersonalizado(
        pagoId: pagoId,
        datosPago: pagoData,
        logoUrl: logoUrl,
      );
    } else {
      qrUrl = await generarQRCode(pagoId, pagoData);
    }

    // Actualizar en Firestore
    await db.collection('pagos').doc(pagoId).update({"qr_code_url": qrUrl});
  } catch (e) {
    debugPrint('Error al regenerar QR: $e');
    rethrow;
  }
}

// ==================== ELIMINAR PAGO ====================

Future<void> deletePago(String id) async {
  await db.collection('pagos').doc(id).delete();
}

// ==================== FUNCIONES AUXILIARES ====================

/// Calcular total pagado por inscripción
Future<double> getTotalPagadoByInscripcion(String inscripcionId) async {
  QuerySnapshot queryPagos = await db
      .collection('pagos')
      .where('inscripcion_id', isEqualTo: inscripcionId)
      .where('estado', isEqualTo: 'completado')
      .get();

  double total = 0.0;
  for (var doc in queryPagos.docs) {
    final data = doc.data() as Map<String, dynamic>;
    total += (data["monto"] ?? 0.0);
  }

  return total;
}

/// Verificar un pago escaneando el QR (validación)
Future<Map<String, dynamic>?> verificarPagoPorQR(String qrData) async {
  try {
    // Decodificar los datos del QR
    final data = jsonDecode(qrData);

    if (data["tipo"] != "comprobante_pago") {
      throw Exception("QR inválido: no es un comprobante de pago");
    }

    final pagoId = data["pago_id"];

    // Buscar el pago en la base de datos
    final pagoReal = await getPagoById(pagoId);

    if (pagoReal == null) {
      throw Exception("Pago no encontrado");
    }

    // Verificar que los datos coincidan
    bool esValido =
        pagoReal["monto"] == data["monto"] &&
        pagoReal["estado"] == data["estado"];

    return {
      "valido": esValido,
      "pago": pagoReal,
      "mensaje": esValido
          ? "Pago verificado exitosamente"
          : "Los datos no coinciden",
    };
  } catch (e) {
    debugPrint('Error al verificar pago: $e');
    return {"valido": false, "mensaje": "Error al verificar: $e"};
  }
}

// ==================== OBTENER MÉTODOS DE PAGO ====================

/// Obtener todos los métodos de pago disponibles
Future<List<Map<String, dynamic>>> getMetodosPago() async {
  List<Map<String, dynamic>> metodosPago = [];

  QuerySnapshot queryMetodos = await db
      .collection('metodos_pago')
      .orderBy('nombre')
      .get();

  for (var doc in queryMetodos.docs) {
    final data = doc.data() as Map<String, dynamic>;
    metodosPago.add({"id": doc.id, ...data});
  }

  return metodosPago;
}
