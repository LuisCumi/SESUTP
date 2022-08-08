// ignore_for_file: prefer_const_constructors, unnecessary_new, camel_case_types, avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable, prefer_const_declarations
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:sesutp/principal/indexAdmin.dart';
import 'package:sesutp/principal/indexUser.dart';

import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:shared_preferences/shared_preferences.dart';

class viewLogin extends StatefulWidget {
  viewLogin({Key? key}) : super(key: key);

  @override
  State<viewLogin> createState() => _viewLoginState();
}

class _viewLoginState extends State<viewLogin> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/utp.png',
                scale: 2.0,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
          ),
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
              ),
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'correo@ejemplo.com'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Contraseña',
                        hintText: 'Ingrese su contraseña'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ingresar(emailController.text, passwordController.text,
                          context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text('Iniciar Sesión'),
                  )
                ],
              )),
        ],
      ),
    ));
  }
}

void ingresar(String email, String pass, BuildContext context) async {
  final snackBarError = SnackBar(content: Text('Cargando'));
  Scaffold.of(context).showSnackBar(snackBarError);
  final url = Constantes.url + '/login';
  Map<String, dynamic> jsonMap = {
    'email': email,
    'pass': pass,
  };

  final snackBar = SnackBar(content: Text('Complete los campos'));

  if (email.isEmpty || pass.isEmpty) {
    Scaffold.of(context).showSnackBar(snackBar);
  } else {
    print('Si paso');
    http.post(Uri.parse(url), body: jsonMap).then((value) {
      Map<String, dynamic> datos = jsonDecode(value.body);
      final snackBarError = SnackBar(content: Text(datos['mensaje']));

      if (datos['success']) {
        if (datos['data']['isActivo'] != 1) {
          final snackBarError =
              SnackBar(content: Text('Tu usuario esta dado de baja.'));
          Scaffold.of(context).showSnackBar(snackBarError);
        } else {
          //
          setLoginData(email, pass, datos['data']['rol'], datos['data']['id'],
              datos['data']['isActivo']);
          if (datos['data']['rol'] == 1) {
            Constantes.idUser = datos['data']['id'].toString();
            Constantes.rolUser = datos['data']['rol'].toString();
            Constantes.isActivo = datos['data']['isActivo'].toString();
            print('idUsuario: ' + Constantes.idUser.toString());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => indexAdmin(),
              ),
            );
          }
          if (datos['data']['rol'] == 2) {
            Constantes.idUser = datos['data']['id'].toString();
            Constantes.rolUser = datos['data']['rol'].toString();
            Constantes.isActivo = datos['data']['isActivo'].toString();
            print('idUsuario: ' + Constantes.idUser.toString());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => indexUser(),
              ),
            );
          }
        }
      } else {
        Scaffold.of(context).showSnackBar(snackBarError);
      }
    });
  }
}

Future<void> setLoginData(email, pass, rol, id, isActivo) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setInt('idUser', id);
  pref.setString('usuario', email);
  pref.setString('pass', pass);
  pref.setInt('rol', rol);
  pref.setBool('logueado', true);
  pref.setString('isActivo', isActivo.toString());
}
