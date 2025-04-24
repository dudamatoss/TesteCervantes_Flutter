import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'Pages/home.dart';

import 'package:cadartroapp/Helper/db_helper.dart';


Future<void> main() async {
  // Inicializa o suporte ao SQLite FFI (necessário em apps desktop)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
   WidgetsFlutterBinding.ensureInitialized(); 
   await DatabaseHelper().database; // 

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cervantes Teste',
      debugShowCheckedModeBanner: false, 
      home: Input(),
    );
  }
}
