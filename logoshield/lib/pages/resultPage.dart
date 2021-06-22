import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logoshield/components/constant.dart';
import 'package:logoshield/components/resultRow.dart';
import 'package:logoshield/pages/homeView.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ResultPage extends StatefulWidget {
  final XFile imgPath;
  const ResultPage({key, this.imgPath}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  Interpreter interpreter2;

  var labelKey = '';
  var labelValues;
  bool isLoading = true;

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      loadModel();
      prepareDetection(File(widget.imgPath.path));
    }
  
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeView()));
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.imgPath.path),
                      fit: BoxFit.cover,
                    ),
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
                resultRow(context, 'Isi QR Code', labelKey),
                SizedBox(
                  height: screenHeight(context)*(1/60),
                ),
                resultRow(context, 'Klasifikasi', isLoading ? '' : hasilKlasifikasi()),
                SizedBox(
                  height: screenHeight(context)*(1/20),
                ),
              ],
            ),
          ),
        ),
    );
  }


  //====================================================================//
//====================================================================//

  loadModel() async{
    interpreter2 =
            await Interpreter.fromAsset("model.tflite");
  }  
  prepareDetection(File imageFile){
    ImageProcessor imageProcessor = ImageProcessorBuilder()
      .add(ResizeOp(224, 224, ResizeMethod.NEAREST_NEIGHBOUR))
      .build();
    TensorImage tensorImage = TensorImage.fromFile(imageFile);
    tensorImage = imageProcessor.process(tensorImage);
    //output
    TensorBuffer probabilityBuffer = TensorBuffer.createFixedSize(<int>[1, 4], TfLiteType.uint8);
    loadingModelDetection(tensorImage, probabilityBuffer);
  }

  loadingModelDetection(TensorImage tensorImage, TensorBuffer probabilityBuffer) async{
    try {
        interpreter2 =
            await Interpreter.fromAsset("model.tflite");
        interpreter2.run(tensorImage.buffer, probabilityBuffer.buffer);
        List arrayHasil = probabilityBuffer.getDoubleList();
        //for(int i=0;i<arrayHasil.length;i++){
        //  arrayHasil[i] = arrayHasil[i] / 255;
        //}
        //print(arrayHasil);
        labelValues = arrayHasil.cast<num>().reduce(max);
        mappingHasil(probabilityBuffer, arrayHasil.indexOf(labelValues));
    } catch (e) {
        print('Error loading model: ' + e.toString());
    }
  }

  mappingHasil(probabilityBuffer, int x) async{
    List<String> labels = await FileUtil.loadLabels("assets/labels.txt");
    TensorLabel tensorLabel = TensorLabel.fromList(
      labels, probabilityBuffer);

    Map<String, double> doubleMap = tensorLabel.getMapWithFloatValue();
    print(doubleMap);
    labelKey = labels[x];
    print(labelKey);
    isLoading = false;
    setState(() {});
  }
//===========================================================//
//===========================================================//
  String hasilKlasifikasi(){
    switch(labelKey){
      case 'genuine_ip6s':
      return 'Iphone 6s Asli';
      case 'genuine_mi8':
      return 'Mi8 Asli';
      case 'fake_ip6s':
      return 'Iphone 6s Palsu';
      case 'fake_mi8':
      return 'Mi8 Palsu';
    }
  }
}
