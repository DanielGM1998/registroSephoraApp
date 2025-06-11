import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/info/info_screen.dart';
import 'package:sephora/presentation/screens/info/infodos_screen.dart';
import '../../../constants/constants.dart';
import 'package:http/http.dart' as http;

import '../home/home_screen.dart';

class ScannerScreen extends StatefulWidget {
  static const String routeName = 'scanner';

  const ScannerScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isProcessing = false;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  late String idapp; // Variable para guardar el argumento

  Future<bool?> getVariables() async {
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      idapp = args['idapp'].toString();
    } else {
      idapp = ''; // fallback si no llegan argumentos
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  // Descomenta si quieres controlar ciclo de vida
  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  // @override
  // void deactivate() {
  //   _controller.stop();
  //   super.deactivate();
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) {
                return;
              }
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                HomeScreen.routeName,
                (Route<dynamic> route) => false,
                arguments: {
                  'idapp': idapp,
                },
              );
            },
            child: RouteAwareWidget(
              screenName: "scanner",
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.white.withOpacity(1),
                resizeToAvoidBottomInset: false,
                body: AiBarcodeScanner(
                  onDispose: () {
                    //log("Barcode scanner disposed!");
                  },
                  hideGalleryButton: true,
                  hideSheetTitle: true,
                  sheetTitle: "¡Listo, Escanea QR!",
                  hideSheetDragHandler: true,
                  controller: _controller,
                  onDetect: (BarcodeCapture capture) async {
                    final String? scannedValue =
                        capture.barcodes.first.rawValue;

                    if (_isProcessing ||
                        scannedValue == null ||
                        scannedValue.isEmpty) return;

                    _isProcessing = true;
                    _controller.stop(); // detener escáner antes de navegar

                    log("Escaneado: $scannedValue");
                    await showProgress(context, scannedValue, idapp);

                    // Reactivar escaneo si aún estamos en pantalla Scanner
                    if (mounted) {
                      await _controller.start();
                      _isProcessing = false;
                    }
                  },
                  validator: (value) {
                    if (value.barcodes.isEmpty) {
                      return false;
                    }
                    if (!(value.barcodes.first.rawValue
                            ?.contains('flutter.dev') ??
                        false)) {
                      return false;
                    }
                    return true;
                  },
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
  showProgress(BuildContext context, String codigo, String usuario) async {
    var result = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(_check(codigo, usuario)),
    );

    if (result != null) {
      // ignore: use_build_context_synchronously
      await showResultDialog(context, result);
    }
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
          return 'Ocurrió algo extraño, vuelve a intentar';
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
          pageBuilder: (_, __, ___) =>
              Info(text: '${splitted[0]},${splitted[1]}', idapp: idapp),
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
    } else {
      HapticFeedback.heavyImpact();
      Navigator.of(context).push(
        PageRouteBuilder(
          barrierColor: Colors.black.withOpacity(0.6),
          opaque: false,
          pageBuilder: (_, __, ___) => InfoDos(text: result, idapp: idapp),
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
