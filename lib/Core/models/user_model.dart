import 'package:objectbox/objectbox.dart';

@Entity()
class UserModel {
  @Id()
  int id;

  String uid;
  String name;
  String email;
  String photoUrl;
  bool isLoggedIn;

  @Property(type: PropertyType.date)  
  DateTime lastLogin;

  UserModel({
    this.id = 0,
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.isLoggedIn,
    required this.lastLogin,
  });
}