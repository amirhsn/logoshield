import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logoshield/components/cameraViewSingleton.dart';
import 'package:logoshield/components/classifier.dart';
import 'package:logoshield/components/constant.dart';
import 'package:logoshield/components/isolate_utils.dart';
import 'package:logoshield/components/recognition.dart';
import 'package:logoshield/components/stats.dart';
import 'package:logoshield/pages/resultPage.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<Recognition> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  /// Constructor
  const CameraView(this.resultsCallback, this.statsCallback);
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  List<CameraDescription> cameras;

  /// Controller
  CameraController cameraController;

  /// true when inference is ongoing
  bool predicting;

  /// Instance of [Classifier]
  Classifier classifier;

  /// Instance of [IsolateUtils]
  IsolateUtils isolateUtils;

  var rawImage, _imageSaved;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Spawn a new isolate
    isolateUtils = IsolateUtils();
    await isolateUtils.start();

    // Camera initialization
    initializeCamera();

    // Create an instance of classifier to load model and labels
    classifier = Classifier();

    // Initially predicting = false
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController =
        CameraController(cameras[0], ResolutionPreset.veryHigh, enableAudio: false);

    cameraController.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      Size previewSize = cameraController.value.previewSize;

      /// previewSize is size of raw input image to the model
      CameraViewSingleton.inputImageSize = previewSize;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: AspectRatio(
              aspectRatio: cameraController.value.aspectRatio*(1),
              child: CameraPreview(cameraController)),
        ),
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/mask.png',
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: screenHeight(context)*(1/7),
            width: double.infinity,
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.only(
              bottom: screenHeight(context)*(1/20),
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
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier.interpreter != null && classifier.labels != null) {
      // If previous inference has not completed then return
      if (predicting) {
        return;
      }

      setState(() {
        predicting = true;
      });

      var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;

      // Data to be passed to inference isolate
      var isolateData = IsolateData(
          cameraImage, classifier.interpreter.address, classifier.labels);

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      Map<String, dynamic> inferenceResults = await inference(isolateData);

      var uiThreadInferenceElapsedTime =
          DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

      // pass results to HomeView
      widget.resultsCallback(inferenceResults["recognitions"]);

      // pass stats to HomeView
      widget.statsCallback((inferenceResults["stats"] as Stats)
        ..totalElapsedTime = uiThreadInferenceElapsedTime);

      // set predicting to false to allow new frames
      setState(() {
        predicting = false;
      });
    }
  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }


//====================================================================//
//====================================================================//
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
              size: screenHeight(context)*(1/30),
            ),
          ),
        ),
      ),
    );
  }

  Widget cameraControlWidget(context){
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
              onPressed: (){
                cameraController.stopImageStream();
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
//====================================================================//
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
//====================================================================//
//====================================================================//
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

  onCapture(context) async{
    try{
      cameraController.takePicture().then((value) {
        print(value);
        setState(() {
          _imageSaved = File(value.path);
          rawImage = value;
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultPage(
          imgPath: rawImage,
        )));
        
      });
    }catch(e){
      print('capture gagal');
    }
  }
//====================================================================//
//====================================================================//


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}