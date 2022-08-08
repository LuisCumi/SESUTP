// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:group_radio_button/group_radio_button.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/clases/optionSelect.dart';

class viewServicios extends StatefulWidget {
  //viewServicios({Key? key}) : super(key: key);

  int id = 0;
  String nombre = '';
  String descripcion = '';
  String pregunta_1 = '';
  String pregunta_2 = '';

  viewServicios(
    this.id,
    this.nombre,
    this.descripcion,
    this.pregunta_1,
    this.pregunta_2,
  );

  @override
  State<viewServicios> createState() => _viewServiciosState();
}

class _viewServiciosState extends State<viewServicios> {
  List? _options = [];
  String? _myEleccion;

  Future listOpciones() async {
    var url = Constantes.url + '/getSelectServicio';
    Map<String, dynamic> jsonMap = {
      'idServicio': widget.id.toString(),
    };
    var response = await http.post(Uri.parse(url), body: jsonMap).then((value) {
      var datos = jsonDecode(value.body);

      setState(() {
        _options = datos['data'];
      });
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  @override
  void initState() {
    listOpciones();
    super.initState();
  }

  String _verticalGroupValue = "No";
  final List<String> _status = ["No", "Si"];
  @override
  Widget build(BuildContext context) {
    var _valorSeleccionado = '';
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        title: const Text('Detalles'),
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
                      widget.nombre,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        widget.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        widget.pregunta_1,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      RadioGroup<String>.builder(
                        groupValue: _verticalGroupValue,
                        onChanged: (value) => setState(() {
                          _verticalGroupValue = value!;
                          print(_verticalGroupValue);
                        }),
                        items: _status,
                        itemBuilder: (item) => RadioButtonBuilder(
                          item,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: _myEleccion,
                            iconSize: 30,
                            icon: (null),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            hint: Text('Seleccionar una opcion'),
                            onChanged: (newValue) {
                              setState(() {
                                _myEleccion = newValue.toString();
                                print(_myEleccion);
                              });
                            },
                            items: _options?.map((item) {
                                  return DropdownMenuItem(
                                    child: Text(
                                      item['nombre'],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    value: item['nombre'].toString(),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (contexto) => Material(
          color: Colors.indigo.shade900,
          child: InkWell(
            onTap: () {
              if (_verticalGroupValue == 'Si') {
                if (_myEleccion == null) {
                  final snackBarError =
                      SnackBar(content: Text('Debes seleccionar una opción'));
                  Scaffold.of(contexto).showSnackBar(snackBarError);
                } else {
                  enviarSolicitud(
                      contexto,
                      widget.id,
                      widget.nombre,
                      widget.pregunta_1,
                      _verticalGroupValue,
                      widget.pregunta_2,
                      _myEleccion,
                      _scaffoldKey);
                }
              } else {
                enviarSolicitud(
                    contexto,
                    widget.id,
                    widget.nombre,
                    widget.pregunta_1,
                    _verticalGroupValue,
                    widget.pregunta_2,
                    '',
                    _scaffoldKey);
              }
            },
            child: const SizedBox(
              height: kToolbarHeight,
              width: double.infinity,
              child: Center(
                child: Text(
                  'Enviar Solicitud',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void enviarSolicitud(
  BuildContext contexto,
  int id,
  String nombre,
  String pregunta_1,
  String verticalGroupValue,
  String pregunta_2,
  String? myEleccion,
  GlobalKey<ScaffoldState> scaffoldKey,
) async {
  //
  scaffoldKey.currentState
      ?.showSnackBar(new SnackBar(content: new Text('Enviando Solicitud')));
  var url = Constantes.url + '/crearSolicitud';
  Map<String, dynamic> jsonMap = {
    'idServicio': id.toString(),
    'descripcion': nombre.toString(),
    'pregunta_1': pregunta_1.toString(),
    'eleccion_1': verticalGroupValue.toString(),
    'pregunta_2': pregunta_2.toString(),
    'eleccion_2': myEleccion.toString(),
    'estatus': 'Pendiente',
    'idUsuario': Constantes.idUser.toString(),
  };
  var response = await http.post(Uri.parse(url), body: jsonMap).then((value) {
    var datos = jsonDecode(value.body);
    if (datos['success']) {
      scaffoldKey.currentState
          ?.showSnackBar(new SnackBar(content: new Text('Solicitud Enviada')));
      Timer(Duration(seconds: 5), () {
        Navigator.of(contexto).pop();
      });
    } else {
      final snackBarError =
          SnackBar(content: Text('Ocurrio un error al enviar'));
      Scaffold.of(contexto).showSnackBar(snackBarError);
    }
  }).onError((error, stackTrace) {
    final snackBarError =
        SnackBar(content: Text('Ocurrio un error de internet'));
    Scaffold.of(contexto).showSnackBar(snackBarError);
  });
}
