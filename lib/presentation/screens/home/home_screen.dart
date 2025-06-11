import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sephora/presentation/screens/info/info_screen.dart';
import 'package:sephora/presentation/screens/info/infodos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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

  Future<void> requestPermission() async {
    var status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      //print('Permiso otorgado');
    } else {
      //print('Permiso denegado');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              screenName: "home",
              child: Scaffold(
                  backgroundColor: Colors.white.withOpacity(1),
                  appBar: myAppBar(context, _userapp ?? "0", _idapp ?? "0", _tipoapp ?? "0"),
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
                                  height: 60,
                                  color: Colors.transparent,
                                ),
                                Image.asset(
                                  "assets/icon/logoSephora22.png",
                                  height: 120,
                                  width: 420,
                                ),
                                const Text("Web"),
                                const SizedBox(height: 100),
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
                                              // log(_currentIndex.toString());
                                              // log(value.toUpperCase());
                                              // log(_idapp!);
                                              showProgress(context, value.toUpperCase(), _idapp!);
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
                                const SizedBox(height: 280),
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
                /*
                bottomNavigationBar: Container(
                color: const Color.fromARGB(255, 46, 46, 46),
                padding: const EdgeInsets.symmetric(horizontal: 40),
                margin: const EdgeInsets.only(bottom: 0),
                child: GNav(
                  color: colors2[_currentIndex ?? 0],
                  tabBackgroundColor: Colors.black12,
                  selectedIndex: _currentIndex ?? 0,
                  tabBorderRadius: 10,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 30),
                  onTabChange: (index) => {
                    setState(() {
                      index == 0 ? currentIndex0() : currentIndex1();
                      _currentIndex = index;
                    }),
                  },
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: 'Entradas',
                      iconActiveColor: Colors.greenAccent,
                      textColor: Colors.greenAccent,
                    ),
                    GButton(
                      icon: Icons.exit_to_app_outlined,
                      text: 'Salidas',
                      iconActiveColor: Colors.yellow,
                      textColor: Colors.yellow,
                    ),
                  ],
                ),
                 ),*/
                 floatingActionButtonLocation:
                   FloatingActionButtonLocation.centerFloat,
                 floatingActionButton:
                   Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                     showFab
                        ? 
                        Column(
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

                                      // navigatorKey.currentState?.pushNamedAndRemoveUntil(
                                      //   ScannerScreen.routeName,
                                      //   (Route<dynamic> route) => false,
                                      //   arguments: {
                                      //     'idapp': _idapp,
                                      //   },
                                      // );

                                      final result = await Navigator.of(context).push<String>(
                                        MaterialPageRoute(
                                          builder: (context) => AiBarcodeScanner(
                                            onDispose: () {
                                              //log("Barcode scanner disposed!");
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
                                          showProgress(context, result, _idapp!);
                                        });
                                      }
                                    },
                                    elevation: 0,
                                    backgroundColor: Colors.transparent, // Ya tienes fondo por el container
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        /*FloatingActionButton(
                            heroTag: 'ok',
                            onPressed: () async {
                              final result = await Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => AiBarcodeScanner(
                                  onDispose: () {
                                    //log("Barcode scanner disposed!");
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
                                    // log("Index: $_currentIndex");
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

                                if (_currentIndex == 0) {
                                  showProgress(context, result, _idapp!);
                                } else {
                                  showProgress2(context, result, _idapp!);
                                }
                              });

                            }
                            },
                            backgroundColor:
                                const Color.fromARGB(255, 46, 46, 46),
                            child: Icon(Icons.qr_code_2_outlined,
                                color: _currentIndex == 1
                                    ? Colors.yellow
                                    : Colors.greenAccent),
                          )*/
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

  Future<void> scannerON() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ScannerON', true);
  }

  Future<void> scannerOFF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('ScannerON', false).then((_) => setState(() {}));
    await prefs.setBool('ScannerON', false);
  }

  //showProgress
  showProgress(BuildContext context, String codigo, String usuario) async {
    var result = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(_check(codigo, usuario)),
    );

    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

  Future<String> _check(codigo, usuario) async {
    try {
      final response = await http.post(
          Uri(
            scheme: https,
            host: host,
            path: "/registro/addCheck/$codigo/$usuario",

            // scheme: https,
            // host: host,
            // path: '$path/registro/addCheck/$codigo/$usuario',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Access-Control-Allow-Origin': '*'
          });
      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['message'] != '') {
          return jsonData['message'];
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
    if (splitted[0] == 'Bienvenido(a) a' || splitted[0] == 'Gracias por visitar') {
      HapticFeedback.heavyImpact();
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => Info(text: '${splitted[0]},${splitted[1]}', idapp: _idapp),
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
          pageBuilder: (_, __, ___) => InfoDos(text: result, idapp: _idapp),
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

  /*
  //showProgress2
  showProgress2(BuildContext context, String codigo, String usuario) async {
    var result = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(_check2(codigo, usuario)),
    );

    // ignore: use_build_context_synchronously
    showResultDialog2(context, result);
  }

  Future<String> _check2(codigo, usuario) async {
    try {
      final response = await http.post(
          Uri(
            // scheme: https,
            // host: host,
            // path: "/registro/checkout/$codigo/$usuario",

            scheme: https,
            host: host,
            path: '$path/registro/addCheck/$codigo/$usuario',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Access-Control-Allow-Origin': '*'
          });
      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['message'] != '') {
          return jsonData['message'];
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

  Future<void> showResultDialog2(BuildContext context, String result) async {
    var splitted = result.split(',');
    if (splitted[0] == 'Gracias por visitar') {
      HapticFeedback.heavyImpact();
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => Info(text: splitted[0]+splitted[1]),
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
          pageBuilder: (_, __, ___) => InfoDos(text: result),
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
  */
}