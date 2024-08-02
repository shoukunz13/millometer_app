class Engineer {
  final String name;
  final String phone;

  Engineer({
    required this.name,
    required this.phone,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    return Engineer(
      name: json['name'],
      phone: json['phone'],
    );
  }
}
