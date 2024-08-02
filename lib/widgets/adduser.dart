// detail_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
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
          alignment: Alignment.center,
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
              top: screenHeight * 0.2,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Invitation',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 25),
                        )),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Invite User',
                          style: TextStyle(fontSize: 14),
                        )),
                    Text(
                      'Owner\'s Name : ',
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
                    Text(
                      'Owner\'s Phone Number : ',
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
                    SizedBox(height: 20),
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
                            ))),
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
