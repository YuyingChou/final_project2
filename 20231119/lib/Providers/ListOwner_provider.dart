import 'package:flutter/material.dart';

//UberList創建者的使用者信息管理
class ListOwnerProvider extends ChangeNotifier{
  String username = '';
  String userId = '';
  String anotherUserId = '';
  String email = '';
  String studentId = '';
  String department = '';
  String year = '';
  String gender = '';
  String phoneNumber = '';

  //讀取卡片時使用(loadCard)
  void setListOwnerInfo(String newUsername, String newUserId, String newEmail, String newStudentId, String newDepartment,String newYear, String newGender, String newPhoneNumber) {
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
}