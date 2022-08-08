class Servicios {
  int id = 0;
  String nombre = '';
  String descripcion = '';
  String pregunta_1 = '';
  String pregunta_2 = '';
  String icono = '';

  Servicios(
    this.id,
    this.nombre,
    this.descripcion,
    this.pregunta_1,
    this.pregunta_2,
    this.icono,
  );

  Servicios.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    descripcion = json['descripcion'];
    pregunta_1 = json['pregunta_1'];
    pregunta_2 = json['pregunta_2'];
    icono = json['icono'];
  }
}
