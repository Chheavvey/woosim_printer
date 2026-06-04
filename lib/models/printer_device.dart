class PrinterDevice {
  const PrinterDevice({
    required this.name,
    required this.address,
  });

  final String name;
  final String address;

  factory PrinterDevice.fromMap(Map<dynamic, dynamic> map) {
    return PrinterDevice(
      name: map['name']?.toString() ?? 'Unknown Printer',
      address: map['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }
}
