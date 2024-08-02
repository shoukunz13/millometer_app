import 'package:flutter/material.dart';
import 'ParamContainer.dart';

class HomeWidget extends StatefulWidget {
  final String millID;
  const HomeWidget({super.key, required this.millID});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround, //check
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('302121.1',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold,height: 1.5)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Text('Kwh',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //next two rows in this column is for the parameters
            // row for steam pressure and steam flow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ParamContainer(
                  paramtype: 'Steam Pressure',
                  max: 50,
                  threshold: 30.0,
                  unit: 'bar',
                  value: 20,
                  millID: widget.millID,
                ),
                ParamContainer(
                  paramtype: 'Steam Flow',
                  max: 50,
                  threshold: 29,
                  unit: 'T/H',
                  value: 30,
                  millID: widget.millID,
                ),
              ],
            ),
            // row for water level and turbine container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ParamContainer(
                  paramtype: 'Water Level',
                  max: 100,
                  threshold: 42,
                  unit: '%',
                  value: 30,
                  millID: widget.millID,
                ),
                ParamContainer(
                  paramtype: 'Turbine Frequency',
                  max: 60,
                  threshold: 50,
                  unit: 'Hz',
                  value: 40,
                  millID: widget.millID,
                ),
              ],
            ),
            const Text(
              "Last update :  2023-03-12  09:41:01",
              style: TextStyle(
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }
}
