import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

/// Clasificacion de notificaciones
Future<List> getClasificacionesDeNotificaciones() async {
  List clasificacionesDeNotificaciones = [];
  CollectionReference collectionReferenceClasificacionesDeNotificaciones = db
      .collection('clasificaciones_notificaciones');

  QuerySnapshot queryClasificacionesDeNotificaciones =
      await collectionReferenceClasificacionesDeNotificaciones.get();

  for (var document in queryClasificacionesDeNotificaciones.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final clasificacionNotificacion = <String, dynamic>{
      "id": document.id,
      "clasificacion": data["clasificacion"],
      "mensaje": data["mensaje"],
      "envioAutomatico": data["envioAutomatico"],
    };

    clasificacionesDeNotificaciones.add(clasificacionNotificacion);
  }

  return clasificacionesDeNotificaciones;
}

Future<void> addClasificacionDeNotificacion(
  Map<String, dynamic> clasificacionDeNotificacion,
) async {
  await db.collection('clasificaciones_notificaciones').add({
    "clasificacion": clasificacionDeNotificacion["clasificacion"],
    "mensaje": clasificacionDeNotificacion["mensaje"],
    "envioAutomatico": clasificacionDeNotificacion["envioAutomatico"],
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> updateClasificacionDeNotificacion(
  String id,
  Map<String, dynamic> clasificacionDeNotificacion,
) async {
  await db.collection('clasificaciones_notificaciones').doc(id).update({
    "clasificacion": clasificacionDeNotificacion["clasificacion"],
    "mensaje": clasificacionDeNotificacion["mensaje"],
    "envioAutomatico": clasificacionDeNotificacion["envioAutomatico"],
    "actualizadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> deleteClasificacionDeNotificacion(String id) async {
  await db.collection('clasificaciones_notificaciones').doc(id).delete();
}

/// Medios de envío de notificaciones
Future<List> getMediosDeEnvio() async {
  List mediosDeEnvio = [];
  CollectionReference collectionReferenceMediosDeEnvio = db.collection(
    'medios_envio',
  );

  QuerySnapshot queryMediosDeEnvio = await collectionReferenceMediosDeEnvio
      .get();

  for (var document in queryMediosDeEnvio.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final medioEnvio = <String, dynamic>{
      "id": document.id,
      "medioEnvio": data["medioEnvio"],
      "baseUrl": data["baseUrl"],
      "creadoEn": data["creadoEn"],
    };

    mediosDeEnvio.add(medioEnvio);
  }

  return mediosDeEnvio;
}

Future<void> addMedioDeEnvio(Map<String, dynamic> medioDeEnvio) async {
  await db.collection('medios_envio').add({
    "medioEnvio": medioDeEnvio["medioEnvio"],
    "baseUrl": medioDeEnvio["baseUrl"],
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> updateMedioDeEnvio(
  String id,
  Map<String, dynamic> medioDeEnvio,
) async {
  await db.collection('medios_envio').doc(id).update({
    "medioEnvio": medioDeEnvio["medioEnvio"],
    "baseUrl": medioDeEnvio["baseUrl"],
    "actualizadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> deleteMedioDeEnvio(String id) async {
  await db.collection('medios_envio').doc(id).delete();
}
