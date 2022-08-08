class Empleado {
  int id = 0;
  String nombre = '';
  String apellido_pat = '';
  String apellido_mat = '';
  String email = '';
  String telefono = '';
  int rol = 0;
  int isActivo = 0;

  Empleado(
    this.id,
    this.nombre,
    this.apellido_pat,
    this.apellido_mat,
    this.email,
    this.telefono,
    this.rol,
    this.isActivo,
  );

  Empleado.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    apellido_pat = json['apellido_pat'];
    apellido_mat = json['apellido_mat'];
    email = json['email'];
    telefono = json['telefono'];
    rol = json['rol'];
    isActivo = json['isActivo'];
  }
}
