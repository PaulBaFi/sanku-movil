import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getMediosPago() async {
  List<Map<String, dynamic>> mediosPago = [];
  CollectionReference collectionReferenceMediosPago = db.collection(
    'medios_pago',
  );

  QuerySnapshot queryMediosPago = await collectionReferenceMediosPago.get();

  for (var document in queryMediosPago.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final medioPago = <String, dynamic>{
      "id": document.id,
      "imagen": data["imagen"],
      "nombre": data["nombre"],
      "creadoEn": data["creadoEn"],
    };

    mediosPago.add(medioPago);
  }

  return mediosPago;
}

Future<Map<String, dynamic>?> getMedioPagoById(String id) async {
  DocumentSnapshot doc = await db.collection('medios_pago').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "imagen": data["imagen"],
    "nombre": data["nombre"],
    "creadoEn": data["creadoEn"],
  };
}

Future<void> addMedioPago(Map<String, dynamic> medioPago) async {
  await db.collection('medios_pago').add({
    "imagen": medioPago["imagen"],
    "nombre": medioPago["nombre"],
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> updateMedioPago(String id, Map<String, dynamic> medioPago) async {
  await db.collection('medios_pago').doc(id).update({
    "imagen": medioPago["imagen"],
    "nombre": medioPago["nombre"],
  });
}

Future<void> deleteMedioPago(String id) async {
  await db.collection('medios_pago').doc(id).delete();
}
