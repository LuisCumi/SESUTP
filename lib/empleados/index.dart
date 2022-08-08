// ignore_for_file: unnecessary_new

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sesutp/clases/empleados.dart';
import 'package:sesutp/constantes/constantes.dart' as Constantes;
import 'package:sesutp/empleados/create.dart';
import 'package:sesutp/empleados/view.dart';

import '../clases/menu.dart';

class indexEmpleado extends StatefulWidget {
  indexEmpleado({Key? key}) : super(key: key);

  @override
  State<indexEmpleado> createState() => _indexEmpleadoState();
}

class _indexEmpleadoState extends State<indexEmpleado> {
  List<Empleado> _empleado = [];

  Future<List<Empleado>> listEmpleados() async {
    var url = Constantes.url + '/getEmpleados';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> datos = jsonDecode(response.body);
    List<Empleado> empleado = [];
    if (datos['success']) {
      var empleadosJson = datos['data'];
      for (var empleadoJson in empleadosJson) {
        empleado.add(Empleado.fromJson(empleadoJson));
      }
    }

    return empleado;
  }

  @override
  void initState() {
    listEmpleados().then((value) {
      setState(() {
        _empleado.addAll(value);
      });
    });
    super.initState();
    setState(() {});
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
        title: const Text(
          'SESUTP',
          textAlign: TextAlign.center,
        ),

        backgroundColor: Colors.indigo.shade900,
      ),
      body: RefreshIndicator(
        onRefresh: obtenerDatos,
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (_empleado.isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  obtenerDetalleEmpleado(_empleado[index].id, context);
                },
                child: Card(
                  child: ListTile(
                    title: Text(_empleado[index].nombre +
                        ' ' +
                        _empleado[index].apellido_pat +
                        ' ' +
                        _empleado[index].apellido_mat),
                    subtitle: Text(_empleado[index].telefono),
                    trailing: ponerEstatus(_empleado[index].isActivo),
                  ),
                ),
              );
            } else {
              return Text('No hay Empleados');
            }
          },
          itemCount: _empleado.length,
        ),
      ),
      bottomNavigationBar: Material(
        color: Colors.indigo.shade900,
        child: InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => createNewUser()));
            print('called on tap');
          },
          child: const SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Center(
              child: Text(
                'Agregar Usuario',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> obtenerDatos() async {
    var url = Constantes.url + '/getEmpleados';
    var response = await http.get(Uri.parse(url));

    Map<String, dynamic> datos = jsonDecode(response.body);
    List<Empleado> empleado = [];
    if (datos['success']) {
      var empleadosJson = datos['data'];
      print(empleadosJson);
      for (var empleadoJson in empleadosJson) {
        empleado.add(Empleado.fromJson(empleadoJson));
      }
    }
    setState(() {
      _empleado = empleado;
    });
  }
}

void obtenerDetalleEmpleado(id, context) {
  print(id);

  final url = Constantes.url + '/verDetalleEmpleado';
  Map<String, dynamic> jsonMap = {
    'idUser': id.toString(),
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
          builder: (context) => viewDetalleEmpleado(
                datos['data']['id'],
                datos['data']['nombre'],
                datos['data']['apellido_pat'],
                datos['data']['apellido_mat'],
                datos['data']['email'],
                datos['data']['telefono'],
                datos['data']['password'],
                datos['data']['isActivo'],
              )));
    } else {
      Scaffold.of(context).showSnackBar(snackBarError);
    }
  });
}

Widget ponerEstatus(int estatus) {
  if (estatus == 1) {
    return Text('Activo');
  } else {
    return Text('Baja');
  }
}

class CustomDrawer {
  static final _drawerItems = [
    DrawerItem("Inicio", Icons.home),
    DrawerItem("Usuarios", Icons.person),
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
