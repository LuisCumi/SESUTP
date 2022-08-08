import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sesutp/clases/servicios.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/principal/indexAdmin.dart';
import 'package:sesutp/servicios/view.dart';

import '../clases/menu.dart';
import '../mis_solicitudes/index.dart';

class indexUser extends StatefulWidget {
  indexUser({Key? key}) : super(key: key);

  @override
  State<indexUser> createState() => _indexUserState();
}

class _indexUserState extends State<indexUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Servicios> _servicio = [];
  Future<List<Servicios>> listServicios() async {
    List<Servicios> servicio = [];
    try {
      var url = Constantes.url + '/obtenerServicios';
      var response = await http.get(Uri.parse(url));

      Map<String, dynamic> datos = jsonDecode(response.body);

      if (datos['success']) {
        var serviciosJson = datos['data'];
        for (var servicioJson in serviciosJson) {
          servicio.add(Servicios.fromJson(servicioJson));
        }
      }
    } on SocketException catch (_) {
      _scaffoldKey.currentState
          ?.showSnackBar(new SnackBar(content: new Text('Sin conexion')));
    }

    return servicio;
  }

  @override
  void initState() {
    try {
      listServicios().then((value) {
        setState(() {
          _servicio.addAll(value);
        });
      });
    } on SocketException catch (_) {
      print('Sin Conexion');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer.getDrawer(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        // ignore:
        title: const Text(
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: obtenerDatos,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext ctx, index) {
              return GestureDetector(
                onTap: () {
                  print('Estas Clickando: ' + _servicio[index].id.toString());
                  var id = _servicio[index].id;
                  verDetalleServicio(id, context);
                },
                child: Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ignore: prefer_const_constructors
                        Center(
                          // ignore: prefer_const_constructors
                          child: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Divider(),
                        Center(
                          child: Text(_servicio[index].nombre),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: _servicio.length,
          ),
        ),
      ),
    );
  }

  Future<void> obtenerDatos() async {
    var url = Constantes.url + '/obtenerServicios';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> datos = jsonDecode(response.body);
    List<Servicios> servicio = [];
    if (datos['success']) {
      var serviciosJson = datos['data'];
      for (var servicioJson in serviciosJson) {
        servicio.add(Servicios.fromJson(servicioJson));
      }
    }

    setState(() {
      _servicio = servicio;
    });
  }
}

void verDetalleServicio(int id, BuildContext context) {
  final url = Constantes.url + '/getDetalleServicio';
  Map<String, dynamic> jsonMap = {
    'idServicio': id.toString(),
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
          builder: (context) => viewServicios(
                datos['data']['id'],
                datos['data']['nombre'],
                datos['data']['descripcion'],
                datos['data']['pregunta_1'],
                datos['data']['pregunta_2'],
              )));
    } else {
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}

class CustomDrawer {
  static final _drawerItems = [
    DrawerItem("Inicio", Icons.home),
    DrawerItem("Mis Solicitudes", Icons.description),
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
              MaterialPageRoute(builder: (context) => indexMisSolicitudes()));
        }
        break;
    }
    // cerramos el drawer
    Constantes.selectedDrawerIndex = itemPos;
  }

  static Widget getDrawer(BuildContext context) {
    List<Widget> drawerOptions = [];
    // armamos los items del menu
    for (var i = 0; i < _drawerItems.length; i++) {
      var d = _drawerItems[i];
      // ignore:
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
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
