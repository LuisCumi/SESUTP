import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/clases/solicitudes.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/empleados/index.dart';

import '../clases/menu.dart';

class indexSolicitudes extends StatefulWidget {
  indexSolicitudes({Key? key}) : super(key: key);

  @override
  State<indexSolicitudes> createState() => _indexSolicitudesState();
}

class _indexSolicitudesState extends State<indexSolicitudes> {
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

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
            child: Icon(Icons.more_vert),
          ),
        ],
        backgroundColor: Colors.indigo.shade900,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (_solicitud.isNotEmpty) {
            return Card(
              child: Column(
                children: [
                  Text(_solicitud[index].nservicio),
                  Text(_solicitud[index].estatus),
                ],
              ),
            );
          } else {
            return Text('No hay Empleados');
          }
        },
        itemCount: _solicitud.length,
      ),
    );
  }
}

class CustomDrawer {
  static final _drawerItems = [
    DrawerItem("Incio", Icons.home),
    DrawerItem("Usuarios", Icons.person)
  ];

  static _onTapDrawer(int itemPos, BuildContext context) {
    Constantes.selectedDrawerIndex = itemPos;
    switch (Constantes.selectedDrawerIndex) {
      case 0:
        {
          Navigator.of(context).pop();
          Navigator.pop(context);
        }
        break;
      case 1:
        {
          Navigator.of(context).pop();
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
