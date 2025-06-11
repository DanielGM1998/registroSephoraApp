import 'dart:convert';
import 'dart:developer';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:sephora/main.dart';
import 'package:flutter/material.dart';
import 'package:sephora/presentation/screens/premio/premio_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/constants.dart';
import '../screens/home/home_screen.dart';
import 'package:http/http.dart' as http;

AppBar myAppBar(BuildContext context, String name, String idapp, String tipo) {
  final Size size = MediaQuery.of(context).size;
  Future<bool> onWillPop1() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove("id");
              await prefs.remove("nombre");
              await prefs.remove("nombre_encargado");
              await prefs.remove("telefono");
              await prefs.remove("email");
              await prefs.remove("tipo");
              await prefs.remove("pass");
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, 'login');
            },
            child: const Text('Si'),
          ),
        ],
      ),
    )) ??
    false;
  }
  
  return AppBar(
    elevation: 1,
    shadowColor: myColor,
    centerTitle: true,
    backgroundColor: Colors.white,
    title: Text(name, style: const TextStyle(color: myColor)),
    iconTheme: const IconThemeData(color: myColor),
    leading: Row(
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); 
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.home_outlined), 
          onPressed: () {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            if(tipo=="3"){
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                PremioScreen.routeName,
                (Route<dynamic> route) => false,
                arguments: {
                  'idapp': args['idapp'].toString(),
                },
              );
            }else{
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                HomeScreen.routeName,
                (Route<dynamic> route) => false,
                arguments: {
                  'idapp': args['idapp'].toString(),
                },
              );
            }
          },
        ),
      ],
    ),
    leadingWidth: size.width * 0.28,
    actions: <Widget>[
      if(tipo=="2")
        IconButton(
          onPressed: () async{
            showProgress(context, idapp);
          },
          icon: const Icon(Icons.stacked_bar_chart),
          color: myColor,
        ),

      if(tipo=="1")
        PopupMenuButton(
          color: Colors.white,
          icon: const Icon(Icons.more_vert_outlined, color: myColor),
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    const Icon(Icons.login),
                    SizedBox(width: size.width * 0.03),
                    const Text("Cerrar sesión", style: TextStyle(color: myColor)),
                  ],
                ),
              ),
            ];
          },
          onSelected: (value) {
            if (value == 1) {
              onWillPop1();
            }else if (value == 2) {
              
            }
          },
        )      
    ],
  );
}

showProgress(BuildContext context, String id) async {
  var result = await showDialog(
    context: context,
    builder: (context) => FutureProgressDialog(_check(id)),
  );

  // ignore: use_build_context_synchronously
  showResultDialog(context, result);
}

Future<String> _check(id) async {
  try {
    final response = await http.get(
        Uri(
          scheme: https,
          host: host,
          path: "/registro/estadisticaByID/$id",

          // scheme: https,
          // host: host,
          // path: '$path/registro/estadisticaByID/$id',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Access-Control-Allow-Origin': '*'
        });

    // log('Código de estado: ${response.statusCode}');
    // log('Respuesta cruda: ${response.body}');
    // String body3 = utf8.decode(response.bodyBytes);
    // var jsonData = jsonDecode(body3);
    // log('${jsonData['result']['general']},${jsonData['result']['demo']},${jsonData['result']['total']}');

    if (response.statusCode == 200) {
      String body3 = utf8.decode(response.bodyBytes);
      var jsonData = jsonDecode(body3);
      if (jsonData['response']==true) {
        log('${jsonData['result']['general']},${jsonData['result']['demo']},${jsonData['result']['total']}');
        return '${jsonData['result']['general']},${jsonData['result']['demo']},${jsonData['result']['total']}';
      } else {
        return 'Ocurrio algo extraño, Vuelve a intentar';
      }
    } else {
      return 'Error, verificar conexión a Internet';
    }
  } catch (e) {
    return 'Error, verificar conexión a Internet';
  }
}

Future<void> showResultDialog(BuildContext context, String result) async {
  var splitted = result.split(',');
  if (result == 'Error, verificar conexión a Internet' || result == 'Ocurrio algo extraño, Vuelve a intentar') {
    HapticFeedback.heavyImpact();
    awesomeTopSnackbar(
      context,
      result,
      textStyle: const TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
          fontSize: 20),
      backgroundColor:
          Colors.orangeAccent,
      icon: const Icon(Icons.error,
          color: Colors.black),
      iconWithDecoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
            color: Colors.black),
      ),
    );
  }else{
    HapticFeedback.heavyImpact();
    awesomeTopSnackbar(
        context,
        "Total visitas: ${splitted[2]}\nGeneral: ${splitted[0]} Actividad: ${splitted[1]}",
        textStyle: const TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
            fontSize: 14),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.check,
            color: Colors.white),
        iconWithDecoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(20),
          border:
              Border.all(color: Colors.white),
        ),
      );
  } 
}