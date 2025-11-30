import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getTiposEmpleado() async {
  List tiposEmpleado = [];
  CollectionReference collectionReferenceTiposEmpleado = db.collection(
    'tipos_empleado',
  );

  QuerySnapshot queryTipoEmpleados = await collectionReferenceTiposEmpleado
      .get();
  for (var document in queryTipoEmpleados.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final tipoEmpleado = <String, dynamic>{
      "id": document.id,
      "tipo_empleado": data["tipo_empleado"],
      "creadoEn": data["creadoEn"],
    };
    tiposEmpleado.add(tipoEmpleado);
  }

  return tiposEmpleado;
}

Future<Map<String, dynamic>?> getTipoEmpleadoById(String id) async {
  DocumentSnapshot doc = await db.collection('tipos_empleado').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "tipo_empleado": data["tipo_empleado"],
    "creadoEn": data["creadoEn"],
  };
}

Future<void> addTipoEmpleado(Map<String, dynamic> tipoEmpleado) async {
  await db.collection('tipos_empleado').add({
    "tipo_empleado": tipoEmpleado["tipo_empleado"],
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

Future<void> updateTipoEmpleado(String id, Map<String, dynamic> tipo) async {
  final ref = db.collection('tipos_empleado').doc(id);

  // obtener valor anterior
  final oldData = await ref.get();
  if (!oldData.exists) return;

  final oldTipoEmpleado = oldData['tipo_empleado'];
  final newTipoEmpleado = tipo['tipo_empleado'];

  // 1. actualizar en su colección
  await ref.update({"tipo_empleado": newTipoEmpleado});

  // 2. actualizar en empleados
  final empleadosRef = db.collection('empleados');
  final snapshot = await empleadosRef
      .where("tipo_empleado", isEqualTo: oldTipoEmpleado)
      .get();

  // 3. actualizar todos los empleados encontrados
  for (var doc in snapshot.docs) {
    await doc.reference.update({"tipo_empleado": newTipoEmpleado});
  }
}

Future<void> deleteTipoEmpleado(String id) async {
  await db.collection('tipos_empleado').doc(id).delete();
}
