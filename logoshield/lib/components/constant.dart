//File dart ini berisi komponen konstanta yang akan digunakan terus menerus sebagai preset

import 'package:flutter/material.dart';

//Ambil tinggi dan lebar layar smartphone
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

//Warna dasar
Color warna1() => Color(0xFFF5F5F5);