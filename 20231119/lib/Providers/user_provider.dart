import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String username = '';
  String userId = '';
  String email = '';
  String studentId = '';
  String department = '';
  String year = '';
  String gender = '';
  String phoneNumber = '';

  bool isLoggedIn = false;

  void setUser(String newUsername, String newUserId, String newEmail, String newStudentId, String newDepartment,String newYear, String newGender, String newPhoneNumber) {
    username = newUsername;
    userId = newUserId;
    email = newEmail;
    studentId = newStudentId;
    department = newDepartment;
    year = newYear;
    gender = newGender;
    phoneNumber = newPhoneNumber;

    notifyListeners();
  }

  void setUserLoggedIn() {
    isLoggedIn = true;
    notifyListeners();
  }
  void setUserLoggedOut() {
    isLoggedIn = false;
    notifyListeners();
  }
}