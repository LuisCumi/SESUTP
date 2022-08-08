import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;

import '../clases/menu.dart';

class editUsuario extends StatefulWidget {
  //editUsuario({Key? key}) : super(key: key);

  int id = 0;
  String nombre = '';
  String apellido_pat = '';
  String apellido_mat = '';
  String email = '';
  String telefono = '';
  String pass = '';
  int isActivo = 0;

  editUsuario(
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
  State<editUsuario> createState() => _editUsuarioState();
}

class _editUsuarioState extends State<editUsuario> {
  @override
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    TextEditingController nombre =
        new TextEditingController(text: widget.nombre);
    TextEditingController apellid_pat =
        new TextEditingController(text: widget.apellido_pat);
    TextEditingController apellid_mat =
        new TextEditingController(text: widget.apellido_mat);
    TextEditingController telefono =
        new TextEditingController(text: widget.telefono);
    TextEditingController emailController =
        new TextEditingController(text: widget.email);
    TextEditingController passwordController =
        new TextEditingController(text: widget.pass);
    TextEditingController passwordControllerVerify =
        new TextEditingController(text: widget.pass);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Editar Usuario'),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Card(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(children: <Widget>[
                    Expanded(child: Divider()),
                    const Text('Datos de Usuario'),
                    Expanded(child: Divider()),
                  ]),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: nombre,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nombre',
                        hintText: 'Nombre'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: apellid_pat,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Apelldo Paterno',
                        hintText: 'Apelldo Paterno'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: apellid_mat,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Apelldo Materno',
                        hintText: 'Apelldo Materno'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: telefono,
                    maxLength: 10,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Telefono',
                        hintText: '9999999999'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Row(children: <Widget>[
                    Expanded(child: Divider()),
                    const Text('Datos de la cuenta'),
                    Expanded(child: Divider()),
                  ]),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Correo',
                        hintText: 'ejemplo@correo.com'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Contraseña',
                        hintText: 'Contraseña'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  TextField(
                    controller: passwordControllerVerify,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Repetir Contraseña',
                        hintText: 'Repetir Contraseña'),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  ElevatedButton(
                    onPressed: () {
                      actualizarUsuario(
                          widget.id,
                          nombre.text,
                          apellid_pat.text,
                          apellid_mat.text,
                          telefono.text,
                          emailController.text,
                          passwordController.text,
                          passwordControllerVerify.text,
                          _scaffoldKey,
                          context);
                    },
                    child: Text('Actualizar datos'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void actualizarUsuario(
    id,
    nombre,
    apellid_pat,
    apellid_mat,
    telefono,
    emailController,
    passwordController,
    passwordControllerVerify,
    scaffoldKey,
    context) {
  if (nombre != '' &&
      apellid_pat != '' &&
      apellid_mat != '' &&
      telefono != '' &&
      emailController != '' &&
      passwordController != '' &&
      passwordControllerVerify != '') {
    if (passwordController == passwordControllerVerify) {
      scaffoldKey.currentState
          ?.showSnackBar(new SnackBar(content: new Text('Por favor espere')));
      final url = Constantes.url + '/actualizarUsuario';
      Map<String, dynamic> jsonMap = {
        'idUser': id.toString(),
        'nombre': nombre.toString(),
        'apellido_pat': apellid_pat.toString(),
        'apellido_mat': apellid_mat.toString(),
        'email': emailController.toString(),
        'password': passwordControllerVerify.toString(),
        'telefono': telefono.toString(),
      };

      http.post(Uri.parse(url), body: jsonMap).then((value) {
        Map<String, dynamic> datos = jsonDecode(value.body);
        final snackBarError = SnackBar(content: Text(datos['mensaje']));
        if (datos['success']) {
          Navigator.of(context).pop();
        } else {
          scaffoldKey.currentState?.showSnackBar(
              new SnackBar(content: new Text('Ocurrio un error')));
        }
      });
    } else {
      scaffoldKey.currentState?.showSnackBar(
          new SnackBar(content: new Text('La contraseña no coincide')));
    }
  } else {
    scaffoldKey.currentState?.showSnackBar(
        new SnackBar(content: new Text('Debe completar los campos')));
  }
}
