import 'package:flutter/material.dart';
import 'package:logoshield/components/constant.dart';
import 'package:logoshield/components/recognition.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  final Recognition result;

  const BoxWidget({Key key, this.result}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Color for bounding box
    Color color = Colors.blue;

    return Stack(
      children: [
        Positioned(
          left: result.renderLocation.left,
          top: result.renderLocation.top,
          width: result.renderLocation.width,
          height: result.renderLocation.height,
          child: Container(
            width: result.renderLocation.width,
            height: result.renderLocation.height,
            decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.all(Radius.circular(2))),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: screenHeight(context)*(1/25),
            width: screenWidth(context)*(1/1.9),
            margin: EdgeInsets.only(
              bottom: screenHeight(context)*(1/4)
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Hold steady for autofocus',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}