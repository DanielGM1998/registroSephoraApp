import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sephora/presentation/screens/consulta_qr/resultado_consulta_qr_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/constants/constants.dart';

import '../../widgets/my_app_bar.dart';
import '../../widgets/side_menu.dart';

class ConsultaQrScreen extends StatefulWidget {
  static const String routeName = 'consulta';

  const ConsultaQrScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ConsultaQrScreen> createState() => _ConsultaQrScreenState();
}

class _ConsultaQrScreenState extends State<ConsultaQrScreen> with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
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
              screenName: "consulta",
              child: Scaffold(
                  backgroundColor: Colors.white.withOpacity(1),
                  appBar: myAppBar(context, nameConsulta, _idapp ?? "0", _tipoapp ?? "0"),
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
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                barrierColor: Colors.black.withOpacity(0.6),
                                                opaque: false,
                                                pageBuilder: (_, __, ___) => ResultadoConsultaQrScreen(codigo: value.toUpperCase(), idapp: _idapp),
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
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              barrierColor: Colors.black.withOpacity(0.6),
                                              opaque: false,
                                              pageBuilder: (_, __, ___) => ResultadoConsultaQrScreen(codigo: result, idapp: _idapp),
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
                                        });
                                      }
                                    },
                                    elevation: 0,
                                    backgroundColor: Colors.transparent, 
                                    child: const Icon(
                                      Icons.qr_code_scanner,
                                      color: Colors.blueAccent,
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
}