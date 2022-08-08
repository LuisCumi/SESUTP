class Solicitud {
  int id = 0;
  String nservicio = '';
  String pregunta_1 = '';
  String eleccion_1 = '';
  String pregunta_2 = '';
  String eleccion_2 = '';
  String estatus = '';
  String nusuario = '';
  String apellido_pat = '';
  String apellido_mat = '';

  Solicitud(
    this.id,
    this.nservicio,
    this.pregunta_1,
    this.eleccion_1,
    this.pregunta_2,
    this.eleccion_2,
    this.estatus,
    this.nusuario,
    this.apellido_pat,
    this.apellido_mat,
  );

  Solicitud.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nservicio = json['nservicio'];
    pregunta_1 = json['pregunta_1'];
    eleccion_1 = json['eleccion_1'];
    pregunta_2 = json['pregunta_2'];
    eleccion_2 = json['eleccion_2'] ?? '-';
    estatus = json['estatus'];
    nusuario = json['nusuario'];
    apellido_pat = json['apellido_pat'];
    apellido_mat = json['apellido_mat'];
  }
}
