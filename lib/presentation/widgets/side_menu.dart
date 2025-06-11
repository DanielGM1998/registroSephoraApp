import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sephora/constants/constants.dart';
import 'package:sephora/presentation/screens/consulta_qr/consulta_qr_screen.dart';
import 'package:sephora/presentation/screens/estadistica/estadistica_screen.dart';
import 'package:sephora/presentation/screens/premio/premio_screen.dart';
import 'package:sephora/presentation/screens/usuario/usuario_screen.dart';
import '../screens/home/home_screen.dart';

class SideMenu extends StatefulWidget {
  final String userapp;
  final String tipoapp;
  final String idapp;
  const SideMenu({
    Key? key,
    required this.userapp,
    required this.tipoapp,
    required this.idapp,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int? navDrawerIndex;
  late Future<String> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = _checkVersion();
  }

  Future<String> _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return NavigationDrawer(
      backgroundColor: Colors.white,
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (value) {
        setState(() {
          navDrawerIndex = value;

          if(widget.tipoapp=="1"){
            switch (navDrawerIndex) {
              case 0:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed(
                  UsuarioScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed(
                  PremioScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 3:
                Navigator.of(context).pushReplacementNamed(
                  EstadisticaScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              case 4:
                Navigator.of(context).pushReplacementNamed(
                  ConsultaQrScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              default:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
            }

          }else if(widget.tipoapp=="2"){
            switch (navDrawerIndex) {
              case 0:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              default:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
            }

          }else if(widget.tipoapp=="3"){
            switch (navDrawerIndex) {
              case 0:
                Navigator.of(context).pushReplacementNamed(
                  PremioScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              default:
                Navigator.of(context).pushReplacementNamed(
                  PremioScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
            }
          }else{
            switch (navDrawerIndex) {
              case 0:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
              default:
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                  arguments: {
                    'idapp': widget.idapp,
                  },
                );
                break;
            }
          }
        });
      },
      children: [
        FutureBuilder<String>(
          future: _versionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const DrawerHeader(
                decoration: BoxDecoration(color: Colors.white70),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const DrawerHeader(
                decoration: BoxDecoration(color: Colors.white70),
                child: Center(child: Text("Error al cargar la versión")),
              );
            } else {
              return DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white70),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        myLogo,
                        height: size.height * 0.06,
                        width: size.width * 0.4,
                      ),
                    ),
                    SizedBox(height: size.width * 0.01),
                    Text(widget.userapp,
                        style: const TextStyle(
                            color:myColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(nameVersion + snapshot.data!,
                        style: const TextStyle(
                            color: myColor, fontSize: 14)),
                  ],
                ),
              );
            }
          },
        ),
        if(widget.tipoapp=="1")
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_filled, color: myColor),
            label: Text("Inicio", style: TextStyle(color: myColor)),
          ),
        if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: myColor,
          ),
        if(widget.tipoapp=="1")
          const NavigationDrawerDestination(
            icon: Icon(Icons.supervised_user_circle_sharp, color: myColor),
            label: Text("Stands", style: TextStyle(color: myColor)),
          ),
        if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: myColor,
          ),
        if(widget.tipoapp=="1")
          const NavigationDrawerDestination(
            icon: Icon(Icons.card_giftcard, color: myColor),
            label: Text("Premios", style: TextStyle(color: myColor)),
          ),
          if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: myColor,
          ),
        if(widget.tipoapp=="1")
          const NavigationDrawerDestination(
            icon: Icon(Icons.stacked_bar_chart, color: myColor),
            label: Text("Estadísticas", style: TextStyle(color: myColor)),
          ),
          if(widget.tipoapp=="1")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: myColor,
          ),

        if(widget.tipoapp=="1")
          const NavigationDrawerDestination(
            icon: Icon(Icons.search, color: myColor),
            label: Text("Consulta QR", style: TextStyle(color: myColor)),
          ),


        if(widget.tipoapp=="2")
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_filled, color: myColor),
            label: Text("Inicio", style: TextStyle(color: myColor)),
          ),
        if(widget.tipoapp=="2")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: myColor,
          ),


        if(widget.tipoapp=="3")
          const NavigationDrawerDestination(
            icon: Icon(Icons.card_giftcard, color: myColor),
            label: Text("Premios", style: TextStyle(color: myColor)),
          ),
        if(widget.tipoapp=="3")
          const Divider(
            height: 1,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: myColor,
          ),     


      ],
    );
  }
}
