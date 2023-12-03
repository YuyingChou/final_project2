import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'package:nuuapp/AccountServices/Register.dart';


class ProfileSetting extends StatefulWidget {
  const ProfileSetting({Key? key}) : super(key: key);

  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  // 用户信息
  String username = '';
  String email = '';
  String studentId = '';
  String gender = '';
  String phoneNumber = '';
  String department = '';
  String year = '';

  bool isEditing = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final studentIdController = TextEditingController();
  final genderController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final departmentController = TextEditingController();
  final yearController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    usernameController.text = userProvider.username;
    emailController.text = userProvider.email;
    studentIdController.text = userProvider.studentId;
    genderController.text = userProvider.gender;
    phoneNumberController.text = userProvider.phoneNumber;
    departmentController.text = userProvider.department;
    yearController.text = userProvider.year;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    studentIdController.dispose();
    genderController.dispose();
    phoneNumberController.dispose();
    departmentController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> editUser({
    required String userId,
  }) async {
    Future<http.Response> editUserProfile(String username, String email,String studentId, String department,
        String year, String gender, String phoneNumber) {
      final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/$userId';

      final Map<String, dynamic> userData = {
        'userId' : userId,
        'username': username,
        'email': email,
        'studentId': studentId,
        'Department': department,
        'Year': year,
        'gender': gender,
        'phoneNumber': phoneNumber,
      };

      return http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );
    }
    try {
      // 調用 editUserProfile 函數發送 PUT 請求
      final response = await editUserProfile(username, email, studentId, department, year, gender, phoneNumber);

      if (response.statusCode == 200) {
        final updatedUserData = jsonDecode(response.body);
        print('用户信息更新成功: $updatedUserData');
        Fluttertoast.showToast(
          msg: "更新成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0, //文本大小
        );
      } else {
        print('用户信息更新失败: ${response.statusCode}');
      }
    } catch (e) {
      // 發生錯誤
      print('異常: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯個人檔案'),
        actions: <Widget>[
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing; // 切换编辑模式

                if (!isEditing) {
                  username = usernameController.text;
                  email = emailController.text;
                  studentId = studentIdController.text;
                  gender = genderController.text;
                  phoneNumber = phoneNumberController.text;
                  department = departmentController.text;
                  year = yearController.text;
                  editUser( userId: userProvider.userId );
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildProfileField('姓名', usernameController, isEditing),
            _buildProfileField('電子郵件', emailController, isEditing),
            _buildProfileField('學號', studentIdController, isEditing),
            _buildProfileField('性別', genderController, isEditing),
            _buildProfileField('行動電話', phoneNumberController, isEditing),
            _buildProfileField('系所', departmentController, isEditing),
            _buildProfileField('年級', yearController, isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: controller,
          readOnly: !enabled, //只有在编辑模式下可编辑
          decoration: InputDecoration(
            enabled: enabled,
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
