// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/clases/solicitudes.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/empleados/index.dart';
import 'package:sesutp/login/login.dart';
import 'package:sesutp/solicitudes/index.dart';
import 'package:sesutp/solicitudes/view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../clases/menu.dart';

class indexAdmin extends StatefulWidget {
  indexAdmin({Key? key}) : super(key: key);

  @override
  State<indexAdmin> createState() => _indexAdminState();
}

class _indexAdminState extends State<indexAdmin> {
  List<Solicitud> _solicitud = [];

  Future<List<Solicitud>> listSolicitud() async {
    var url = Constantes.url + '/getSolicitudes';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> datos = jsonDecode(response.body);
    List<Solicitud> solicitud = [];
    if (datos['success']) {
      var solicitudJson = datos['data'];
      for (var solicitudJson in solicitudJson) {
        solicitud.add(Solicitud.fromJson(solicitudJson));
      }
    }

    return solicitud;
  }

  @override
  void initState() {
    listSolicitud().then((value) {
      setState(() {
        _solicitud.addAll(value);
      });
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer.getDrawer(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        // ignore:
        title: Text(
          'SESUTP',
          textAlign: TextAlign.center,
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                cerrarSesion(context);
                print('Aqui Cierra Sesion');
              },
            ),
          ),
        ],
        backgroundColor: Colors.indigo.shade900,
      ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Solicitudes',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: obtenerDatos,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (_solicitud.isNotEmpty) {
                    return GestureDetector(
                      onTap: (() {
                        var id = _solicitud[index].id;
                        verDetalle(id, context);
                      }),
                      child: Card(
                        child: ListTile(
                          title: Text(_solicitud[index].nservicio),
                          subtitle: Text(_solicitud[index].nusuario +
                              ' ' +
                              _solicitud[index].apellido_pat +
                              ' ' +
                              _solicitud[index].apellido_mat),
                          trailing: Text(_solicitud[index].estatus),
                        ),
                      ),
                    );
                  } else {
                    return Text('No hay Solicitudes');
                  }
                },
                itemCount: _solicitud.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> obtenerDatos() async {
    var url = Constantes.url + '/getSolicitudes';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> datos = jsonDecode(response.body);
    List<Solicitud> solicitud = [];
    if (datos['success']) {
      var solicitudJson = datos['data'];
      for (var solicitudJson in solicitudJson) {
        solicitud.add(Solicitud.fromJson(solicitudJson));
      }
    }
    setState(() {
      _solicitud = solicitud;
    });
  }
}

void cerrarSesion(BuildContext context) {
  setLoginData(context);
}

Future<void> setLoginData(BuildContext context) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setInt('idUser', 0);
  pref.setString('usuario', '');
  pref.setString('pass', '');
  pref.setInt('rol', 0);
  pref.setBool('logueado', false);
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => viewLogin()));
}

void verDetalle(id, context) {
  final url = Constantes.url + '/verDetalleSolicitud';
  Map<String, dynamic> jsonMap = {
    'idSolicitud': id.toString(),
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 3),
    content: Text("Cargando..."),
  ));

  http.post(Uri.parse(url), body: jsonMap).then((value) {
    Map<String, dynamic> datos = jsonDecode(value.body);
    final snackBarError = SnackBar(content: Text(datos['mensaje']));
    if (datos['success']) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => viewSolicitud(
                datos['data']['id'],
                datos['data']['nservicio'],
                datos['data']['pregunta_1'],
                datos['data']['eleccion_1'],
                datos['data']['pregunta_2'],
                datos['data']['eleccion_2'] ?? 'Ninguno',
                datos['data']['nusuario'],
                datos['data']['apellido_pat'],
                datos['data']['apellido_mat'],
                datos['data']['estatus'],
                datos['data']['observaciones'] ?? '',
                datos['data']['isEliminado'],
              )));
    } else {
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}

class CustomDrawer {
  static final _drawerItems = [
    DrawerItem("Inicio", Icons.home),
    DrawerItem("Usuarios", Icons.person)
  ];

  static _onTapDrawer(int itemPos, BuildContext context) {
    Constantes.selectedDrawerIndex = itemPos;
    switch (Constantes.selectedDrawerIndex) {
      case 0:
        {
          Navigator.pop(context);
        }
        break;
      case 1:
        {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => indexEmpleado()));
        }
        break;
    }
    // cerramos el drawer
  }

  static Widget getDrawer(BuildContext context) {
    List<Widget> drawerOptions = [];
    // armamos los items del menu
    for (var i = 0; i < _drawerItems.length; i++) {
      var d = _drawerItems[i];
      // ignore:
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(d.title),
        selected: i == Constantes.selectedDrawerIndex,
        onTap: () => _onTapDrawer(i, context),
      ));
    }

    // menu lateral
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: <Widget>[Column(children: drawerOptions)],
        ),
      ),
    );
  }
}
