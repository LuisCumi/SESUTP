// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sesutp/login/login.dart';
import 'package:sesutp/principal/indexAdmin.dart';
import 'package:sesutp/principal/indexUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;

class spalshScreen extends StatefulWidget {
  spalshScreen({Key? key}) : super(key: key);

  @override
  State<spalshScreen> createState() => _spalshScreenState();
}

class _spalshScreenState extends State<spalshScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(
      Duration(milliseconds: 3000),
      () => validar(context),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Spacer(),
            Center(
              child: FractionallySizedBox(
                widthFactor: .6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/utp.png',
                      scale: 2.0,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            CircularProgressIndicator(),
            Spacer(),
            Text('Te damos la Bienvenida')
          ],
        ),
      ),
    );
  }
}

validar(context) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var login = preferences.getBool('logueado').toString();
    var id = preferences.getInt('idUser').toString();
    var rol = preferences.getInt('rol').toString();
    var isActivo = preferences.getString('isActivo').toString();

    //Para volver a generar el inicio
    var email = preferences.getString('usuario').toString();
    var pass = preferences.getString('pass').toString();

    Constantes.idUser = id;
    Constantes.rolUser = rol;

    //Guardamos en constantes cada vez que se inicia
    Constantes.usuario = email;
    Constantes.pass = pass;

    print(login);
    print('idUser: ' + Constantes.idUser.toString());
    print(rol);
    print('Esta Activo: ' + isActivo);

    if (login == 'true') {
      final url = Constantes.url + '/login';
      Map<String, dynamic> jsonMap = {
        'email': email.toString(),
        'pass': pass.toString(),
      };
      print('Si paso');
      http.post(Uri.parse(url), body: jsonMap).then((value) {
        Map<String, dynamic> datos = jsonDecode(value.body);
        final snackBarError = SnackBar(content: Text(datos['mensaje']));

        if (datos['success']) {
          if (datos['data']['isActivo'] != 1) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => viewLogin()));
            final snackBarError =
                SnackBar(content: Text('Tu usuario esta dado de baja.'));
            Scaffold.of(context).showSnackBar(snackBarError);
          } else {
            //
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
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => viewLogin()));
        }
      });
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => viewLogin()));
    }
  } on SocketException catch (_) {
    print('not connected');
  }
}
