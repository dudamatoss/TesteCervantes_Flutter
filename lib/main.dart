import 'package:cadartroapp/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cadartroapp/Helper/db_helper.dart';


Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
   await DatabaseHelper().database; 

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cervantes Teste ',
      debugShowCheckedModeBanner: false, 
      home: Home(),
    );
  }
}
