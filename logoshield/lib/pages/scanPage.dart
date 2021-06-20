import 'dart:io';
import 'dart:typed_data';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:logoshield/components/bottomBar.dart';
import 'package:logoshield/components/constant.dart';
import 'package:camerawesome/camerapreview.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/capture_modes.dart';
import 'package:camerawesome/models/flashmodes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:camerawesome/models/sensors.dart';
import 'package:camerawesome/picture_controller.dart';
import 'package:path_provider/path_provider.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({ key }) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.ON);
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size.infinite);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<bool> _enableAudio = ValueNotifier(true);
  ValueNotifier<CameraOrientations> _orientation = ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture
  PictureController _pictureController = PictureController();
  Stream<Uint8List> previewStream;

  @override
  void initState(){
    super.initState();
    loadModel().then((value){
      setState(() {});
    });
  }

  @override
  void dispose() {
    Tflite.close();
    _photoSize.dispose();
    _captureMode.dispose();
    super.dispose();
  }

  bool _loading = false;
  File _image;
  var _output;

  classifyImage(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 4,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
          _output = output;
          _loading = false;
    });
  }

  checkImageStream(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 4,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
          _output = output;
          _loading = false;
    });
    print(output);
  }

  loadModel() async{
    await Tflite.loadModel(
      model: 'assets/ml/model.tflite',
      labels: 'assets/ml/labels.txt'
    );
  }



  @override
  Widget build(BuildContext context) {
    print(screenHeight(context));
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              width: screenWidth(context),
              height: screenHeight(context),
              child: GestureDetector(
                child: CameraAwesome(
                  selectDefaultSize: (List<Size> availableSizes) => availableSizes[0],
                  onCameraStarted: () { },
                  zoom: _zoomNotifier,
                  sensor: _sensor,
                  photoSize: _photoSize,
                  switchFlashMode: _switchFlash,
                  captureMode: _captureMode,
                  fitted: false,
                  imagesStreamBuilder: (imageStream){
                    setState(() {
                      previewStream = imageStream;
                    });
                    imageStream.listen((Uint8List imageData){
                      //print("...${DateTime.now()} new image received... ${imageData.lengthInBytes} bytes");
                      _takePhoto();
                      checkImageStream(_image);
                    });
                  },
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: screenHeight(context)*(1/3.7),
              height: screenHeight(context)*(1/3.7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blue,
                  width: 2
                )
              ),
            ),
          ),
          BottomBarWidget(
            onZoomInTap: () {
              if (_zoomNotifier.value <= 0.9) {
                _zoomNotifier.value += 0.1;
              }
              setState(() {});
            }, 
            onZoomOutTap: () {
              if (_zoomNotifier.value >= 0.1) {
                _zoomNotifier.value -= 0.1;
              }
              setState(() {});
            }, 
            onFlashTap: (){
              switch (_switchFlash.value){
                case CameraFlashes.NONE:
                  _switchFlash.value = CameraFlashes.ON;
                  break;
                case CameraFlashes.ON:
                  _switchFlash.value = CameraFlashes.NONE;
                  break;
                case CameraFlashes.AUTO:
                  _switchFlash.value = CameraFlashes.NONE;
                  break;
                case CameraFlashes.ALWAYS:
                  _switchFlash.value = CameraFlashes.NONE;
                  break;      
              }
              setState(() {});
            },
            switchFlash: _switchFlash,
          )
        ],
      ),
    );
  }

  _takePhoto() async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
        await Directory('${extDir.path}/test').create(recursive: true);
    final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _pictureController.takePicture(filePath);
    print("----------------------------------");
    print("TAKE PHOTO CALLED");
    final file = File(filePath);
    print("==> hastakePhoto : ${file.exists()} | path : $filePath");
    //final img = imgUtils.decodeImage(file.readAsBytesSync());
    //print("==> img.width : ${img.width} | img.height : ${img.height}");
    print("----------------------------------");
    _image = File(filePath);
  }

}