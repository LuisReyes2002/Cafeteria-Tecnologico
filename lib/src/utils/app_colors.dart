import 'package:flutter/material.dart';

class AppColors {
  static const verde = Color(0xFF7ed957);
  static const amarrillo = Color(0xFFffde59);
  static const rojo = Color.fromARGB(255, 137, 8, 8);
  static const oscuroV = Color(0xFF024b22);
  static const azul = Color(0xFF004aae);
  static const naranja = Color(0xFFf79415);
  static const gris = Color(0xFFf0f0f0);
  static const negro = Color(0xFF000000);
  static const rosa = Color(0xFFff66c4);

  static get gradientColor1 => LinearGradient(
        colors: [
          naranja,
          amarrillo,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
  static const gradienColor2 = LinearGradient(
      colors: [
        rojo,
        azul,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [
        0,
        5,
        0.5,
      ]);
}
