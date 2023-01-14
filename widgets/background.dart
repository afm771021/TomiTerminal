import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
        gradient:  LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.2, 0.8],
          colors:[
            Colors.blue.shade100,
            Colors.blue.shade200,
          ]
        )
      );
    return  Stack(
      children: [
        Container(decoration:  boxDecoration),
        Positioned(
          top:-250,
          left: -30,
          child: _PinkBox(),),
        Positioned(
            child: _GreenBox(),
            top: 500,
          left: 500
        )
      ],

    );
  }
}

class _GreenBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -75,
      child: Container(
        width: 560,
        height: 560,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            gradient:  LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade100,
                ]
            )
        ),
      ),
    );
  }
}

class _PinkBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 45,
      child: Container(
        width: 660,
        height: 660,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(236, 98, 188, 1),
              Color.fromRGBO(241, 142, 172, 1),
            ]
          )
        ),
      ),
    );
  }
}

