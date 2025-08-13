import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'boleta_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BoletaProvider(),
      child: MaterialApp(
        title: 'Boleta de Productos',
        home: HomeScreen(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    );
  }
}
