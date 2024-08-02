import 'package:flutter/material.dart';
import 'package:mill_project/screens/paramgraph.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ParamContainer extends StatefulWidget {
  final String paramtype;
  final double max;
  final double threshold;
  final String unit;
  final double value;
  final String millID;
  const ParamContainer(
      {super.key,
      required this.paramtype,
      required this.max,
      required this.threshold,
      required this.unit,
      required this.value,
      required this.millID}); //constructor

  @override
  State<ParamContainer> createState() => _ParamContainerState();
}

class _ParamContainerState extends State<ParamContainer> {
  //temporary
  double curr_val = 0;
  @override
  Widget build(BuildContext context) {
    curr_val = widget.value;
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 190,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(alignment: Alignment.topCenter, children: [
                Positioned(
                  child: Column(
                    children: [
                      SizedBox(
                        child: Text(
                          widget.paramtype.split(' ')[0],
                          style: const TextStyle(
                              fontSize: 20,
                              height: 0.7,
                              color: Color.fromARGB(255, 104, 104, 104)),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          widget.paramtype.split(' ')[1],
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 104, 104, 104)),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: 140,
                    height: 120,
                    child: SfGaugeTheme(
                      data: SfGaugeThemeData(),
                      child: Align(
                        heightFactor: 0.8,
                        child: SfRadialGauge(
                          enableLoadingAnimation: true,
                          animationDuration: 500,
                          axes: <RadialAxis>[
                            RadialAxis(
                              showLabels: false,
                              startAngle: 180,
                              endAngle: 0,
                              canScaleToFit: true,
                              minimum: 0,
                              maximum: widget.max,
                              radiusFactor: 1,
                              axisLineStyle: AxisLineStyle(
                                  thickness: 0.3,
                                  thicknessUnit: GaugeSizeUnit.factor),
                              pointers: <GaugePointer>[
                                RangeColor(),
                                RangePointer(
                                  value: curr_val,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  pointerOffset: 0.3,
                                  color: Colors.white,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),

              Row(
                children: [
                  Text(
                    '$curr_val',
                    style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w700, height: 0.5),
                  ),
                  Text(widget.unit,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 0.6))
                ],
              ), //here
              //here
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ParamGraph(
              paramtype: widget.paramtype,
              millID: widget.millID,
            ),
          ),
        );
      },
    );
  }

  Text Status() {
    if (curr_val < widget.threshold) {
      return Text("Low",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red));
    } else {
      return Text("Normal",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.green));
    }
  }

  RangePointer RangeColor() {
    if (curr_val < widget.threshold) {
      return RangePointer(
        value: curr_val,
        sizeUnit: GaugeSizeUnit.factor,
        color: Colors.red,
      );
    } else {
      return RangePointer(
        value: curr_val,
        sizeUnit: GaugeSizeUnit.factor,
        color: Colors.green,
      );
    }
  }
}
