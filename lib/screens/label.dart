// detail_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String userInput = '';

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        // Close the floating widget when tapping outside the content area
        Navigator.pop(context);
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              bottom: 0,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mill name : ',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          userInput = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Type here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          // Do something with the user input if needed
                          print('User input: $userInput');
                    
                          // Close the floating widget
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                           height: 50,
                            child: Center(
                              child: Text(
                                'Submit',
                                style: TextStyle(fontSize: 18),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
