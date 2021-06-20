import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logoshield/components/cameraOverlay.dart';
import 'package:logoshield/components/constant.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:logoshield/pages/resultPage.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({ key }) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController cameraController;
  List cameras;
  int selectedCameraIndex;
  
  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      availableCameras().then((value) {
        cameras = value;
        if(cameras.length > 0){
          selectedCameraIndex = 0;
          initCamera(cameras[selectedCameraIndex],).then((_){});
        }else{
          print('error');
        }
      }).catchError((e){
        print(e.code);
      });
    }

  @override
    void dispose() {
      // TODO: implement dispose
      super.dispose();
    }

  Future initCamera(CameraDescription cameraDescription) async{
    if (cameraController != null){
      await cameraController.dispose();
    }
    cameraController = CameraController(cameraDescription, ResolutionPreset.veryHigh);
    cameraController.addListener(() {if (mounted){
      setState(() {});
    }});
    if (cameraController.value.hasError){
      print('Camera Error');
    }
    try{
      await cameraController.initialize();
    }catch(e){
      print('Camera error'+e);
    }
    if(mounted){
      setState(() {});
    }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: cameraPreview(),
            ),
            cameraOverlay(
              padding: 50, aspectRatio: 1, color: Color(0x55000000)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenHeight(context)*(1/7),
                width: double.infinity,
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    cameraFlashWidget(),
                    cameraControlWidget(context),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cameraPreview(){
    if(cameraController == null || !cameraController.value.isInitialized){
      return Text(
        'Loading',
        style: TextStyle(
          color: warna1()
        ),
      );
    }
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }

  

  Widget cameraFlashWidget(){
    if(cameras == null || cameras.isEmpty){
      return Spacer();
    }
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: (){
            onSwitchFlash();
          }, 
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: warna1()
            ),
            height: screenWidth(context)*(1/10),
            width: screenWidth(context)*(1/10),
            child: Icon(
              getFlashIcon(cameraController.value.flashMode),
              color: Colors.black,
              size: screenHeight(context)*(1/25),
            ),
          ),
        ),
      ),
    );
  }

  getFlashIcon(flashStatus){
    switch (flashStatus){
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.torch:
        return Icons.touch_app_rounded;  
      default:
        return Icons.device_unknown;
    }
  }

  onSwitchFlash(){
    FlashMode selectedFlashNow = cameraController.value.flashMode;
    if (selectedFlashNow == FlashMode.off){
      selectedFlashNow = FlashMode.always;
      onSetFlashModeButtonPressed(selectedFlashNow);
    }
    else if (selectedFlashNow == FlashMode.always){
      selectedFlashNow = FlashMode.auto;
      onSetFlashModeButtonPressed(selectedFlashNow);
    }
    else if (selectedFlashNow == FlashMode.auto){
      selectedFlashNow = FlashMode.torch;
      onSetFlashModeButtonPressed(selectedFlashNow);
    }  
    else if (selectedFlashNow == FlashMode.torch){
      selectedFlashNow = FlashMode.off;
      onSetFlashModeButtonPressed(selectedFlashNow);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (cameraController == null) {
      return;
    }

    try {
      await cameraController.setFlashMode(mode);
    } on CameraException catch (e) {
      print(e.toString());
    }
  }

  cameraControlWidget(context){
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
              onPressed: (){
                onCapture(context);
              },
              backgroundColor: warna1(),
              child: Icon(
                Icons.camera,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }

  onCapture(context) async{
    try{
      cameraController.takePicture().then((value) {
        print(value);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(imgPath: value,)));
      });
    }catch(e){
      print('capture gagal');
    }
  }

  
//===========================================================//
//===========================================================//


  
}