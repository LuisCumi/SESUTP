import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/constantes/constantes.dart' as Constantes;

class viewDetalleMiSolicitud extends StatefulWidget {
  //viewDetalleMiSolicitud({Key? key}) : super(key: key);
  int id = 0;
  String servicio = '';
  String pregunta_1 = '';
  String eleccion_1 = '';
  String pregunta_2 = '';
  String eleccion_2 = '';
  String nusuario = '';
  String apellido_pat = '';
  String apellido_mat = '';
  String estatus = '';
  String observaciones = '';

  viewDetalleMiSolicitud(
    this.id,
    this.servicio,
    this.pregunta_1,
    this.eleccion_1,
    this.pregunta_2,
    this.eleccion_2,
    this.nusuario,
    this.apellido_pat,
    this.apellido_mat,
    this.estatus,
    this.observaciones,
  );

  @override
  State<viewDetalleMiSolicitud> createState() => _viewDetalleMiSolicitudState();
}

class _viewDetalleMiSolicitudState extends State<viewDetalleMiSolicitud> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text('Detalle de mi solicitud'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Solicitó: ' +
                          widget.nusuario +
                          ' ' +
                          widget.apellido_pat +
                          ' ' +
                          widget.apellido_mat,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Servicio: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(widget.servicio, style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        widget.pregunta_1 + ': ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(widget.eleccion_1, style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        widget.pregunta_2 + ': ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(widget.eleccion_2, style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Estatus: ' + widget.estatus,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                Divider(),
                // ignore: prefer_const_constructors
                Center(
                  child: const Text(
                    'Observaciones',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(widget.observaciones),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: mostrarBoton(widget.estatus, context, widget.id),
    );
  }
}

mostrarBoton(String estatus, context, int id) {
  return Material(
    color: Colors.red.shade900,
    child: InkWell(
      onTap: () {
        eliminar(context, id);
      },
      child: const SizedBox(
        height: kToolbarHeight,
        width: double.infinity,
        child: Center(
          child: Text(
            'Eliminar',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

void eliminar(context, int id) {
  final url = Constantes.url + '/eliminarSolicitud';
  Map<String, dynamic> jsonMap = {
    'idSolicitud': id.toString(),
    'estatus': 'Eliminado por el Usuario',
  };
  http.post(Uri.parse(url), body: jsonMap).then((value) {
    Map<String, dynamic> datos = jsonDecode(value.body);
    final snackBarError = SnackBar(content: Text(datos['mensaje']));
    if (datos['success']) {
      Navigator.of(context).pop();
    } else {
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}
