import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getEspecialidades() async {
  List especialidades = [];

  CollectionReference collectionReferenceEspecialidades = db.collection(
    'especialidades',
  );

  QuerySnapshot queryEspecialidades = await collectionReferenceEspecialidades
      .get();

  for (var document in queryEspecialidades.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final especialidad = <String, dynamic>{
      "id": document.id,
      "especialidad": data["especialidad"],
      "creadoEn": data["creadoEn"],
    };
    especialidades.add(especialidad);
  }

  return especialidades;
}

Future<Map<String, dynamic>?> getEspecialidadesyById(String id) async {
  DocumentSnapshot doc = await db.collection('especialidades').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "especialidad": data["especialidad"],
    "creadoEn": data["creadoEn"],
  };
}

Future<void> addEspecialidad(Map<String, dynamic> especialidad) async {
  await db.collection('especialidades').add({
    "especialidad": especialidad["especialidad"],
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> updateEspecialidad(
  String id,
  Map<String, dynamic> especialidad,
) async {
  final ref = db.collection('especialidades').doc(id);

  // Obtener el valor anterior para comparar
  final oldData = await ref.get();
  if (!oldData.exists) return;

  final oldEspecialidad = oldData['especialidad'];
  final newEspecialidad = especialidad['especialidad'];

  // 1. Actualizar la especialidad en su colección
  await ref.update({"especialidad": newEspecialidad});

  // 2. Buscar empleados que tengan la especialidad antigua
  final empleadosRef = db.collection('empleados');
  final snapshot = await empleadosRef
      .where("especialidad", isEqualTo: oldEspecialidad)
      .get();

  // 3. Actualizar todos los empleados encontrados
  for (var doc in snapshot.docs) {
    await doc.reference.update({"especialidad": newEspecialidad});
  }
}

Future<void> deleteEspecialidad(String id) async {
  await db.collection('especialidades').doc(id).delete();
}
