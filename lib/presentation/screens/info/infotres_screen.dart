import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sephora/main.dart';
import 'package:sephora/presentation/screens/premio/premio_screen.dart';

class InfoTres extends StatefulWidget {
  const InfoTres({Key? key, required this.text, this.idapp}) : super(key: key);
  // ignore: prefer_typing_uninitialized_variables
  final text;
  // ignore: prefer_typing_uninitialized_variables
  final idapp;
  
  @override
  State<InfoTres> createState() => _InfoTresState();
}

class _InfoTresState extends State<InfoTres> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(seconds: 4), () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        PremioScreen.routeName,
        (Route<dynamic> route) => false,
        arguments: {
          'idapp': widget.idapp,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.green,
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
                                  maxLines: 4,
                                  style: GoogleFonts.roboto(
                                      fontSize: 24,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold),
                                  child: Text(widget.text),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Image.asset("assets/images/check.png",
                                  height: 200),
                                  const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Espere un momento por favor...',
                                style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  color: Colors.white70,
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
      PremioScreen.routeName,
      (Route<dynamic> route) => false,
      arguments: {
        'idapp': widget.idapp,
      },
    );
    return true;
  }
}
