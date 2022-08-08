import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/empleados/view.dart';

import '../clases/menu.dart';

class createNewUser extends StatefulWidget {
  createNewUser({Key? key}) : super(key: key);

  @override
  State<createNewUser> createState() => _createNewUserState();
}

class _createNewUserState extends State<createNewUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    TextEditingController nombre = new TextEditingController();
    TextEditingController apellid_pat = new TextEditingController();
    TextEditingController apellid_mat = new TextEditingController();
    TextEditingController telefono = new TextEditingController();
    TextEditingController emailController = new TextEditingController();
    TextEditingController passwordController = new TextEditingController();
    TextEditingController passwordControllerVerify =
        new TextEditingController();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Crear Usuario'),
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
                      guardarUsuario(
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
                    child: Text('Crear Usuario'),
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

void guardarUsuario(nombre, apellid_pat, apellid_mat, telefono, emailController,
    passwordController, passwordControllerVerify, scaffoldKey, context) async {
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
      final url = Constantes.url + '/registrarUsuario';
      Map<String, dynamic> jsonMap = {
        'nombre': nombre,
        'apellido_pat': apellid_pat,
        'apellido_mat': apellid_mat,
        'email': emailController,
        'password': passwordControllerVerify,
        'telefono': telefono,
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
