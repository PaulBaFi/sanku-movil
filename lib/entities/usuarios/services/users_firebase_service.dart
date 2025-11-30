import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanku_pro/apis/avatar_placeholder.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Obtener lista de usuarios desde Firestore
Future<List> getUsuarios() async {
  List usuarios = [];
  CollectionReference collectionReferenceUsuarios = db.collection('usuarios');

  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.get();

  for (var document in queryUsuarios.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final usuario = <String, dynamic>{
      "id": document.id,
      "nombres": data["nombres"],
      "apellidos": data["apellidos"],
      "username": data["username"] ?? "${data["nombres"]} ${data["apellidos"]}",
      "email": data["email"],
      "clave": data["clave"],
      "role": data["role"],
      "avatarUrl": data["avatarUrl"], // avatar dinámico
      "dni": data["dni"],
      "nacimiento": data["nacimiento"],
      "phone": data["phone"],
      "direccion": data["direccion"],
      "creadoEn": data["creadoEn"],
    };

    usuarios.add(usuario);
  }

  return usuarios;
}

// LOGIN
Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  final query = await db
      .collection('usuarios')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (query.docs.isEmpty) return null; // Usuario no encontrado

  final data = query.docs.first.data();

  // Validar contraseña
  if (data['clave'] != password) return {}; // Contraseña incorrecta

  // Usuario válido
  return {"id": query.docs.first.id, ...data};
}

// Obtener usuario por ID
Future<Map<String, dynamic>?> getUsuarioById(String id) async {
  DocumentSnapshot doc = await db.collection('usuarios').doc(id).get();

  if (!doc.exists) return null;

  final data = doc.data() as Map<String, dynamic>;

  return {
    "id": doc.id,
    "nombres": data["nombres"],
    "apellidos": data["apellidos"],
    "username": data["username"] ?? "${data["nombres"]} ${data["apellidos"]}",
    "email": data["email"],
    "clave": data["clave"],
    "role": data["role"],
    "avatarUrl": data["avatarUrl"], // avatar dinámico
    "dni": data["dni"],
    "nacimiento": data["nacimiento"],
    "phone": data["phone"],
    "direccion": data["direccion"],
    "creadoEn": data["creadoEn"],
  };
}

// Agregar/actualizar información de cuenta
Future<void> addUsuarioCuenta(String id, Map<String, dynamic> cuenta) async {
  await db.collection('usuarios').doc(id).set({
    "email": cuenta["email"],
    "clave": cuenta["clave"],
    "role": cuenta["role"],
    "username": cuenta["username"],
    "creadoEn": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> updateUsuarioCuenta(String id, Map<String, dynamic> cuenta) async {
  await db.collection('usuarios').doc(id).update({
    "email": cuenta["email"],
    "clave": cuenta["clave"],
    "role": cuenta["role"],
    "username": cuenta["username"],
  });
}

// Agregar Información Personal con avatar dinámico
Future<void> addUsuarioPersonal(
  String id,
  Map<String, dynamic> personal,
) async {
  final avatarUrl = generarAvatarUrl(
    personal["nombres"],
    personal["apellidos"],
  );

  await db.collection('usuarios').doc(id).set({
    "nombres": personal["nombres"],
    "apellidos": personal["apellidos"],
    "dni": personal["dni"],
    "nacimiento": personal["nacimiento"],
    "phone": personal["phone"],
    "direccion": personal["direccion"],
    "avatarUrl": avatarUrl,
  }, SetOptions(merge: true));
}

// Actualizar Información Personal con nuevo avatar dinámico
Future<void> updateUsuarioPersonal(
  String id,
  Map<String, dynamic> personal,
) async {
  // Obtener avatar actual
  final doc = await db.collection('usuarios').doc(id).get();
  final data = doc.data() as Map<String, dynamic>;
  final avatarActual = data["avatarUrl"];

  // Extraer color
  final colorActual = extraerColorDesdeAvatar(avatarActual);

  // Generar avatar solo con nuevas iniciales, pero mismo color
  final nuevoAvatarUrl = generarAvatarUrl(
    personal["nombres"],
    personal["apellidos"],
    colorHex: colorActual,
  );

  await db.collection('usuarios').doc(id).update({
    "nombres": personal["nombres"],
    "apellidos": personal["apellidos"],
    "dni": personal["dni"],
    "nacimiento": personal["nacimiento"],
    "phone": personal["phone"],
    "direccion": personal["direccion"],
    "avatarUrl": nuevoAvatarUrl,
  });
}

// Eliminar usuario
Future<void> deleteUsuario(String id) async {
  await db.collection('usuarios').doc(id).delete();
}
