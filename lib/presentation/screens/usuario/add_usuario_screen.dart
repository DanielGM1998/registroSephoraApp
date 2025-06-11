import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/constants/constants.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/home/home_screen.dart';
import 'package:sephora/presentation/screens/usuario/usuario_screen.dart';
import 'package:sephora/presentation/widgets/side_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class AgregarUsuarioScreen extends StatefulWidget {
  static const String routeName = 'agregar_usuario';

  const AgregarUsuarioScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AgregarUsuarioScreen> createState() => _AgregarUsuarioScreenState();
}

class _AgregarUsuarioScreenState extends State<AgregarUsuarioScreen>
    with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String nombre = "";
  String nombreEncargado = "";
  int tipo = 2;
  String email = "";
  String telefono = "";
  String password = "";
  bool _passwordVisible = true;

  var textController1 = TextEditingController();
  var textController2 = TextEditingController();
  var textController3 = TextEditingController();
  var textController4 = TextEditingController();
  var textController5 = TextEditingController();

  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _telefonoFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nombreEncargadoFocus = FocusNode();

  // ignore: prefer_final_fields
  String? _rolSeleccionado = 'Stand';
  final List<String> _roles = ['Administrador', 'Stand', 'Premios'];

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo");
    _userapp = prefs.getString("nombre");
    return false;
  }

  final colors = <Color>[
    myColorBackground1,
    myColorBackground2,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    _passwordFocus.dispose();
    _nombreEncargadoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final idapp = args['idapp'];
    //  log(idapp);
    final Size size = MediaQuery.of(context).size;
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                UsuarioScreen.routeName,
                (Route<dynamic> route) => false,
                arguments: {
                  'idapp': args['idapp'].toString(),
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0.0, 1.3),
                  colors: colors,
                  tileMode: TileMode.repeated,
                ),
              ),
              child: RouteAwareWidget(
                screenName: "agregar_usuario",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "0", idapp: idapp ?? "0"),
                  appBar: AppBar(
                    title: const Text(nameAgregarUsuario),
                    elevation: 1,
                    shadowColor: myColor,
                    backgroundColor: Colors.white,
                    actions: const [],
                    iconTheme: const IconThemeData(color: myColor),
                    leading: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.home_outlined),
                          onPressed: () {
                            navigatorKey.currentState?.pushNamedAndRemoveUntil(
                              HomeScreen.routeName,
                              (Route<dynamic> route) => false,
                              arguments: {
                                'idapp': args['idapp'].toString(),
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    leadingWidth: size.width * 0.28,
                  ),
                  resizeToAvoidBottomInset: true,
                  body: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: const Alignment(0.0, 1.3),
                            colors: colors,
                            tileMode: TileMode.repeated,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10, left: 10, right: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ThemeData().colorScheme.copyWith(
                                  primary: myColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  controller: textController1,
                                  focusNode: _nombreFocus,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_nombreEncargadoFocus),
                                  keyboardType:TextInputType.name,
                                  cursorColor: myColor,
                                  onChanged: (valor) {
                                    setState(() {
                                      nombre = valor;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      hintText: "Nombre",
                                      hintStyle: TextStyle(fontSize: 14),
                                      labelText: "Nombre",
                                      labelStyle: TextStyle(color: Colors.black38),
                                      suffixIcon: Icon(
                                        Icons.label_outline,
                                        size: 30,
                                        color: myColor,
                                      ),
                                      icon: Icon(
                                        Icons.label,
                                        color: myColor,
                                      )),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ThemeData().colorScheme.copyWith(
                                  primary: myColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  controller: textController2,
                                  focusNode: _nombreEncargadoFocus,
                                  keyboardType:TextInputType.name,
                                  cursorColor: myColor,
                                  onChanged: (valor) {
                                    setState(() {
                                      nombreEncargado = valor;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      hintText: "Nombre del encargado",
                                      hintStyle: TextStyle(fontSize: 14),
                                      labelText: "Encargado",
                                      labelStyle: TextStyle(color: Colors.black38),
                                      suffixIcon: Icon(
                                        Icons.view_list_outlined,
                                        size: 30,
                                        color: myColor,
                                      ),
                                      icon: Icon(
                                        Icons.view_list,
                                        color: myColor,
                                      )),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: DropdownButtonFormField<String>(
                                value: _rolSeleccionado,
                                items: _roles.map((String rol) {
                                  return DropdownMenuItem<String>(
                                    value: rol,
                                    child: Text(rol),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _rolSeleccionado = newValue;
                                    if(_rolSeleccionado=="Administrador"){
                                      tipo=1;
                                    }else if(_rolSeleccionado=="Premios"){
                                      tipo=3;
                                    }else{
                                      tipo=2;
                                    }
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  labelText: 'Tipo de usuario',
                                  labelStyle: TextStyle(color: Colors.black38),
                                  icon: Icon(Icons.account_box_outlined, color: myColor),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ThemeData().colorScheme.copyWith(
                                  primary: myColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  controller: textController3,
                                  focusNode: _emailFocus,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_telefonoFocus),
                                  keyboardType:TextInputType.emailAddress,
                                  cursorColor: myColor,
                                  onChanged: (valor) {
                                    setState(() {
                                      email = valor;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      hintText: "Email del stand",
                                      hintStyle: TextStyle(fontSize: 14),
                                      labelText: "Email",
                                      labelStyle: TextStyle(color: Colors.black38),
                                      suffixIcon: Icon(
                                        Icons.email_outlined,
                                        size: 30,
                                        color: myColor,
                                      ),
                                      icon: Icon(
                                        Icons.email,
                                        color: myColor,
                                      )),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ThemeData().colorScheme.copyWith(
                                  primary: myColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  controller: textController4,
                                  focusNode: _telefonoFocus,
                                  maxLength: 10,
                                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                                  cursorColor: myColor,
                                  onChanged: (valor) {
                                    setState(() {
                                      telefono = valor;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      hintText: "Teléfono del stand",
                                      hintStyle: TextStyle(fontSize: 14),
                                      labelText: "Teléfono",
                                      labelStyle: TextStyle(color: Colors.black38),
                                      suffixIcon: Icon(
                                        Icons.phone_android_outlined,
                                        size: 30,
                                        color: myColor,
                                      ),
                                      icon: Icon(
                                        Icons.phone_android_rounded,
                                        color: myColor,
                                      )),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ThemeData().colorScheme.copyWith(
                                  primary: myColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: TextField(
                                  controller: textController5,
                                  focusNode: _passwordFocus,
                                  onSubmitted: (value) {
                                    if (nombre != "") {
                                      bool isValid = EmailValidator.validate(email);
                                      if (isValid) {
                                        if (password != "") {
                                          // log(nombre);
                                          // log(tipo.toString());
                                          // log(nombreEncargado);
                                          // log(email);
                                          // log(telefono);
                                          // log(password);
                                          showProgress(context, nombre, nombreEncargado, tipo.toString(), email, telefono, password);
                                        }else{
                                          awesomeTopSnackbar(
                                            context,
                                            "Debe ingresar Contraseña",
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
                                        }
                                      } else {
                                        awesomeTopSnackbar(
                                          context,
                                          "Debe ingresar un Email valido",
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
                                      }
                                    } else {
                                      awesomeTopSnackbar(
                                        context,
                                        "Debe ingresar Nombre",
                                        textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20),
                                        backgroundColor: Colors.orangeAccent,
                                        icon: const Icon(Icons.error,
                                            color: Colors.black),
                                        iconWithDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: Colors.black),
                                        ),
                                      );
                                    }
                                  },
                                  obscureText: _passwordVisible,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  cursorColor: myColor,
                                  onChanged: (valor) {
                                    setState(() {
                                      password = valor;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      hintText: "Contraseña del stand",
                                      labelText: "Contraseña",
                                      labelStyle:
                                  const TextStyle(color: myColor),
                                    suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible = !_passwordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 30,
                                          color: myColor,
                                        )),
                                      icon: const Icon(
                                        Icons.bookmark,
                                        color: myColor,
                                      )),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.020,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                  floatingActionButton: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                     showFab
                      ? FloatingActionButton(
                          heroTag: 'ok',
                          onPressed: () async {
                            if (nombre != "") {
                              bool isValid = EmailValidator.validate(email);
                              if (isValid) {
                                if (password != "") {
                                  // log(nombre);
                                  // log(tipo.toString());
                                  // log(nombreEncargado);
                                  // log(email);
                                  // log(telefono);
                                  // log(password);
                                  showProgress(context, nombre, nombreEncargado, tipo.toString(), email, telefono, password);
                                }else{
                                  awesomeTopSnackbar(
                                    context,
                                    "Debe ingresar Contraseña",
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
                                }
                              } else {
                                awesomeTopSnackbar(
                                  context,
                                  "Debe ingresar un Email valido",
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
                              }
                            } else {
                              awesomeTopSnackbar(
                                context,
                                "Debe ingresar Nombre",
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20),
                                backgroundColor: Colors.orangeAccent,
                                icon: const Icon(Icons.error,
                                    color: Colors.black),
                                iconWithDecoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.black),
                                ),
                              );
                            }
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 46, 46, 46),
                          child: const Icon(Icons.save,
                              color: Colors.white),
                        )
                      : const SizedBox(height: 0),
                   ]
                 ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  //showProgress
  showProgress(BuildContext context, String nombre, String nombreEncargado, String tipo, String email, String telefono, String password) async {
    var result = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(_check(nombre, nombreEncargado, tipo, email, telefono, password)),
    );

    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

  Future<String> _check(nombre, nombreEncargado, tipo, email, telefono, password) async {
    try {
      var data = {"nombre":nombre, "nombre_encargado":nombreEncargado, "tipo":tipo, "email":email, "telefono":telefono, "password":password};
      final response = await http.post(
          Uri(
            scheme: https,
            host: host,
            path: "/seg_usuario/add/",

            // scheme: https,
            // host: host,
            // path: '$path/seg_usuario/add/',
          ),
          body: data,
          // headers: <String, String>{
          //   'Content-Type': 'application/json; charset=UTF-8',
          //   'Access-Control-Allow-Origin': '*'
          // },
        );

        log('Código de estado: ${response.statusCode}');
        log('Respuesta cruda: ${response.body}');
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        log('Mensaje del servidor: ${jsonData['message']}');

      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['message'] == 'Agregado exitosamente') {
          return jsonData['message'];
        } else {
          return 'Ocurrio algo extraño, Vuelve a intentar';
        }
      } else {
        return 'Error, verificar conexión a Internet';
      }
    } catch (e, stackTrace) {
      log('Excepción atrapada: $e');
      log('StackTrace: $stackTrace');
      return 'Error, verificar conexión a Internet';
    }
  }

  Future<void> showResultDialog(BuildContext context, String result) async {
    if (result == 'Agregado exitosamente') {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        UsuarioScreen.routeName,
        (Route<dynamic> route) => false,
        arguments: {
          'idapp': args['idapp'].toString(),
        },
      );
      HapticFeedback.heavyImpact();
      awesomeTopSnackbar(
        context,
        "Agregado exitosamente",
        textStyle: const TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
            fontSize: 20),
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
    }else{
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        UsuarioScreen.routeName,
        (Route<dynamic> route) => false,
        arguments: {
          'idapp': args['idapp'].toString(),
        },
      );
      HapticFeedback.heavyImpact();
      awesomeTopSnackbar(
        context,
        result,
        textStyle: const TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
            fontSize: 20),
        backgroundColor: Colors.orangeAccent,
        icon: const Icon(Icons.error,
            color: Colors.black),
        iconWithDecoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(20),
          border:
              Border.all(color: Colors.black),
        ),
      );
    } 
  }

}