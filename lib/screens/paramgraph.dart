import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import '../web_socket_service.dart';  // Import the WebSocket service
import 'dart:async';

class ParamGraph extends StatefulWidget {
  final String paramtype;
  final String millID;

  const ParamGraph({super.key, required this.paramtype, required this.millID});

  @override
  State<ParamGraph> createState() => _ParamGraphState();
}

class _ParamGraphState extends State<ParamGraph> {
  late WebSocketService _webSocketService;
  final List<ChartData> _chartData = [];
  late StreamSubscription<String> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService('ws://localhost:3004'); // Replace with your WebSocket URL

    _streamSubscription = _webSocketService.stream.listen(
      (data) {
        try {
          final double parsedData = double.parse(data);
          setState(() {
            _chartData.add(ChartData(DateTime.now(), parsedData));
            // Optionally limit the number of data points for performance
            if (_chartData.length > 100) {
              _chartData.removeAt(0);
            }
          });
        } catch (e) {
          print('Error parsing data: $e');
        }
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.millID),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  widget.paramtype,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 0.6,
                    color: Color.fromARGB(255, 104, 104, 104),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enableMouseWheelZooming: true,
                ),
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('HH:mm'), // Format the x-axis labels as 'hour:minute'
                ),
                series: <ChartSeries>[
                  LineSeries<ChartData, DateTime>(
                    dataSource: _chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Calendar(),
          ],
        ),
      ),
    );
  }
}

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: SfDateRangePicker(
          view: DateRangePickerView.month,
          selectionMode: DateRangePickerSelectionMode.range,
          showActionButtons: true,
          onSubmit: (selectedDateRange) {
            // Handle date range submission
          },
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}