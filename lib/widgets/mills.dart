import 'package:flutter/material.dart';
import 'package:mill_project/screens/label.dart';

// ignore: must_be_immutable
class Mills extends StatefulWidget {
  final String raspberrypiId; // Corrected parameter name
  final String label; // Label from cloud saved data
  final List<double>? parameters;
  final bool isSelected;

  Mills({
    super.key,
    required this.raspberrypiId, // Corrected parameter name
    this.parameters,
    required this.label,
    this.isSelected = false,
  });

  @override
  State<Mills> createState() => _MillsState();
}

class _MillsState extends State<Mills> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showDetailScreen(context); // Call function to open another widget
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
        child: Container(
          height: 90,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0XFFF8F8F8),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 2,
                offset: const Offset(0, 2), // Shadow position (X, Y)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.factory_sharp,
                  size: 30,
                ),
              ),
              _labelName(),
            ],
          ),
        ),
      ),
    );
  }

  Text _labelName() {
    if (widget.label.isEmpty) {
      return Text(
        widget.raspberrypiId,
        style: const TextStyle(fontSize: 18),
      );
    } else {
      return Text(
        widget.label,
        style: const TextStyle(fontSize: 18),
      );
    }
  }

  void _showDetailScreen(BuildContext context) {
    // Use Navigator to push a new widget onto the screen when long-pressed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DetailScreen(); // Replace 'DetailScreen' with the widget you want to show
        },
      ),
    );
  }
}
