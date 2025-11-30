import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getPaquetes() async {
  List paquetes = [];
  CollectionReference collectionReferencePaquetes = db.collection('paquetes');

  QuerySnapshot queryPaquetes = await collectionReferencePaquetes.get();

  for (var document in queryPaquetes.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final paquete = <String, dynamic>{
      "id": document.id,
      "nombre_paquete": data["nombre_paquete"],
      "numero_sesiones": data["numero_sesiones"],
      "precio": data["precio"],
      "clientes_activos": data["clientes_activos"],
      "creadoEn": data["creadoEn"],
    };

    paquetes.add(paquete);
  }

  return paquetes;
}

Future<Map<String, dynamic>?> getPaqueteById(String id) async {
  DocumentSnapshot doc = await db.collection('paquetes').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "nombre_paquete": data["nombre_paquete"],
    "numero_sesiones": data["numero_sesiones"],
    "precio": data["precio"],
    "clientes_activos": data["clientes_activos"],
    "creadoEn": data["creadoEn"],
  };
}

Future<void> addPaquete(Map<String, dynamic> paquete) async {
  await db.collection('paquetes').add({
    "nombre_paquete": paquete["nombre_paquete"],
    "numero_sesiones": paquete["numero_sesiones"],
    "precio": paquete["precio"],
    "clientes_activos": 0,
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> updatePaquete(String id, Map<String, dynamic> paquete) async {
  await db.collection('paquetes').doc(id).update({
    "nombre_paquete": paquete["nombre_paquete"],
    "numero_sesiones": paquete["numero_sesiones"],
    "precio": paquete["precio"],
    // clientes_activos NO se actualiza aquí a menos que lo necesites
  });
}

Future<void> deletePaquete(String id) async {
  await db.collection('paquetes').doc(id).delete();
}
