import 'dart:async';
import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/consulta_qr/consulta_qr_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/side_menu.dart';
import '../home/home_screen.dart';

class ResultadoConsultaQrScreen extends StatefulWidget {
  static const String routeName = 'resultado_consulta';

  const ResultadoConsultaQrScreen({
    Key? key, this.codigo, this.idapp,
  }) : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final codigo;

  // ignore: prefer_typing_uninitialized_variables
  final idapp;

  @override
  State<ResultadoConsultaQrScreen> createState() => _ResultadoConsultaQrScreenState();
}

class _ResultadoConsultaQrScreenState extends State<ResultadoConsultaQrScreen>
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
          // ignore: prefer_interpolation_to_compose_strings
          path: '/registro/getAllByCodigo/'+widget.codigo,

          // scheme: https,
          // host: host,
          // path: '$path/registro/getAllByCodigo/'+widget.codigo,
        ),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final bool respuesta = jsonResponse['response'];
        if(respuesta){
          setState(() {
            items = jsonResponse['result'];
            filteredItems = List.from(items); // Inicializa la lista filtrada
          });
        }
        
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
          final fechaEntrada =
              removeDiacritics(item['fecha_entrada'] ?? '');
          return nombre.contains(normalizedQuery) ||
              fechaEntrada.contains(normalizedQuery);
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
    final Size size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: getVariables(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) { return; }
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                ConsultaQrScreen.routeName,
                (Route<dynamic> route) => false,
                arguments: {
                  'idapp': widget.idapp,
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
                screenName: "resultado_consulta",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "0", idapp: widget.idapp ?? "0"),
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
                        : const Text(nameConsulta),
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
                                'idapp': widget.idapp,
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
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        elevation: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: item['fecha_salida'] !=  null
                                                ? Colors.black
                                                :  Colors.redAccent,
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
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: item['fecha_salida'] !=  null
                                                                ? Colors.black
                                                                :  Colors.redAccent,
                                                            ),
                                                            overflow: TextOverflow.ellipsis, 
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            // ignore: prefer_interpolation_to_compose_strings
                                                            "Entrada: "+item['fecha_entrada'],
                                                            style: const TextStyle(
                                                                fontSize: 16),
                                                            overflow: TextOverflow.ellipsis, 
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                          item['fecha_salida'] != null
                                                            // ignore: prefer_interpolation_to_compose_strings
                                                            ? "Salida: "+item['fecha_salida']
                                                            : "",
                                                            style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12),
                                                            overflow: TextOverflow.ellipsis, 
                                                            maxLines: 1,
                                                          ),
                                                          Text(
                                                            item['tiempo_evento']=="00:00:00"
                                                              ? ""
                                                              : item['tiempo_evento'],
                                                            style: const TextStyle(
                                                                fontSize: 12),
                                                            overflow: TextOverflow.ellipsis, 
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}