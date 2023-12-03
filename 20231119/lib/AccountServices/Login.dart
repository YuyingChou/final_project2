import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:nuuapp/AccountServices/Register.dart';
import 'Home.dart';

void main() => runApp(MaterialApp(home: LoginPage()));

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BuildContext currentContext = context;
    return MaterialApp(
      title: '登入介面',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'TW'),
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('登入'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      hintText: '輸入使用者名稱',
                      labelText: '使用者名稱',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '輸入密碼',
                      labelText: '密碼',
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    key: const Key('loginButton'),
                    onPressed: () async {
                      String username = usernameController.text;
                      String password = passwordController.text;

                      // 檢查 username 和 password 是否為空
                      if (username.isEmpty || password.isEmpty) {
                        showDialog(
                          context: currentContext,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('登入失敗'),
                              content: const Text('請輸入使用者名稱和密碼'),
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
                        return; // 避免繼續執行
                      }

                      Future<http.Response> postUserInfo(
                          String username, String password) {
                        const String apiUrl =
                            'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/login';

                        final Map<String, dynamic> userData = {
                          'username': username,
                          'password': password
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
                        //傳送帳號密碼
                        final response = await postUserInfo(username, password);

                        // 登入成功
                        if (response.statusCode == 200) {
                          final jsonResponse = json.decode(response.body);
                          final userId = jsonResponse['_id'];

                          Future<http.Response> getUserInfo(
                              String userId) async {
                            String apiUrl =
                                'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/user/$userId';

                            final response = await http.get(
                              Uri.parse(apiUrl),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                            );
                            return response;
                          }

                          // 取得使用者信息
                          final userInfoResponse = await getUserInfo(userId);

                          // 取得信息成功
                          if (userInfoResponse.statusCode == 200) {
                            final userInfo = json.decode(userInfoResponse.body);
                            // 更新狀態
                            context.read<UserProvider>().setUser(
                                  userInfo['username'],
                                  userId,
                                  userInfo['email'],
                                  userInfo['studentId'],
                                  userInfo['Department'],
                                  userInfo['Year'],
                                  userInfo['gender'],
                                  userInfo['phoneNumber'],
                                );

                            Provider.of<UserProvider>(context, listen: false)
                                .setUserLoggedIn();

                            Navigator.push(
                              currentContext,
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()),
                            );
                          }
                        } else {
                          // 登入失敗
                          showDialog(
                            context: currentContext,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('登入失敗'),
                                content: const Text('請確認你的使用者名稱與密碼是否輸入正確'),
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
                        // 發生錯誤
                        print('登入失敗: $e');
                      }
                    },
                    child: const Text('登入'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 在按下按鈕時導航到註冊頁面
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text('註冊'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 當按鈕被按下時，導航到 PasswordResetPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PasswordResetPage()),
                      );
                    },
                    child: Text('忘記密碼'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordResetPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('忘記密碼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: '輸入您的電子郵件',
                labelText: '電子郵件',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;

                // 執行資料庫查詢，檢查該email是否已註冊
                bool isEmailRegistered = await checkEmailRegistration(email);

                if (isEmailRegistered) {
                  // 生成驗證碼
                  String verificationCode = generateVerificationCode();

                  // 寄送驗證碼至郵箱（請自行實現此功能）
                  await sendVerificationCode(email, verificationCode);

                  // 導航到驗證碼頁面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificationCodePage(
                        generatedVerificationCode: verificationCode,
                        email: email, // 將電子郵件作為參數傳遞
                      ),
                    ),
                  );

                  // 顯示驗證碼已成功發送的提示
                  showVerificationCodeSentDialog(context);
                } else {
                  // 如果未註冊，顯示相應的對話框
                  showEmailNotRegisteredDialog(context);
                }
              },
              child: Text('發送驗證碼'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkEmailRegistration(String email) async {
    try {
      const apiUrl =
          'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/checkEmailRegistration';

      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'email': email}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['isRegistered'];
      } else {
        throw Exception('Failed to check email registration');
      }
    } catch (error) {
      print('Error checking email registration: $error');
      return false;
    }
  }

  String generateVerificationCode() {
    return (1000 + DateTime.now().millisecond % 9000).toString();
  }

  Future<bool> sendVerificationCode(
      String email, String verificationCode) async {
    try {
      final smtpServer =
          gmail('nuuappemailsender@gmail.com', 'evhb ahun gikp ffgd');

      final message = Message()
        ..from = Address('nuuappemailsender@gmail.com', 'NuuApp')
        ..recipients.add(email)
        ..subject = '驗證碼'
        ..text = '您的驗證碼是：$verificationCode';

      final sendReport = await send(message, smtpServer);

      if (sendReport.toString().contains('Message sent')) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print('Error sending verification code email: $error');
      return false;
    }
  }

  void showEmailNotRegisteredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('該Email尚未註冊'),
          content: Text('請確認您輸入的電子郵件是否正確。'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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

void showVerificationCodeSentDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('驗證碼已成功發送'),
        content: Text('請檢查您的郵箱並輸入收到的驗證碼。'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class VerificationCodePage extends StatelessWidget {
  final TextEditingController verificationCodeController =
      TextEditingController();
  final String generatedVerificationCode;
  final String email;

  VerificationCodePage({
    required this.generatedVerificationCode,
    required this.email, // 新增這一行
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('驗證碼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: verificationCodeController,
              decoration: InputDecoration(
                hintText: '輸入驗證碼',
                labelText: '驗證碼',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String enteredCode = verificationCodeController.text;
                bool isCodeCorrect = checkVerificationCode(enteredCode);

                if (isCodeCorrect) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordChangePage(
                        email: email, // 將電子郵件作為參數傳遞
                      ),
                    ),
                  );
                } else {
                  showIncorrectCodeDialog(context);
                }
              },
              child: Text('驗證'),
            ),
          ],
        ),
      ),
    );
  }

  bool checkVerificationCode(String enteredCode) {
    return enteredCode == generatedVerificationCode;
  }

  void showIncorrectCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('驗證碼錯誤'),
          content: Text('請檢查您輸入的驗證碼是否正確。'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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

class PasswordChangePage extends StatelessWidget {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final String email;

  PasswordChangePage({required this.email});

  Future<String?> fetchUsername() async {
    try {
      final apiUrl =
          'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/email/$email';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['username'];
      } else {
        throw Exception('Failed to fetch username');
      }
    } catch (error) {
      print('Error fetching username: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改密碼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: fetchUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('未找到用户名');
                } else {
                  String username = snapshot.data.toString();
                  if (username.isNotEmpty) {
                    return Text(
                      '要修改密碼的電子郵件：$email\n用户名：$username',
                      style: TextStyle(fontSize: 16.0),
                    );
                  } else {
                    return Text('未找到用户名');
                  }
                }
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '輸入新密碼',
                labelText: '新密碼',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '再次確認新密碼',
                labelText: '確認新密碼',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (newPassword == confirmPassword) {
                  bool isPasswordChanged =
                      await changePasswordInDatabase(email, newPassword);

                  if (isPasswordChanged) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    showFailedToChangePasswordDialog(context);
                  }
                } else {
                  showPasswordMismatchDialog(context);
                }
              },
              child: Text('確認修改'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> changePasswordInDatabase(
      String email, String newPassword) async {
    try {
      final apiUrl =
          'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/change-password/$email';

      final response = await http.put(
        Uri.parse(apiUrl),
        body: jsonEncode({'newPassword': newPassword}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['success'];
      } else {
        throw Exception('Failed to change password');
      }
    } catch (error) {
      print('Error changing password: $error');
      return false;
    }
  }

  void showFailedToChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('修改密碼失敗'),
          content: Text('無法將新密碼更新到資料庫。請稍後再試。'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPasswordMismatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('密碼不一致'),
          content: Text('請確保兩次輸入的密碼相同。'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
