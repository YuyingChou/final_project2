import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

String? selectedRole = '學生';
List<String> roleOptions = ['學生', '其他人士'];

String? selectedGender = '其他';
List<String> genderOptions = ['男', '女', '其他'];

String? selectedDepartment;
String? selectedYear;

List<String> departments = [
  '臺灣語文與傳播學系',
  '華語文學系',
  '文化創意與數位行銷學系',
  '文化觀光產業學系',
  '工業設計學系',
  '建築學系',
  '經營管理學系',
  '財務金融學系',
  '資訊管理學系',
  '電機工程學系',
  '電子工程學系',
  '光電工程學系',
  '資訊工程學系',
  '機械工程學系',
  '土木與防災工程學系',
  '化學工程學系'
];

List<String> years = ['一年級', '二年級', '三年級', '四年級', '碩士生', '博士生'];

void main() => runApp(const MaterialApp(home: RegisterPage()));

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController verificationCodeController =
  TextEditingController();

  String emailVerificationCode = '';

  Future<void> registerUser() async {
    final String username = usernameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String studentId = studentIdController.text;
    final String phoneNumber = phoneNumberController.text;

    // 檢查驗證碼是否已輸入
    if (verificationCodeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('請輸入驗證碼'),
            content: const Text('請輸入您收到的驗證碼'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // 不進行註冊
    }

    // 比對驗證碼
    if (verificationCodeController.text != emailVerificationCode) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('驗證碼不正確!'),
            actions: <Widget>[
              TextButton(
                child: const Text('確定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // 不進行註冊
    }

    Future<http.Response> createAlbum(
        String username, String email, String password, String studentId) {
      const String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/register';

      String processedStudentId = studentId;
      String processedDepartment = selectedDepartment ?? '';
      String processedYear = selectedYear ?? '';

      if (selectedRole == '其他人士') {
        processedStudentId = '$username!';
        processedDepartment = 'other';
        processedYear = 'other';
      }

      final Map<String, dynamic> userData = {
        'username': username,
        'email': email,
        'password': password,
        'studentId': processedStudentId,
        'Department': processedDepartment,
        'Year': processedYear,
        'gender': selectedGender,
        'phoneNumber': phoneNumber,
      };

      return http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );
    }

    try {
      if (selectedRole == '其他人士') {
        studentIdController.text = username;
      }

      final response = await createAlbum(username, email, password, studentId);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('註冊成功，用戶 ID: ${jsonResponse['_id']}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text('註冊成功!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('回到登錄頁面'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('註冊失敗'),
              content: const Text('姓名、學號或電子信箱已被註冊過\n(所有欄位都必填)'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('註冊失敗: $e');
    }
  }

  String generateVerificationCode() {
    final Random random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  void sendVerificationCode(String email, String verificationCode) async {
    final smtpServer =
    gmail('nuuappemailsender@gmail.com', 'evhb ahun gikp ffgd');

    final message = Message()
      ..from = Address('nuuappemailsender@gmail.com', 'NuuApp')
      ..recipients.add(email)
      ..subject = 'Email 驗證'
      ..text = '你的驗證碼是: $verificationCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  void sendVerificationEmail(String email) async {
    // 在這裡添加檢查郵箱是否已被註冊的邏輯
    bool isEmailRegistered = await checkEmailRegistration(email);

    if (isEmailRegistered) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('郵箱已註冊'),
            content: const Text('此郵箱已被註冊，請使用其他郵箱'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // 如果郵箱未被註冊，則發送驗證碼
      emailVerificationCode = generateVerificationCode();
      sendVerificationCode(email, emailVerificationCode);
    }
  }

  Future<bool> checkEmailRegistration(String email) async {
    const String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/checkEmailRegistration';

    final Map<String, dynamic> requestData = {'email': email};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['isRegistered'] ?? false;
      } else {
        print('檢查郵箱註冊狀態失敗: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('檢查郵箱註冊狀態時發生異常: $e');
      return false;
    }
  }

  void verifyCode() {
    String userEnteredCode = verificationCodeController.text;
    if (userEnteredCode == emailVerificationCode) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('驗證碼正確!'),
            actions: <Widget>[
              TextButton(
                child: const Text('確定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('驗證碼不正確!'),
            actions: <Widget>[
              TextButton(
                child: const Text('確定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('註冊'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RadioListTile<String>(
                  title: const Text('學生'),
                  value: '學生',
                  groupValue: selectedRole,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRole = value;
                      if (selectedRole == '其他人士') {
                        studentIdController.text = usernameController.text;
                        selectedDepartment = null;
                        selectedYear = null;
                      }
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('其他人士'),
                  value: '其他人士',
                  groupValue: selectedRole,
                  onChanged: (String? value) {
                    setState(() {
                      selectedRole = value;
                      if (selectedRole == '學生') {
                        studentIdController.text = '';
                        selectedDepartment = null;
                        selectedYear = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: '姓名',
                    labelText: '姓名',
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: '電子郵件',
                          labelText: '電子郵件',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        sendVerificationEmail(emailController.text);
                      },
                      child: const Text('發送驗證碼到郵箱'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: verificationCodeController,
                  decoration: const InputDecoration(
                    hintText: '輸入驗證碼',
                    labelText: '驗證碼',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '密碼',
                    labelText: '密碼',
                  ),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(
                    hintText: '行動電話',
                    labelText: '行動電話',
                  ),
                ),
                const SizedBox(height: 16.0),
                if (selectedRole == '學生')
                  TextField(
                    controller: studentIdController,
                    decoration: const InputDecoration(
                      hintText: '學號',
                      labelText: '學號',
                    ),
                  ),
                if (selectedRole == '學生')
                  DropdownButtonFormField<String>(
                    value: selectedDepartment,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('選擇系所'),
                      ),
                      ...departments
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                    decoration: const InputDecoration(
                      hintText: '系所',
                      labelText: '系所',
                    ),
                  ),
                if (selectedRole == '學生')
                  DropdownButtonFormField<String>(
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue;
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: '',
                        child: Text('選擇年級'),
                      ),
                      ...years.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ],
                    decoration: const InputDecoration(
                      hintText: '年級',
                      labelText: '年級',
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text('選擇性別'),
                    ),
                    ...genderOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ],
                  decoration: const InputDecoration(
                    hintText: '性別',
                    labelText: '性別',
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    registerUser();
                  },
                  child: const Text('註冊'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
