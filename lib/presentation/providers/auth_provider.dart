import 'package:flutter/material.dart';
import 'package:yakunstructuretest/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? get currentUser => UserModel(userId: "아이디", userName: "userName", joinDate: DateTime.timestamp(), pushAgree: false, isActive: true);
}