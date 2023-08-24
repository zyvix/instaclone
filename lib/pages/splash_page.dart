import 'dart:async';

import 'package:flutter/material.dart';
import 'package:instaclone/pages/home_page.dart';
import 'package:instaclone/pages/signin_page.dart';

class SplashPage extends StatefulWidget {
  static final String id = "splash_page";
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  _initTimer(){
    Timer(Duration(seconds: 2),(){
      _callSignInPage();
    });
  }

  _callSignInPage(){
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  _callHomePage(){
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(193, 53, 132, 1),
              Color.fromRGBO(131, 58, 180, 1),
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Instagram",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontFamily: "Billabong",
                  ),
                ),
              ),
            ),

            Text(
              "All right reserved",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
            ),

            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}
