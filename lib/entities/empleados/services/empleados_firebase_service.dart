import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanku_pro/presentation/utils/others/avatar_default.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getEmpleados() async {
  List empleados = [];
  CollectionReference collectionReferenceEmpleados = db.collection('empleados');

  QuerySnapshot queryEmpleados = await collectionReferenceEmpleados.get();
  for (var document in queryEmpleados.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final empleado = <String, dynamic>{
      "id": document.id,
      "nombres": data["nombres"],
      "apellidos": data["apellidos"],
      "email": data["email"],
      "tipo_empleado": data["tipo_empleado"],
      "especialidad": data["especialidad"],
      "avatarUrl": data["avatarUrl"] ?? defaultAvatarUrl,
      "dni": data["dni"],
      "nacimiento": data["nacimiento"],
      "phone": data["phone"],
      "direccion": data["direccion"],
      "creadoEn": data["creadoEn"],
    };
    empleados.add(empleado);
  }

  return empleados;
}

Future<List<Map<String, dynamic>>> getTiposEmpleadoDesdeEmpleado() async {
  List<Map<String, dynamic>> tipos = [];

  final ref = db.collection('tipos_empleado');
  final snapshot = await ref.get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    tipos.add({"id": doc.id, "tipo_empleado": data["tipo_empleado"]});
  }

  return tipos;
}

Future<List<Map<String, dynamic>>> getEspecialidadesDesdeEmpleado() async {
  List<Map<String, dynamic>> items = [];

  final ref = db.collection('especialidades');
  final snapshot = await ref.get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    items.add({"id": doc.id, "especialidad": data["especialidad"]});
  }

  return items;
}

Future<Map<String, dynamic>?> getEmpleadoById(String id) async {
  DocumentSnapshot doc = await db.collection('empleados').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "nombres": data["nombres"],
    "apellidos": data["apellidos"],
    "email": data["email"],
    "tipo_empleado": data["tipo_empleado"],
    "especialidad": data["especialidad"],
    "avatarUrl": data["avatarUrl"] ?? defaultAvatarUrl,
    "dni": data["dni"],
    "nacimiento": data["nacimiento"],
    "phone": data["phone"],
    "direccion": data["direccion"],
    "creadoEn": data["creadoEn"],
  };
}

Future<void> addEmpleado(String id, Map<String, dynamic> empleado) async {
  await db.collection('empleados').doc(id).set({
    "nombres": empleado["nombres"],
    "apellidos": empleado["apellidos"],
    "email": empleado["email"],
    "tipo_empleado": empleado["tipo_empleado"],
    "especialidad": empleado["especialidad"],
    "avatarUrl": empleado["avatarUrl"] ?? defaultAvatarUrl,
    "dni": empleado["dni"],
    "nacimiento": empleado["nacimiento"],
    "phone": empleado["phone"],
    "direccion": empleado["direccion"],
    "creadoEn": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> updateEmpleado(String id, Map<String, dynamic> empleado) async {
  await db.collection('empleados').doc(id).update({
    "nombres": empleado["nombres"],
    "apellidos": empleado["apellidos"],
    "email": empleado["email"],
    "tipo_empleado": empleado["tipo_empleado"],
    "especialidad": empleado["especialidad"],
    "avatarUrl": empleado["avatarUrl"] ?? defaultAvatarUrl,
    "dni": empleado["dni"],
    "nacimiento": empleado["nacimiento"],
    "phone": empleado["phone"],
    "direccion": empleado["direccion"],
  });
}

Future<void> deleteEmpleado(String id) async {
  await db.collection('empleados').doc(id).delete();
}
