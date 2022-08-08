class OptionSelect {
  int id = 0;
  String nombre = '';
  int id_servicio = 0;

  OptionSelect(
    this.id,
    this.nombre,
    this.id_servicio,
  );

  OptionSelect.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    id_servicio = json['id_servicio'];
  }
}
