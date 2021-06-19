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

class ScanPage extends StatefulWidget {
  const ScanPage({ Key? key }) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size.infinite);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<bool> _enableAudio = ValueNotifier(true);
  ValueNotifier<CameraOrientations> _orientation = ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture
  PictureController _pictureController = PictureController();
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
              child: CameraAwesome(
                selectDefaultSize: (List<Size> availableSizes) => Size(1920, 1080),
                onCameraStarted: () { },
                zoom: _zoomNotifier,
                sensor: _sensor,
                photoSize: _photoSize,
                switchFlashMode: _switchFlash,
                captureMode: _captureMode,
                fitted: true,
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
            },
          )
        ],
      ),
    );
  }
}