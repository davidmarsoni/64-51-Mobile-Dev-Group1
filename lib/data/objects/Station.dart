class Station {
  String location;
  String address;
  List<String> bikeReferences;

  Station({
    required this.location,
    required this.address,
    required this.bikeReferences,
  });

  // Method to convert Station object to JSON
  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'address': address,
      'bikeReferences': bikeReferences,
    };
  }

  // Method to create Station object from JSON
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      location: json['location'],
      address: json['address'],
      bikeReferences: List<String>.from(json['bikeReferences']),
    );
  }
}