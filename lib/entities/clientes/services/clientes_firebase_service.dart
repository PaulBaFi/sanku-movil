import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanku_pro/apis/avatar_placeholder.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Obtener lista de clientes desde Firestore
Future<List> getClientes() async {
  List clientes = [];
  CollectionReference collectionReferenceClientes = db.collection('clientes');

  QuerySnapshot queryClientes = await collectionReferenceClientes.get();

  for (var document in queryClientes.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final cliente = <String, dynamic>{
      "id": document.id,
      "nombres": data["nombres"],
      "apellidos": data["apellidos"],
      "dni": data["dni"],
      "direccion": data["direccion"],
      "email": data["email"],
      "contacto": data["contacto"],
      "contactoEmergencia": data["contactoEmergencia"],
      "estado": data["estado"],
      "avatarUrl": data["avatarUrl"], // avatar dinámico
    };

    clientes.add(cliente);
  }

  return clientes;
}

// Obtener cliente por ID
Future<Map<String, dynamic>?> getClienteById(String id) async {
  DocumentSnapshot doc = await db.collection('clientes').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "nombres": data["nombres"],
    "apellidos": data["apellidos"],
    "dni": data["dni"],
    "direccion": data["direccion"],
    "email": data["email"],
    "contacto": data["contacto"],
    "contactoEmergencia": data["contactoEmergencia"],
    "estado": data["estado"],
    "avatarUrl": data["avatarUrl"], // avatar dinámico
  };
}

// Agregar cliente con avatar dinámico
Future<void> addCliente(Map<String, dynamic> cliente) async {
  final avatarUrl = generarAvatarUrl(
    cliente["nombres"],
    cliente["apellidos"],
  );

  await db.collection('clientes').add({
    "nombres": cliente["nombres"],
    "apellidos": cliente["apellidos"],
    "dni": cliente["dni"],
    "direccion": cliente["direccion"],
    "email": cliente["email"],
    "contacto": cliente["contacto"],
    "contactoEmergencia": cliente["contactoEmergencia"],
    "estado": cliente["estado"],
    "avatarUrl": avatarUrl,
    "creadoEn": FieldValue.serverTimestamp(),
  });
}

// Actualizar cliente con nuevo avatar dinámico
Future<void> updateCliente(String id, Map<String, dynamic> cliente) async {
  // Obtener avatar actual
  final doc = await db.collection('clientes').doc(id).get();
  final data = doc.data() as Map<String, dynamic>;
  final avatarActual = data["avatarUrl"];

  // Extraer color
  final colorActual = extraerColorDesdeAvatar(avatarActual);

  // Generar avatar solo con nuevas iniciales, pero mismo color
  final nuevoAvatarUrl = generarAvatarUrl(
    cliente["nombres"],
    cliente["apellidos"],
    colorHex: colorActual,
  );

  await db.collection('clientes').doc(id).update({
    "nombres": cliente["nombres"],
    "apellidos": cliente["apellidos"],
    "dni": cliente["dni"],
    "direccion": cliente["direccion"],
    "email": cliente["email"],
    "contacto": cliente["contacto"],
    "contactoEmergencia": cliente["contactoEmergencia"],
    "estado": cliente["estado"],
    "avatarUrl": nuevoAvatarUrl,
  });
}

// Eliminar cliente
Future<void> deleteCliente(String id) async {
  await db.collection('clientes').doc(id).delete();
}