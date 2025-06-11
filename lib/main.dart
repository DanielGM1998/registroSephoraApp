import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sephora/config/navigation/route_observer.dart';
import 'package:sephora/constants/constants.dart';
import 'package:sephora/presentation/screens/consulta_qr/consulta_qr_screen.dart';
import 'package:sephora/presentation/screens/consulta_qr/resultado_consulta_qr_screen.dart';
import 'package:sephora/presentation/screens/estadistica/estadistica_screen.dart';
import 'package:sephora/presentation/screens/home/home_screen.dart';
import 'package:sephora/presentation/screens/login/login_screen.dart';
import 'package:sephora/presentation/screens/premio/premio_screen.dart';
import 'package:sephora/presentation/screens/scanner/scanner_screen.dart';
import 'package:sephora/presentation/screens/splash/splash_screen.dart';
import 'package:sephora/presentation/screens/usuario/add_usuario_screen.dart';
import 'package:sephora/presentation/screens/usuario/edit_usuario_screen.dart';
import 'package:sephora/presentation/screens/usuario/usuario_screen.dart';
import 'config/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
String? initialPayload;

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null); // Inicializa para español
  Intl.defaultLocale = 'es'; // Configura el locale predeterminado

  // Limpia la caché para evitar errores de migración
  await DefaultCacheManager().emptyCache();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: nameApp,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme(selectedColor: 0).getTheme(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
        Locale('he', ''),
        Locale('es', ''),
        Locale('ru', ''),
        Locale('ko', ''),
        Locale('hi', ''),
      ],
      builder: EasyLoading.init(),
      navigatorObservers: [appRouteObserver],
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (BuildContext context) => const SplashScreen(),
        LoginScreen.routeName: (BuildContext context) => const LoginScreen(),
        HomeScreen.routeName: (BuildContext context) => const HomeScreen(),
        UsuarioScreen.routeName: (BuildContext context) => const UsuarioScreen(),
        PremioScreen.routeName: (BuildContext context) => const PremioScreen(),
        AgregarUsuarioScreen.routeName: (BuildContext context) => const AgregarUsuarioScreen(),
        EstadisticaScreen.routeName: (BuildContext context) => const EstadisticaScreen(),
        EditarUsuarioScreen.routeName: (BuildContext context) => const EditarUsuarioScreen(),
        ScannerScreen.routeName: (BuildContext context) => const ScannerScreen(),
        ConsultaQrScreen.routeName: (BuildContext context) => const ConsultaQrScreen(),
        ResultadoConsultaQrScreen.routeName: (BuildContext context) => const ResultadoConsultaQrScreen(),
      },
    );
  }
}
