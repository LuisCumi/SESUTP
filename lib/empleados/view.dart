import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/empleados/edit.dart';

import '../clases/menu.dart';

class viewDetalleEmpleado extends StatefulWidget {
  //viewDetalleEmpleado({Key? key}) : super(key: key);
  int id = 0;
  String nombre = '';
  String apellido_pat = '';
  String apellido_mat = '';
  String email = '';
  String telefono = '';
  String pass = '';
  int isActivo = 0;

  viewDetalleEmpleado(
    this.id,
    this.nombre,
    this.apellido_pat,
    this.apellido_mat,
    this.email,
    this.telefono,
    this.pass,
    this.isActivo,
  );

  @override
  State<viewDetalleEmpleado> createState() => _viewDetalleEmpleadoState();
}

class _viewDetalleEmpleadoState extends State<viewDetalleEmpleado> {
  @override
  Widget build(BuildContext context) {
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
          'Detalles del empleado',
          textAlign: TextAlign.center,
        ),
        // ignore: prefer_const_literals_to_create_immutables

        backgroundColor: Colors.indigo.shade900,
      ),
      body: Center(
        child: detallesEmpleado(
            widget.id,
            widget.nombre,
            widget.apellido_pat,
            widget.apellido_mat,
            widget.email,
            widget.telefono,
            widget.isActivo,
            widget.pass,
            context),
      ),
      bottomNavigationBar: mostrarBoton(widget.isActivo, context, widget.id),
    );
  }
}

mostrarBoton(int isActivo, BuildContext context, id) {
  if (isActivo == 1) {
    return Material(
      color: Colors.indigo.shade900,
      child: InkWell(
        onTap: () {
          darDeBaja(id, context);
          print('called on tap');
        },
        child: const SizedBox(
          height: kToolbarHeight,
          width: double.infinity,
          child: Center(
            child: Text(
              'Dar de baja',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  } else {
    return Material(
      color: Colors.indigo.shade900,
      child: InkWell(
        onTap: () {
          darDeAlta(id, context);
          print('called on tap');
        },
        child: const SizedBox(
          height: kToolbarHeight,
          width: double.infinity,
          child: Center(
            child: Text(
              'Dar de Alta',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

void darDeBaja(id, context) async {
  final url = Constantes.url + '/darDeBaja';
  Map<String, dynamic> jsonMap = {
    'idUser': id.toString(),
  };
  http.post(Uri.parse(url), body: jsonMap).then((value) {
    Map<String, dynamic> datos = jsonDecode(value.body);
    if (datos['success']) {
      Navigator.of(context).pop();
    } else {
      final snackBarError = SnackBar(content: Text('Ocurrio un error'));
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}

void darDeAlta(id, context) async {
  final url = Constantes.url + '/darDeAlta';
  Map<String, dynamic> jsonMap = {
    'idUser': id.toString(),
  };
  http.post(Uri.parse(url), body: jsonMap).then((value) {
    Map<String, dynamic> datos = jsonDecode(value.body);
    if (datos['success']) {
      Navigator.of(context).pop();
    } else {
      final snackBarError = SnackBar(content: Text('Ocurrio un error'));
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}

Widget detallesEmpleado(
    id,
    String nombre,
    String apellido_pat,
    String apellido_mat,
    String email,
    String telefono,
    int isActivo,
    String pass,
    BuildContext context) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => editUsuario(id, nombre, apellido_pat,
                    apellido_mat, email, telefono, pass, isActivo),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              primary: Colors.green.shade800),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Editar'),
              Icon(Icons.edit),
            ],
          ),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade900,
                      ],
                    )),
                accountName:
                    Text(nombre + ' ' + apellido_pat + ' ' + apellido_mat),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.teal.shade400,
                  child: Text(
                    nombre[0],
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              ListTile(
                title: Text(telefono),
                subtitle: Text('Telefono'),
                trailing: mostrarEstatus(isActivo),
              )
            ],
          ),
        ),
      ),
    ],
  );
}

Widget mostrarEstatus(int isActivo) {
  if (isActivo == 1) {
    return Text('Activo');
  } else {
    return Text('Baja');
  }
}
