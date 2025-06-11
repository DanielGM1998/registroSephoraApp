import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/info/info_cuatro.dart';
import 'package:sephora/presentation/screens/info/infotres_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class PremioScreen extends StatefulWidget {
  static const String routeName = 'premio';

  const PremioScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PremioScreen> createState() => _PremioScreenState();
}

class _PremioScreenState extends State<PremioScreen> with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;
  String? _idapp;

  var textController = TextEditingController();

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    _tipoapp = prefs.getString("tipo");
    _userapp = prefs.getString("nombre");
    _idapp = prefs.getString("id");
    return false;
  }

  final colors = <Color>[
    myColorBackground1,
    myColorBackground2,
  ];

  String now = "${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -7)))} a ${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
  String inicio = "null", fin = "null";
  int totalPremios = 0;

  void fistLoad() async {
    try {
      final http.Response response;
      if(inicio == "null" && fin == "null"){
        inicio = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -7)));
        fin = DateFormat('yyyy-MM-dd').format(DateTime.now());
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            path: '/registro/estadisticas/2/$inicio/$fin',

            // scheme: https,
            // host: host,
            // path: '$path/registro/estadisticas/2/$inicio/$fin',
          ),
        );
      }else if(inicio == "null"){
        inicio = fin;
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            path: '/registro/estadisticas/2/$inicio/$fin',

            // scheme: https,
            // host: host,
            // path: '$path/registro/estadisticas/2/$inicio/$fin',
          ),
        );
      }else if(fin == "null"){
        fin = inicio;
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            path: '/registro/estadisticas/2/$inicio/$fin',

            // scheme: https,
            // host: host,
            // path: '$path/registro/estadisticas/2/$inicio/$fin',
          ),
        );
      }else{
        response = await http.get(
          Uri(
            scheme: https,
            host: host,
            path: '/registro/estadisticas/2/$inicio/$fin',

            // scheme: https,
            // host: host,
            // path: '$path/registro/estadisticas/2/$inicio/$fin',
          ),
        );
      }
      //log('/solicitud/app/getAll/'+inicio+'/'+fin);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          totalPremios = jsonResponse['message'];
        });
      } else {
        if (kDebugMode) {
          print("Error en la respuesta: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar datos');
      }
      HapticFeedback.heavyImpact();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Error, verificar conexión a Internet",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fistLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // final idapp = args['idapp'];
    //  log(idapp);
    final Size size = MediaQuery.of(context).size;
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    //  log("Pantalla actual: $currentScreen");
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              bool value = await _onWillPop();
              if (value) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(value);
              }
            },
            child: RouteAwareWidget(
              screenName: "premio",
              child: Scaffold(
                  backgroundColor: Colors.white.withOpacity(1),
                  appBar: myAppBar(context, namePremio, _idapp ?? "0", _tipoapp ?? "0"),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "0", idapp: _idapp ?? "0"),
                  resizeToAvoidBottomInset: false,
                  body: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0.0, 1.3),
                        colors: colors,
                        tileMode: TileMode.repeated,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: size.width*0.02),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  color: Colors.transparent,
                                ),
                                Image.asset(
                                  "assets/icon/logoSephora22.png",
                                  height: 120,
                                  width: 420,
                                ),
                                const Text("Web"),
                                const SizedBox(height: 50),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.7,
                                      child: TextField(
                                        controller: textController,
                                        onSubmitted: (value) async {
                                          if (value.toUpperCase() == "") {
                                          } else {
                                            showProgress(context, value.toUpperCase());
                                            setState(() {
                                              textController.clear();
                                            });
                                          }
                                        },
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            hintText: "Folio",
                                            labelText: "Folio",
                                            suffixIcon: Icon(
                                              Icons.person,
                                              size: 40,
                                            ),
                                            icon: Icon(
                                              Icons.account_circle,
                                            )),
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 100),
                                Column(
                                  children: [
                                    Card(
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Total Premios entregados: $totalPremios'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 240),
                                Container(
                                  height: 100,
                                  color: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                          ),
                        ],
                      ),
                    )
                  ),
                 floatingActionButtonLocation:
                   FloatingActionButtonLocation.centerFloat,
                 floatingActionButton:
                   Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                     showFab
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Presiona para escanear",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  gradient: const LinearGradient(
                                    colors: [Colors.black87, Colors.black54],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: FloatingActionButton(
                                    heroTag: 'ok',
                                    onPressed: () async {
                                      final result = await Navigator.of(context).push<String>(
                                        MaterialPageRoute(
                                          builder: (context) => AiBarcodeScanner(
                                            onDispose: () {
                                              log("Barcode scanner disposed!");
                                            },
                                            hideGalleryButton: true,
                                            hideSheetTitle: true,
                                            sheetTitle: "¡Listo, Escanea QR!",
                                            hideSheetDragHandler: true,
                                            controller: MobileScannerController(
                                              detectionSpeed: DetectionSpeed.noDuplicates,
                                            ),
                                            onDetect: (BarcodeCapture capture) {
                                              final String? scannedValue = capture.barcodes.first.rawValue;
                                              // log("Escaneado: $scannedValue");
                                              // log("Usuario: $_idapp");
                                              if (scannedValue != null && scannedValue.isNotEmpty) {
                                                Navigator.pop(context, scannedValue);
                                              }
                                            },
                                            validator: (value) {
                                              if (value.barcodes.isEmpty) {
                                                return false;
                                              }
                                              if (!(value.barcodes.first.rawValue?.contains('flutter.dev') ?? false)) {
                                                return false;
                                              }
                                              return true;
                                            },
                                          ),
                                        ),
                                      );

                                      if (mounted && result != null) {
                                        setState(() {
                                          textController.clear();
                                          showProgress(context, result);
                                        });

                                      }
                                    },
                                    elevation: 0,
                                    backgroundColor: Colors.transparent, // Ya tienes fondo por el container
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.pinkAccent,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(height: 0),
                   ]
                 )
                ),
            ),
          );
        } else if (snapshot.data == true) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const SizedBox(height: 0, width: 0);
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const SizedBox(height: 0, width: 0);
      },
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cerrar aplicación'),
            content: const Text('¿Deseas salir de la aplicación?'),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Si'),
              ),
            ],
          ),
        )) ??
        false;
  }

  //showProgress
  showProgress(BuildContext context, String codigo) async {
    var result = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(_check(codigo)),
    );

    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

  Future<String> _check(codigo) async {
    try {
      final response = await http.get(
          Uri(
            scheme: https,
            host: host,
            path: "/registro/getPremio/$codigo",

            // scheme: https,
            // host: host,
            // path: '$path/registro/getPremio/$codigo',
          ),
          // headers: <String, String>{
          //   'Content-Type': 'application/json; charset=UTF-8',
          //   'Access-Control-Allow-Origin': '*'
          // },
        );

        // log('Código de estado: ${response.statusCode}');
        // log('Respuesta cruda: ${response.body}');
        // String body3 = utf8.decode(response.bodyBytes);
        // var jsonData = jsonDecode(body3);
        // log('Mensaje del servidor: ${jsonData['message']}');

      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['response'] == true) {
          //int res = int.parse(jsonData['result']);
          int res = jsonData['result'];
          String mes = '';
          mes = 'Felicidades has ganado un premio';
          return "$mes, $res";
        } else {
          if(jsonData['message'] == 'No has alcanzado las condiciones necesarias para el premio'){
            int res = jsonData['result'];
            String mes = '';
            mes = 'No has alcanzado las condiciones necesarias para el premio';
            return "$mes, $res";
          }
          return jsonData['message'].toString();
        }
      } else {
        return 'Error, verificar conexión a Internet1';
      }
    } catch (e) {
      return 'Error, verificar conexión a Internet2';
    }
  }

  Future<void> showResultDialog(BuildContext context, String result) async {
    var splitted = result.split(',');
    //log(result);
    if (splitted[0] == 'Felicidades has ganado un premio') {
      HapticFeedback.heavyImpact();
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => InfoTres(text: 'Felicidades has ganado un premio\n\nVisitas: ${splitted[1]}', idapp: _idapp),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * animation.value,
                sigmaY: 10 * animation.value,
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    }else if (splitted[0] == 'No has alcanzado las condiciones necesarias para el premio') {
      HapticFeedback.heavyImpact();
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => InfoCuatro(text: '${splitted[0]}.\n\nVisitas: ${splitted[1]}', idapp: _idapp),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * animation.value,
                sigmaY: 10 * animation.value,
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    }else{
      HapticFeedback.heavyImpact();
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => InfoCuatro(text: result, idapp: _idapp),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10 * animation.value,
                sigmaY: 10 * animation.value,
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    } 
  }
}