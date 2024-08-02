import 'engineer.dart';

class Factory {
  String factoryId;
  final String factoryName;
  String status;
  double steamPressure;
  double steamFlow;
  double waterLevel;
  double powerFrequency;
  String datetime;

  Engineer? owner;
  List<Engineer> engineers;
  final Threshold threshold;

  Factory({
    required this.factoryId,
    required this.factoryName,
    required this.status,
    required this.steamPressure,
    required this.steamFlow,
    required this.waterLevel,
    required this.powerFrequency,
    required this.datetime,
    this.owner,
    required this.engineers,
    required this.threshold,
  });

  void updateOwner(Engineer newOwner) {
    owner = newOwner;
  }

  void updateEngineers(List<Engineer> newEngineers) {
    engineers = newEngineers;
  }
}

class Threshold {
  double steamPressure;
  double steamFlow;
  double waterLevel;
  double powerFrequency;

  Threshold({
    required this.steamPressure,
    required this.steamFlow,
    required this.waterLevel,
    required this.powerFrequency,
  });
}

List<Factory> factories = [
  Factory(
    factoryId: '668637b5a5d082f6188137d1',
    factoryName: "Factory 1",
    status: "⚠️ ABD1234 IS UNREACHABLE!",
    steamPressure: 0.0,
    steamFlow: 0.0,
    waterLevel: 0.0,
    powerFrequency: 0.0,
    datetime: "--:--",
    engineers: [],
    threshold: Threshold(
      steamPressure: 30,
      steamFlow: 25,
      waterLevel: 52,
      powerFrequency: 48,
    ),
  ),
  Factory(
    factoryId: '668637b5a5d082f6188137d2',
    factoryName: "Factory 2",
    status: "1549.7kW",
    steamPressure: 34.19,
    steamFlow: 22.8,
    waterLevel: 55.41,
    powerFrequency: 50.08,
    datetime: "2024-04-26 13:45:25",
    engineers: [],
    threshold: Threshold(
      steamPressure: 30,
      steamFlow: 25,
      waterLevel: 52,
      powerFrequency: 48,
    ),
  ),
  Factory(
    factoryId: '668637b5a5d082f6188137d3',
    factoryName: "Factory 3",
    status: "2013.4kW",
    steamPressure: 56.78,
    steamFlow: 35.15,
    waterLevel: 60.11,
    powerFrequency: 58.81,
    datetime: "2024-04-26 13:46:37",
    engineers: [],
    threshold: Threshold(
      steamPressure: 29,
      steamFlow: 22,
      waterLevel: 53,
      powerFrequency: 48,
    ),
  ),
  Factory(
    factoryId: '668637b5a5d082f6188137d4',
    factoryName: "Factory 4",
    status: "⚠️ XYZ6666 IS UNREACHABLE!",
    steamPressure: 0.0,
    steamFlow: 0.0,
    waterLevel: 0.0,
    powerFrequency: 0.0,
    datetime: "--:--",
    engineers: [],
    threshold: Threshold(
      steamPressure: 20,
      steamFlow: 20,
      waterLevel: 20,
      powerFrequency: 20,
    ),
  ),
];

final List<String> details = [
  "Steam Pressure",
  "Steam Flow",
  "Water Level",
  "Power Frequency"
];

final List<String> units = ["bar", "T/H", "%", "Hz"];
