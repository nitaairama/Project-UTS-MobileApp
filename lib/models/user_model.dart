class UserModel {
  int? id;
  String username;
  String password;
  String? photo; // Path foto profil

  UserModel({
    this.id,
    required this.username,
    required this.password,
    this.photo,
  });

  // Convert dari map ke object
  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        photo: json['photo'],
      );

  // Convert object ke map untuk SQLite
  Map<String, dynamic> toMap() => {
        "username": username,
        "password": password,
        "photo": photo,
      };
}