import 'package:flutter/material.dart';

const colorList = <Color>[
  Colors.white,
  Colors.teal,
  Colors.green,
  Colors.red,
  Colors.purple,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.pinkAccent,
];



class AppTheme {

  final int selectedColor;
  final bool isDarkmode;
  final colorDark = Colors.blue[700];//Color(0xFF040b2c);
  final colorWhite = Color(0xffb7dc4f);// Colors.white70;
  final bordeDark = Colors.blue; 
  final bordeWhite = Color(0xffb7dc4f);
  final colorBtn = [Color.fromARGB(255, 19, 143, 133), Color.fromARGB(255, 35, 73, 208)];
  final headerGradiant = [Color(0xffb7dc4f), Colors.green];


  AppTheme({
    this.selectedColor = 0,
    this.isDarkmode = true,
  }): assert( selectedColor >= 0, 'Selected color must be greater then 0' ),  
      assert( selectedColor < colorList.length, 
        'Selected color must be less or equal than ${ colorList.length - 1 }');

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: isDarkmode ? Brightness.dark : Brightness.light,
    
    scaffoldBackgroundColor: isDarkmode ? Color(0xFF040b2c) : null,
    colorSchemeSeed: colorList[ selectedColor ],
    appBarTheme: AppBarTheme(
      centerTitle: true,
       backgroundColor: isDarkmode ? Color(0xFF040b2c) : null, // Color del encabezado (AppBar)
       foregroundColor: isDarkmode ? Colors.white: null, 
    ),

   
  );


  AppTheme copyWith({
    int? selectedColor,
    bool? isDarkmode
  }) => AppTheme(
    selectedColor: selectedColor ?? this.selectedColor,
    isDarkmode: isDarkmode ?? this.isDarkmode,
  );

}