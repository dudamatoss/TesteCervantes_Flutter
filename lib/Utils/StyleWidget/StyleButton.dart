import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  insert,
}

class StyleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  const StyleButton(
      {Key? key,
      required this.onPressed,
      required this.text,
      required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        maximumSize: Size(double.infinity, 100),
          backgroundColor:
               const Color.fromARGB(208, 60, 254, 39), // cor de fundo
                elevation: 5, // sem sombra
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // bordas arredondadas
    ),
          foregroundColor:  Colors.black,
           textStyle: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none, // remove sublinhado
    ),
  ),
      child: Text(text),
    );
  }
}