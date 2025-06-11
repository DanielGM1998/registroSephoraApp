import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/home/home_screen.dart';

class Info extends StatefulWidget {
  const Info({Key? key, required this.text, this.idapp}) : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  final text;
  // ignore: prefer_typing_uninitialized_variables
  final idapp;

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(seconds: 2), () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        HomeScreen.routeName,
        (Route<dynamic> route) => false,
        arguments: {
          'idapp': widget.idapp,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    //final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var splitted = widget.text.split(',');
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
      child: Scaffold(
        body: Stack(
          children: [
            Hero(
              tag: 'ok',
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: splitted[0]=="Bienvenido(a) a"
                      ?Colors.green
                      : Colors.amber,
                  ),
                  SafeArea(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 30, left: 30),
                                child: DefaultTextStyle(
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: GoogleFonts.roboto(
                                      fontSize: 24,
                                      color: splitted[0]=="Bienvenido(a) a"
                                        ? Colors.white70
                                        : Colors.black87,
                                      fontWeight: FontWeight.bold),
                                  child: Text(splitted[0]+splitted[1]),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Image.asset("assets/images/check.png",
                                  height: 200),
                              Text(
                                'Espere un momento por favor...',
                                style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  color: splitted[0]=="Bienvenido(a) a"
                                    ? Colors.white70
                                    : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      HomeScreen.routeName,
      (Route<dynamic> route) => false,
      arguments: {
        'idapp': widget.idapp,
      },
    );
    return true;
  }
}
