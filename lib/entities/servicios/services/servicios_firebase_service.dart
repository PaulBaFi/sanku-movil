import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Obtener lista de servicios
Future<List> getServicios() async {
  List servicios = [];
  CollectionReference collectionReferenceServicios = db.collection('servicios');

  QuerySnapshot queryServicios = await collectionReferenceServicios.get();
  for (var document in queryServicios.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final servicio = <String, dynamic>{
      "id": document.id,
      "nombre_servicio": data["nombre_servicio"],
      "descripcion": data["descripcion"],
      "creadoEn": data["creadoEn"],
    };
    servicios.add(servicio);
  }

  return servicios;
}

// Obtener un servicio por ID
Future<Map<String, dynamic>?> getServicioById(String id) async {
  DocumentSnapshot doc = await db.collection('servicios').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "nombre_servicio": data["nombre_servicio"],
    "descripcion": data["descripcion"],
    "creadoEn": data["creadoEn"],
  };
}

// Agregar un servicio
Future<void> addServicio(Map<String, dynamic> servicio) async {
  await db.collection('servicios').add({
    "nombre_servicio": servicio["nombre_servicio"],
    "descripcion": servicio["descripcion"],
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

// Actualizar servicio
Future<void> updateServicio(String id, Map<String, dynamic> servicio) async {
  await db.collection('servicios').doc(id).update({
    "nombre_servicio": servicio["nombre_servicio"],
    "descripcion": servicio["descripcion"],
  });
}

// Eliminar servicio
Future<void> deleteServicio(String id) async {
  await db.collection('servicios').doc(id).delete();
}
