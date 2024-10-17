class AppUser {
  final String? uid;
  final String name;
  final String surname;
  final String phone;
  final String birthDate;
  final String username;
  final String address;
  final String number;
  final String npa;
  final String locality;
  final String email;

  AppUser({
    this.uid,
    required this.name,
    required this.surname,
    required this.phone,
    required this.birthDate,
    required this.username,
    required this.address,
    required this.number,
    required this.npa,
    required this.locality,
    required this.email,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'phone': phone,
      'birthDate': birthDate,
      'username': username,
      'address': address,
      'number': number,
      'npa': npa,
      'locality': locality,
      'email': email,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      name: json['name'],
      surname: json['surname'],
      phone: json['phone'],
      birthDate: json['birthDate'],
      username: json['username'],
      address: json['address'],
      number: json['number'],
      npa: json['npa'],
      locality: json['locality'],
      email: json['email'],
    );
  }
}