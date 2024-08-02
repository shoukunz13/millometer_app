import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool vibrate = true;
  bool notification = true;
  String tone = 'None';

  // Controllers for the text fields
  final steamPressureController = TextEditingController();
  final steamFlowController = TextEditingController();
  final waterLevelController = TextEditingController();
  final turbineFrequencyController = TextEditingController();

  // Dummy PiID and phoneNum for testing
  final String dummyPiID = 'millopi';
  final String dummyPhoneNum = '601139021939';
  final String apiKey =
      '1b50e01f728f56b50a66c92261b746c0aa8277251de247df713d72f5a8a65b04'; // Replace with your actual API key

  Future<void> updateThresholds() async {
    if (steamPressureController.text.isEmpty ||
        steamFlowController.text.isEmpty ||
        waterLevelController.text.isEmpty ||
        turbineFrequencyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final String piID = dummyPiID;
    final String phoneNum = dummyPhoneNum;

    final url = Uri.parse(
        'http://10.0.2.2:3004/api/updateThreshold/?PiID=$piID&phoneNum=%2B$phoneNum');

    try {
      print('Sending request to $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'api-key':
              '1b50e01f728f56b50a66c92261b746c0aa8277251de247df713d72f5a8a65b04', // Add API key here
        },
        body: json.encode({
          'steam_pressure': int.parse(steamPressureController.text),
          'steam_flow': int.parse(steamFlowController.text),
          'water_level': int.parse(waterLevelController.text),
          'turbine_frequency': int.parse(turbineFrequencyController.text),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle successful response
        print('Thresholds updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thresholds updated successfully')),
        );
      } else {
        // Handle error response
        print('Failed to update thresholds: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update thresholds: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error during network request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    steamPressureController.dispose();
    steamFlowController.dispose();
    waterLevelController.dispose();
    turbineFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 5,
      fit: FlexFit.loose,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(220, 248, 248, 248),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 2, // Spread radius of the shadow
              blurRadius: 4, // Blur radius of the shadow
              offset: Offset(0, 3), // Offset of the shadow
            )
          ],
        ),
        height: 490,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start, //check
            children: [
              Row(
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Text(
                          'Minimum Threshold',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.info_outline),
                              tooltip:
                                  'Values lower than the \nvalues specified here will\ntrigger the alert.',
                            ))
                      ],
                    ),
                  ),
                ],
              ),
              Flexible(
                flex: 7,
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ParamSetting(
                              controller: steamPressureController,
                              paramtype: 'Steam\nPressure',
                              unit: 'bar',
                              threshold: 30,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ParamSetting(
                              controller: waterLevelController,
                              paramtype: 'Water\nLevel',
                              threshold: 42,
                              unit: '%',
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ParamSetting(
                              controller: steamFlowController,
                              paramtype: 'Steam\nFlow',
                              threshold: 29,
                              unit: 'T/H',
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ParamSetting(
                              controller: turbineFrequencyController,
                              paramtype: 'Turbine\nFrequency',
                              threshold: 50,
                              unit: 'Hz',
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Sound & Vibrations',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                ),
              ),
              Flexible(
                flex: 5,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Vibrate',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 104, 104, 104)),
                        ),
                        Text(
                          'Show notifications',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 104, 104, 104)),
                        ),
                        Text(
                          'Sound',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 104, 104, 104)),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 80,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: vibrate,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              setState(() {
                                vibrate = value;
                              });
                            },
                          ),
                        ),
                        Transform.scale(
                          scale: 1.2,
                          child: Switch(
                            value: notification,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              setState(() {
                                notification = value;
                              });
                            },
                          ),
                        ),
                        TextButton(onPressed: () {}, child: Text(tone))
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: updateThresholds,
                child: Text('Save Thresholds'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParamSetting extends StatefulWidget {
  final TextEditingController controller;
  final String paramtype;
  final int threshold;
  final String unit;

  const ParamSetting({
    super.key,
    required this.controller,
    required this.paramtype,
    required this.threshold,
    required this.unit,
  });

  @override
  State<ParamSetting> createState() => _ParamSettingState();
}

class _ParamSettingState extends State<ParamSetting> {
  @override
  Widget build(BuildContext context) {
    widget.controller.text = widget.threshold.toString(); // Set initial value

    return Column(
      children: [
        Text(
          widget.paramtype,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 104, 104, 104),
              height: 1.2),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 80,
                height: 50,
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      hintText: widget.threshold.toString(),
                      hintStyle: TextStyle(color: Colors.grey)),
                  keyboardType: TextInputType.number,
                )),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 230, 230, 230),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  widget.unit,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 104, 104, 104),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
