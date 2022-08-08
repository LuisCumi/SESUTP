// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/clases/solicitudes.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/empleados/index.dart';
import 'package:sesutp/solicitudes/index.dart';
import 'package:fluttertoast/fluttertoast.dart';

class viewSolicitud extends StatefulWidget {
  //viewSolicitud({Key? key}) : super(key: key);

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
  String isEliminado = '';

  viewSolicitud(
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
    this.isEliminado,
  );

  @override
  State<viewSolicitud> createState() => _viewSolicitudState();
}

class _viewSolicitudState extends State<viewSolicitud> {
  @override
  Widget build(BuildContext context) {
    TextEditingController observaciones =
        new TextEditingController(text: widget.observaciones);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // ignore:
        title: Text(
          widget.servicio,
          textAlign: TextAlign.center,
        ),
        // ignore: prefer_const_literals_to_create_immutables

        backgroundColor: Colors.indigo.shade900,
      ),
      body: SingleChildScrollView(
        child: Center(
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // ignore:
                    child: TextField(
                        controller: observaciones,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Observaciones',
                            hintText: 'Escriba aqui sus observaciones')),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.isEliminado != '1') {
                          crearExcepcion(
                              widget.id, context, observaciones.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          primary: Colors.red),
                      child: Text('Mandar Excepción'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          mostrarBoton(widget.estatus, context, widget.id, widget.isEliminado),
    );
  }
}

void crearExcepcion(int id, BuildContext context, String observaciones) {
  print('Excepcion');
  final url = Constantes.url + '/cambiarEstatus';
  Map<String, dynamic> jsonMap = {
    'idSolicitud': id.toString(),
    'estatus': 'Excepción',
    'observaciones': observaciones,
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

mostrarBoton(String estatus, context, int id, eliminado) {
  if (eliminado != '1') {
    if (estatus == 'Pendiente') {
      return Material(
        color: Colors.indigo.shade900,
        child: InkWell(
          onTap: () {
            marcarCompletado(context, id);
          },
          child: const SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Center(
              child: Text(
                'Marcar como completado',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
  } else {
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
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

void eliminar(context, int id) {
  final url = Constantes.url + '/borrarDefinitivo';
  Map<String, dynamic> jsonMap = {
    'idSolicitud': id.toString(),
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

void marcarCompletado(context, int id) {
  final url = Constantes.url + '/cambiarEstatus';
  Map<String, dynamic> jsonMap = {
    'idSolicitud': id.toString(),
    'estatus': 'Completado',
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
