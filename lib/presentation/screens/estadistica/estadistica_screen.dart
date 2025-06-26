import 'dart:async';
import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/widgets/bar_graph.dart';
import 'package:sephora/presentation/widgets/table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/constants.dart';
import 'package:http/http.dart' as http;

import '../../widgets/side_menu.dart';
import '../home/home_screen.dart';

class EstadisticaScreen extends StatefulWidget {
  static const String routeName = 'estadistica';

  const EstadisticaScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EstadisticaScreen> createState() => _EstadisticaScreenState();
}

class _EstadisticaScreenState extends State<EstadisticaScreen>
    with SingleTickerProviderStateMixin {
  String? _tipoapp;
  String? _userapp;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> filteredItems = [];

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
  int totalPremios = 0;
  int totalBrazaletes = 0;

  final colors = <Color>[
    myColorBackground1,
    myColorBackground2,
  ];

  List<DateTime?> _dialogCalendarPickerValue = [
    DateTime.now().add(const Duration(days: -7)),
    DateTime.now(),
  ];

  String now = "${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: -7)))} a ${DateFormat('yyyy-MM-dd').format(DateTime.now())}";

  String inicio = "null", fin = "null";

  void fistLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
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
          items = jsonResponse['result'];
          totalPremios = jsonResponse['message'];
          totalBrazaletes = jsonResponse['totalBrazaletes'];
          filteredItems = List.from(items);
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
                screenName: "estadistica",
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white.withOpacity(1),
                  drawer: SideMenu(userapp: _userapp ?? "0", tipoapp: _tipoapp ?? "0", idapp: idapp ?? "0"),
                  appBar: AppBar(
                    title: const Text(nameEstadistica),
                    elevation: 1,
                    shadowColor: myColor,
                    backgroundColor: Colors.white,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: (){
                          fistLoad();
                        },
                      ),
                      PopupMenuButton(
                        color: Colors.white,
                        icon: const Icon(Icons.more_vert_outlined, color: myColor),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: [
                                  const Icon(Icons.remove_red_eye_outlined),
                                  SizedBox(width: size.width * 0.03),
                                  const Text("Descargar Reporte Visitas", style: TextStyle(color: myColor)),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                children: [
                                  const Icon(Icons.timer_outlined),
                                  SizedBox(width: size.width * 0.03),
                                  const Text("Descargar Reporte Tiempos", style: TextStyle(color: myColor)),
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_forever),
                                  SizedBox(width: size.width * 0.03),
                                  const Text("Eliminar registros sin Salida", style: TextStyle(color: myColor)),
                                ],
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          if (value == 1) {
                            onWillPop1();
                          }else if (value == 2) {
                            onWillPop2();
                          }else if (value == 3) {
                            onWillPop3();
                          }
                        },
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
                            children: [
                              if (!isFirstLoadRunning)
                                const SizedBox(height: 10),

                              if (!isFirstLoadRunning)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.05), 
                                    borderRadius: BorderRadius.circular(20), 
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _datePicker();
                                    },
                                    icon: Row(
                                      mainAxisSize: MainAxisSize.min, 
                                      children: [
                                        const Icon(Icons.date_range_outlined),
                                        const SizedBox(width: 2), 
                                        Text(now),
                                      ],
                                    ),
                                  ),
                                ),

                              if (!isFirstLoadRunning)
                                const SizedBox(height: 10),

                              if (!isFirstLoadRunning)
                                GraficaDeBarras(filteredItems: filteredItems),                              

                              if (!isFirstLoadRunning)
                                const SizedBox(height: 35),
                              
                              if (!isFirstLoadRunning)
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
                                    const SizedBox(height: 10)
                                  ],
                                ),

                              if (!isFirstLoadRunning)
                                Column(
                                  children: [
                                    Card(
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Brazaletes en Sistema: $totalBrazaletes'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10)
                                  ],
                                ),

                              if (isFirstLoadRunning)
                                const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(color: myColor),
                                  ),
                                )

                              else
                                Expanded(child: SingleChildScrollView(child: TablaDeVisitas(filteredItems: filteredItems))),

                                /* // mosaico de card doble
                                Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(8),
                                    controller: controller,
                                    itemCount: filteredItems.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 1.1,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final int general = int.tryParse('${item['visita_general']}') ?? 0;
                                      final int demo = int.tryParse('${item['visita_demo']}') ?? 0;
                                      final int total = general + demo;
                                      return Card(
                                        elevation: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(item['nombre']+"\n"+item['nombre_encargado'], 
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis, 
                                                maxLines: 2,
                                              ),
                                              Text('Total Visitas: $total', style: const TextStyle(fontSize: 12)),
                                              Text('General: $general', style: const TextStyle(fontSize: 12)),
                                              Text('Demo: $demo', style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                */
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

  Future<bool> onWillPop1() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Descargar')),
        content: const Text('¿Deseas descargar Reporte de Visitas?', textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              _getExcel(inicio, fin);
            },
            child: const Text('Si'),
          ),
        ],
      ),
    )) ??
    false;
  }

  Future<bool> onWillPop2() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Descargar')),
        content: const Text('¿Deseas descargar Reporte de Tiempos?', textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              _getExcel2(inicio, fin);
            },
            child: const Text('Si'),
          ),
        ],
      ),
    )) ??
    false;
  }

  Future<bool> onWillPop3() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Eliminar')),
        content: const Text('¿Deseas eliminar registros Sin Salida?', textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              showProgress(context);
            },
            child: const Text('Si'),
          ),
        ],
      ),
    )) ??
    false;
  }

  Future<String> _getExcel(fechaInicio, fechaFin) async {
    var url = "$https://$host$path/registro/getExcel/$fechaInicio/$fechaFin";
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    return '';
  }

  Future<String> _getExcel2(fechaInicio, fechaFin) async {
    var url = "$https://$host$path/registro/getExcel2/$fechaInicio/$fechaFin";
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
    return '';
  }

  //showProgress
  showProgress(context) async {
    var result = await showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(_deleteRegistrosSinSalida()),
    );

    // ignore: use_build_context_synchronously
    showResultDialog(context, result);
  }

  Future<String> _deleteRegistrosSinSalida() async {
    try {
      final response = await http.post(
          Uri(
            scheme: https,
            host: host,
            path: "/registro/deleteRegistrosSinSalida/",
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Access-Control-Allow-Origin': '*'
          });
      if (response.statusCode == 200) {
        String body3 = utf8.decode(response.bodyBytes);
        var jsonData = jsonDecode(body3);
        return jsonData['message'];
      } else {
        return 'Error, verificar conexión a Internet';
      }
    } catch (e) {
      return 'Error, verificar conexión a Internet';
    }
  }

  Future<void> showResultDialog(context, String result) async {
    if (result == 'Error, verificar conexión a Internet' || result == 'Ocurrio algo extraño, Vuelve a intentar' || result == 'No hay registros') {
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
              Expanded(
                child: Text(result,
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
    }else{
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
      isFirstLoadRunning = false;
      hasNextPage = true;
      isLoadMoreRunning = false;
      items = [];
      page = 1;
      fistLoad();
      controller = ScrollController()..addListener(loadMore);
      return setState(() {});
    } 
  }

  _datePicker() async {
    const dayTextStyle =
        TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
    const weekendTextStyle =
        TextStyle(color: Colors.black, fontWeight: FontWeight.w700);
    final anniversaryTextStyle = TextStyle(
      color: Colors.red[400],
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    final config = CalendarDatePicker2WithActionButtonsConfig(
      dayTextStyle: dayTextStyle,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: Colors.orangeAccent,
      closeDialogOnCancelTapped: true,
      firstDayOfWeek: 1,
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.orangeAccent,
        fontWeight: FontWeight.bold,
      ),
      controlsTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
      selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
      dayTextStylePredicate: ({required date}) {
        TextStyle? textStyle;
        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          textStyle = weekendTextStyle;
        }
        if (DateUtils.isSameDay(date, DateTime(2021, 1, 25))) {
          textStyle = anniversaryTextStyle;
        }
        return textStyle;
      },
      dayBuilder: ({
        required date,
        textStyle,
        decoration,
        isSelected,
        isDisabled,
        isToday,
      }) {
        Widget? dayWidget;
        if (date.day % 3 == 0 && date.day % 9 != 0) {
          dayWidget = Container(
            decoration: decoration,
            child: Center(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Text(
                    MaterialLocalizations.of(context).formatDecimal(date.day),
                    style: textStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 27.5),
                    child: Container(
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isSelected == true
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return dayWidget;
      },
      yearBuilder: ({
        required year,
        decoration,
        isCurrentYear,
        isDisabled,
        isSelected,
        textStyle,
      }) {
        return Center(
          child: Container(
            decoration: decoration,
            height: 36,
            width: 72,
            child: Center(
              child: Semantics(
                selected: isSelected,
                button: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      year.toString(),
                      style: textStyle,
                    ),
                    if (isCurrentYear == true)
                      Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(left: 5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(15),
      value: _dialogCalendarPickerValue,
      dialogBackgroundColor: Colors.white,
    );
    if (values != null) {
      //log(_getValueText(config.calendarType, values));
      //log(_getValueText2(config.calendarType, values));
      inicio = _getValueText(config.calendarType, values);
      fin = _getValueText2(config.calendarType, values);
      setState(() {
        if(inicio == "null" && fin == "null"){
          now = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }else if(inicio == "null"){
          now = fin;
        }else if(fin == "null"){
          now = inicio;
        }else{
          now = "${inicio}al $fin";
        }
        _dialogCalendarPickerValue = values;
        //_getExcel(inicio, fin);
      });
      fistLoad();
    }
  }

  String _getValueText(
    CalendarDatePicker2Type datePickerType,
    List<DateTime?> values,
  ) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        // final endDate = values.length > 1
        //     ? values[1].toString().replaceAll('00:00:00.000', '')
        //     : 'null';
        // valueText = '$startDate to $endDate';
        valueText = startDate;
      } else {
        return 'null';
      }
    }
    return valueText;
  }

  String _getValueText2(
    CalendarDatePicker2Type datePickerType,
    List<DateTime?> values,
  ) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        // final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1
            ? values[1].toString().replaceAll('00:00:00.000', '')
            : 'null';
        valueText = endDate;
      } else {
        return 'null';
      }
    }
    return valueText;
  }

}