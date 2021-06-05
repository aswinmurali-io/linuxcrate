import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routes/dashboard.dart';

void main() => runApp(LinuxCrate());

class LinuxCrate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Crate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuTextTheme(
          Theme.of(context).textTheme,
        ),
        // brightness: Brightness.dark,
        popupMenuTheme: PopupMenuThemeData(
          textStyle: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          textTheme: GoogleFonts.ubuntuTextTheme(
            const TextTheme(
              headline6: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      home: Dashboard(),
    );
  }
}
