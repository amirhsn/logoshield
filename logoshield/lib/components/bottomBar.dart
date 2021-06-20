import 'package:flutter/material.dart';
import 'package:logoshield/components/constant.dart';
import 'package:camerawesome/models/flashmodes.dart';

class BottomBarWidget extends StatelessWidget {
  final Function onZoomInTap;
  final Function onZoomOutTap;
  final Function onFlashTap;
  final ValueNotifier<CameraFlashes> switchFlash;
  
  BottomBarWidget({ 
    key, 
    @required this.onZoomInTap, 
    @required this.onZoomOutTap, 
    @required this.onFlashTap,
    @required this.switchFlash, 
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [GestureDetector(
                onTap: () => onZoomInTap.call(),
                child: Container(
                  width: screenHeight(context)*(1/15),
                  height: screenHeight(context)*(1/15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: warna1(),
                  ),
                  child: Icon(
                    Icons.zoom_in,
                    size: screenHeight(context)*(1/29),
                    color: Colors.blue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onFlashTap.call(),
                child: Container(
                  width: screenHeight(context)*(1/10),
                  height: screenHeight(context)*(1/10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: warna1(),
                  ),
                  child: Icon(
                    getFlashIcon(),
                    size: screenHeight(context)*(1/23),
                    color: Colors.blue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onZoomOutTap.call(),
                child: Container(
                  width: screenHeight(context)*(1/15),
                  height: screenHeight(context)*(1/15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: warna1(),
                  ),
                  child: Icon(
                    Icons.zoom_out,
                    size: screenHeight(context)*(1/29),
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: screenHeight(context)*(1/12),
          ),
        ],
      ),
    );
  }

  IconData getFlashIcon() {
    switch (switchFlash.value) {
      case CameraFlashes.NONE:
        return Icons.flash_off;
      case CameraFlashes.ON:
        return Icons.flash_on;
      case CameraFlashes.AUTO:
        return Icons.flash_auto;
      case CameraFlashes.ALWAYS:
        return Icons.highlight;
      default:
        return Icons.flash_off;
    }
  }
}