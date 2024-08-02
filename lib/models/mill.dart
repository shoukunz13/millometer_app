class Mill {
  final String raspberrypiId;
  final String label;

  Mill({required this.raspberrypiId, required this.label});

  factory Mill.fromJson(Map<String, dynamic> json) {
    return Mill(
      raspberrypiId: json['raspberrypi_id'],
      label: json['label'],
    );
  }
}
