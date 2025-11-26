class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String username;
  final String birthDate;
  final int age;
  final String gender;
  final String image;
  final String bloodGroup;
  final double height;
  final double weight;
  final String eyeColor;
  final Address address;
  final Company company;
  final String role;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.username,
    required this.birthDate,
    required this.age,
    required this.gender,
    required this.image,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.address,
    required this.company,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? 0,
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        username: json['username'] ?? '',
        birthDate: json['birthDate'] ?? '',
        age: json['age'] ?? 0,
        gender: json['gender'] ?? '',
        image: json['image'] ?? '',
        bloodGroup: json['bloodGroup'] ?? '',
        height: (json['height'] ?? 0).toDouble(),
        weight: (json['weight'] ?? 0).toDouble(),
        eyeColor: json['eyeColor'] ?? '',
        address: Address.fromJson(json['address'] ?? {}),
        company: Company.fromJson(json['company'] ?? {}),
        role: json['role'] ?? 'user',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'username': username,
        'birthDate': birthDate,
        'age': age,
        'gender': gender,
        'image': image,
        'bloodGroup': bloodGroup,
        'height': height,
        'weight': weight,
        'eyeColor': eyeColor,
        'address': address.toJson(),
        'company': company.toJson(),
        'role': role,
      };
}

class Address {
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  Address({
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        postalCode: json['postalCode'] ?? '',
        country: json['country'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
      };
}

class Company {
  final String name;
  final String title;
  final String department;

  Company({
    required this.name,
    required this.title,
    required this.department,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        name: json['name'] ?? '',
        title: json['title'] ?? '',
        department: json['department'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'title': title,
        'department': department,
      };
}
