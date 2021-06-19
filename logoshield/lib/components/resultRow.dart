import 'package:flutter/material.dart';
import 'package:logoshield/components/constant.dart';

Widget resultRow(BuildContext context, String judul, String hasil){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        judul,
        style: TextStyle(
          color: Colors.black,
          letterSpacing: 1,
          fontSize: screenHeight(context)*(1/40),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            ':',
            style: TextStyle(
              color: Colors.black,
              letterSpacing: 1,
              fontSize: screenHeight(context)*(1/35),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: screenWidth(context)*(1/20)
            ),
            width: screenWidth(context)*(1/2.7),
            child: Text(
              hasil,
              style: TextStyle(
                color: Colors.black,
                letterSpacing: 1,
                fontSize: screenHeight(context)*(1/38),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}