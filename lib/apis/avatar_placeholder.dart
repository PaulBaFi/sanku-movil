import 'dart:math';

String? extraerColorDesdeAvatar(String avatarUrl) {
  final uri = Uri.parse(avatarUrl);
  return uri.queryParameters["background"];
}

String generarAvatarUrl(
  String nombres,
  String apellidos, {
  String? colorHex,
}) {
  final primerNombre = nombres.split(" ").first;
  final primerApellido = apellidos.split(" ").first;

  final iniciales = (primerNombre[0] + primerApellido[0]).toUpperCase();

  // Si no viene color, generar uno nuevo
  colorHex ??= List.generate(6, (_) {
    const chars = '0123456789ABCDEF';
    return chars[Random().nextInt(chars.length)];
  }).join();

  return "https://avatar.iran.liara.run/username?username=$iniciales&background=$colorHex&color=fff&size=128";
}
