class DeviceCategory {
  final String id;
  final String name;

  DeviceCategory({required this.id, required this.name});

  factory DeviceCategory.fromMap(Map<String, dynamic> map, String id) {
    return DeviceCategory(id: id, name: map['name'] ?? '');
  }

  Map<String, dynamic> toMap() => {'name': name};
}
