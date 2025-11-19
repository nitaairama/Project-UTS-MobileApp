class ContactModel {
  int? id;
  String name;
  String email;
  String phone;
  String? photo;      // path lokal
  String? avatarUrl;  // foto dari API

  ContactModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
    this.avatarUrl,
  });

  factory ContactModel.fromMap(Map<String, dynamic> json) => ContactModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        photo: json['photo'],
        avatarUrl: json['avatarUrl'],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "phone": phone,
        "photo": photo,
        "avatarUrl": avatarUrl,
      };
}