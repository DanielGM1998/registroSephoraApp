import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/usuario/add_usuario_screen.dart';
import 'package:sephora/presentation/screens/usuario/edit_usuario_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/side_menu.dart';
import '../home/home_screen.dart';

class UsuarioScreen extends StatefulWidget {
  static const String routeName = 'usuario';

  const UsuarioScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen>
    with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> filteredItems = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  Future<bool?> getVariables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tipoapp = prefs.getString("tipo");
    _userapp = prefs.getString("nombre");
    return false;
  }

  bool isFirstLoadRunning = false;
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;
  int page = 1;
  final int limit = 50;
  List items = [];
  late ScrollController controller;

  final colors = <Color>[
    myColorBackground1,
    myColorBackground2,
  ];

  void fistLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      final response = await http.get(
        Uri(
          scheme: https,
          host: host,
          path: '/seg_usuario/getAll/',

          // scheme: https,
          // host: host,
          // path: '$path/seg_usuario/getAll/',
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          items = jsonResponse['result'];
          filteredItems = List.from(items); // Inicializa la lista filtrada
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

    if (!mounted) return;

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredItems = List.from(items); // Restaura la lista original
      }
    });
  }

  String removeDiacritics(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  void filterItems(String query) {
    final normalizedQuery = removeDiacritics(query);
    setState(() {
      if (query.isEmpty) {
        filteredItems = List.from(items);
      } else {
        filteredItems = items.where((item) {
          final nombre = removeDiacritics(item['nombre'] ?? '');
          final nombreEncargado =
              removeDiacritics(item['nombre_encargado'] ?? '');
          return nombre.contains(normalizedQuery) ||
              nombreEncargado.contains(normalizedQuery);
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fistLoad();
    controller = ScrollController()..addListener(loadMore);
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
                HomeScreen.routeName,
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
                screenName: "usuario",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "0", idapp: idapp ?? "0"),
                  appBar: AppBar(
                    title: isSearching
                        ? TextField(
                            controller: searchController,
                            autofocus: true,
                            onChanged: filterItems,
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Buscar Nombre",
                              hintStyle: TextStyle(color: Colors.black),
                              border: InputBorder.none,
                            ),
                          )
                        : const Text(nameUsuario),
                    elevation: 1,
                    shadowColor: myColor,
                    backgroundColor: Colors.white,
                    actions: [
                      isSearching
                      ? const Text("")
                      : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: (){
                          fistLoad();
                        },
                      ),
                      IconButton(
                        icon: Icon(isSearching ? Icons.close : Icons.search),
                        onPressed: toggleSearch,
                      ),
                    ],
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
                  resizeToAvoidBottomInset: false,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0.0),
                        child: CustomRefreshIndicator(
                          // ignore: implicit_call_tearoffs
                          builder: MaterialIndicatorDelegate(
                            builder: (context, controller) {
                              return Icon(
                                Icons.refresh_outlined,
                                color: myColor,
                                size: size.width * 0.1,
                              );
                            },
                          ),
                          onRefresh: () async {
                            isFirstLoadRunning = false;
                            hasNextPage = true;
                            isLoadMoreRunning = false;
                            items = [];
                            page = 1;
                            fistLoad();
                            controller = ScrollController()..addListener(loadMore);
                            return setState(() {});
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isFirstLoadRunning)
                                const Center(
                                  child: CircularProgressIndicator(color: myColor),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    controller: controller,
                                    itemCount: filteredItems.length +
                                        (isLoadMoreRunning ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == items.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                                color: myColor),
                                          ),
                                        );
                                      }
                
                                      final item = filteredItems[index];
                                      return InkWell(
                                        onTap: (){
                                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                                            EditarUsuarioScreen.routeName,
                                            (Route<dynamic> route) => false,
                                            arguments: {
                                              'idapp': idapp,
                                              'id': item['id'],
                                              'nombre': item['nombre'],
                                              'nombre_encargado': item['nombre_encargado'],
                                              'tipo': item['tipo'],
                                              'email': item['email'],
                                              'telefono': item['telefono'],
                                            },
                                          );
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          elevation: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: item['tipo'] ==  "1"
                                                  ? Colors.greenAccent
                                                  : item['tipo'] ==  "2"
                                                    ? Colors.orangeAccent
                                                    : Colors.pinkAccent,
                                                  radius: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.06,
                                                  child: const Icon(Icons.person,
                                                      color: Colors.white),
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.04),
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              item['nombre'],
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                              overflow: TextOverflow.ellipsis, 
                                                              maxLines: 1,
                                                            ),
                                                            Text(
                                                              item['nombre_encargado'] ?? "",
                                                              style: const TextStyle(
                                                                  fontSize: 16),
                                                              overflow: TextOverflow.ellipsis, 
                                                              maxLines: 1,
                                                            ),
                                                            Text(
                                                              item['tipo'] ==  "1"
                                                                  ? "Administrador"
                                                                  : item['tipo'] ==  "2"
                                                                  ? "Stand"
                                                                  : "Premios",
                                                              style: const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12),
                                                              overflow: TextOverflow.ellipsis, 
                                                              maxLines: 1,
                                                            ),
                                                            Text(
                                                              item['email'],
                                                              style: const TextStyle(
                                                                  fontSize: 12),
                                                              overflow: TextOverflow.ellipsis, 
                                                              maxLines: 1,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Padding(
                                                          padding: EdgeInsets.only(right: size.width * 0.01),
                                                          child: const Icon(
                                                            Icons.edit,
                                                            size: 24,
                                                            color: Colors.black54
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 40)
                            ],
                          ),
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
                              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                                AgregarUsuarioScreen.routeName,
                                (Route<dynamic> route) => false,
                                arguments: {
                                  'idapp': args['idapp'].toString(),
                                },
                              );
                            },
                            backgroundColor:const Color.fromARGB(255, 46, 46, 46),
                            child: const Icon(Icons.group_add,
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

  Future<void> showResultDialog(BuildContext context, String result) async {  
    if (result == 'Error, verificar conexión a Internet') {
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
                    Icons.error,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result,
                    style: const TextStyle(
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
    }else if (result == 'No hay entrada registrada') {
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
                  Icons.error,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result,
                  style: const TextStyle(
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
    } else {
      HapticFeedback.heavyImpact();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result,
                  style: const TextStyle(
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
          backgroundColor: Colors.green,
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

  // Salida
  Future<String> _salida(idUsuario, proveedorId, notasVigilancia) async {
    try {

      var data = {
        "idUsuario": idUsuario, 
        "proveedor_id": proveedorId,
        "notas_salida": notasVigilancia, 
      };

      final response = await http.post(Uri(
        scheme: https,
        host: host,
        path: '/proveedor/app/editSalidaBitacora/',

        // scheme: https,
        // host: host,
        // path: '$path/proveedor/app/editSalidaBitacora/',
      ), 
      body: data
      );

      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        if (jsonData['response'] == true) {
          return 'Salida registrada exitosamente';
        } else if(jsonData['message'] == "No hay entrada registrada"){
          return "No hay entrada registrada";
        } else {
          return 'Error, verificar conexión a Internet';
        }
      } else {
        return 'Error, verificar conexión a Internet';
      }
    } catch (e) {
      return 'Error, verificar conexión a Internet';
    }
  }

  showProgressSalida(BuildContext context, String idUsuario, String proveedorId, String notasVigilancia, List<String> imagePaths) async {

    EasyLoading.show(
      status: 'Guardando...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.clear,
    );

    var result = await _salida(idUsuario, proveedorId, notasVigilancia);
    log(result);

    EasyLoading.dismiss();
    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

}