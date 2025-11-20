class ContactModel {
  int? id;
  String name;
  String email;
  String phone;
  String? photo;
  String? avatarUrl;
  String? address;
  String? company;

  ContactModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
    this.avatarUrl,
    this.address,
    this.company,
  });

  factory ContactModel.fromMap(Map<String, dynamic> json) => ContactModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        photo: json['photo'],
        avatarUrl: json['avatarUrl'],
        address: json['address'],
        company: json['company'],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "phone": phone,
        "photo": photo,
        "avatarUrl": avatarUrl,
        "address": address,
        "company": company,
      };
}