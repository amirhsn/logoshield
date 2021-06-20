import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logoshield/components/constant.dart';
import 'package:logoshield/components/resultRow.dart';

class ResultPage extends StatefulWidget {
  final XFile imgPath;
  const ResultPage({key, this.imgPath}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: warna1(),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Colors.black,
            ), 
            onPressed: (){
              Navigator.pop(context);
            }
          ),
          elevation: 0,
        ),
        backgroundColor: warna1(),
        body: Center(
          child: Container(
            width: screenWidth(context)*(1/1.2),
            height: screenHeight(context)*(1/1.6),
            decoration: BoxDecoration(
              color: warna1(),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(
                color: Colors.grey,
                blurRadius: 2,
                spreadRadius: 2,
              )]
            ),
            margin: EdgeInsets.only(
              bottom: screenHeight(context)*(1/15)
            ),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth(context)*(1/20)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: screenHeight(context)*(1/5),
                  height: screenHeight(context)*(1/5),
                  //color: Colors.orange,
                  child: Image.file(
                    File(widget.imgPath.path),
                    fit: BoxFit.cover,
                  )
                ),
                SizedBox(
                  height: screenHeight(context)*(1/100),
                ),
                Center(
                  child: Text(
                    'HASIL',
                    style: TextStyle(
                      color: Colors.black,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight(context)*(1/25),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  indent: 60,
                  endIndent: 60,
                ),
                SizedBox(
                  height: screenHeight(context)*(1/20),
                ),
                resultRow(context, 'Isi QR Code', '637463882747'),
                SizedBox(
                  height: screenHeight(context)*(1/60),
                ),
                resultRow(context, 'Klasifikasi', 'fake ip6'),
                SizedBox(
                  height: screenHeight(context)*(1/20),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
