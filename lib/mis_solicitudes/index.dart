import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sesutp/clases/menu.dart';
import 'package:sesutp/clases/solicitudes.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:http/http.dart' as http;
import 'package:sesutp/mis_solicitudes/view.dart';
import 'package:sesutp/principal/indexUser.dart';

class indexMisSolicitudes extends StatefulWidget {
  indexMisSolicitudes({Key? key}) : super(key: key);

  @override
  State<indexMisSolicitudes> createState() => _indexMisSolicitudesState();
}

class _indexMisSolicitudesState extends State<indexMisSolicitudes> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Solicitud> _solicitud = [];

  Future<List<Solicitud>> listMisSolicitudes() async {
    var url = Constantes.url + '/getMisSolicitudes';
    Map<String, dynamic> jsonMap = {
      'idUser': Constantes.idUser.toString(),
    };
    var response = await http.post(Uri.parse(url), body: jsonMap);

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
    listMisSolicitudes().then((value) {
      setState(() {
        _solicitud.addAll(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer.getDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Mis solicitudes'),
      ),
      body: RefreshIndicator(
        onRefresh: obtenerDatos,
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (_solicitud.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  verDetalle(_solicitud[index].id, context);
                },
                child: Card(
                  child: ListTile(
                    title: Text(_solicitud[index].nservicio),
                    subtitle: Text(''),
                    trailing: Text(_solicitud[index].estatus),
                  ),
                ),
              );
            } else {
              return Center(child: Text('No hay Solicitudes'));
            }
          },
          itemCount: _solicitud.length,
        ),
      ),
    );
  }

  Future<void> obtenerDatos() async {
    var url = Constantes.url + '/getMisSolicitudes';
    Map<String, dynamic> jsonMap = {
      'idUser': Constantes.idUser.toString(),
    };
    var response = await http.post(Uri.parse(url), body: jsonMap);

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

class CustomDrawer {
  static final _drawerItems = [
    DrawerItem("Home", Icons.home),
    DrawerItem("Mis Solicitudes", Icons.description),
  ];

  static _onTapDrawer(int itemPos, BuildContext context) {
    Constantes.selectedDrawerIndex = itemPos;
    print(Constantes.selectedDrawerIndex);
    switch (Constantes.selectedDrawerIndex) {
      case 0:
        {
          Navigator.of(context).pop();
          Navigator.pop(context);
        }
        break;
      case 1:
        {
          Navigator.pop(context);
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
          builder: (context) => viewDetalleMiSolicitud(
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
                datos['data']['observaciones'] ?? '-',
              )));
    } else {
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}
