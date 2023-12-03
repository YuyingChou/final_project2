import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:nuuapp/Providers/UberList_provider.dart';
import 'package:nuuapp/Providers/ListItem_provider.dart';
import 'package:nuuapp/Providers/ListOwner_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'UberListPage/MyUberList.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<bool> showDetailsDialog(BuildContext context, UberItem item) async {
  Future<http.Response> getUserInfo(String userId) async {
    String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/users/user/$userId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }
  //取得擁有者信息
  final userInfoResponse = await getUserInfo(item.userId);
  //取得信息成功
  if (userInfoResponse.statusCode == 200) {
    final ownerInfo = json.decode(userInfoResponse.body);
    if (!context.mounted) return false;
    context.read<ListOwnerProvider>().setListOwnerInfo(
      ownerInfo['username'],
      item.userId,
      ownerInfo['email'],
      ownerInfo['studentId'],
      ownerInfo['Department'],
      ownerInfo['Year'],
      ownerInfo['gender'],
      ownerInfo['phoneNumber'],
    );
  }

  //送出email給清單建立者
  Future<void> sendReservationEmail(
      String listOwnerEmail,
      String reservedUserEmail,
      String reservedUserName,
      String reservedUserStudentId,
      String reservedUserDepartment,
      String reservedUserYear,
      String reservedUserGender,
      String reservedUserPhoneNumber,
      ) async {
    String username = 'nuuappemailsender@gmail.com';
    String password = 'evhb ahun gikp ffgd';

    final smtpServer = gmail(username, password);

    final messageToListOwner = Message()
      ..from = Address(username, 'NuuApp')
      ..recipients.add(listOwnerEmail)
      ..subject = '預約行程通知'
      ..text = '有人預約你的行程。\n\n'
          '預約者信息:\n'
          '姓名: $reservedUserName\n\n'
          'Email:$reservedUserEmail \n\n'
          '系所:$reservedUserDepartment $reservedUserYear \n\n'
          '性別: $reservedUserGender \n\n'
          '行動電話: $reservedUserPhoneNumber \n\n'
          '備註: 行動電話僅在必要時連絡對方，請勿隨意將個資外洩，或是造成他人困擾!';

    try {
      final sendReportToListOwner = await send(messageToListOwner, smtpServer);
      print('郵件發送成功: ${sendReportToListOwner.toString()}');
    } on MailerException catch (e) {
      print('郵件發送失敗: $e');
    }
  }


  //更新list的reserved狀態，成功後發送email
  Future<void> editList({
    required String listId,
  }) async {
    Future<http.Response> setReserved() {
      final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/editList/$listId';

      final Map<String, dynamic> listData = {
        'userId' : context.read<ListItemProvider>().userId,
        'anotherUserId': context.read<ListItemProvider>().anotherUserId,
        'reserved' : context.read<ListItemProvider>().reserved,
        'startingLocation': context.read<ListItemProvider>().startingLocation,
        'destination': context.read<ListItemProvider>().destination,
        'selectedDateTime': context.read<ListItemProvider>().selectedDateTime.toIso8601String(),
        'wantToFindRide': context.read<ListItemProvider>().wantToFindRide,
        'wantToOfferRide': context.read<ListItemProvider>().wantToOfferRide
      };

      return http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(listData),
      );
    }
    try {
      // 調用 setReserved 函數發送 PUT 請求
      final response = await setReserved();

      if (response.statusCode == 200) {
        final updatedUserData = jsonDecode(response.body);
        print('預約成功: $updatedUserData');
        Fluttertoast.showToast(
          msg: "預約成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0, //文本大小
        );
        sendReservationEmail(
            context.read<ListOwnerProvider>().email,
            context.read<UserProvider>().email,
            context.read<UserProvider>().username,
            context.read<UserProvider>().studentId,
            context.read<UserProvider>().department,
            context.read<UserProvider>().year,
            context.read<UserProvider>().gender,
            context.read<UserProvider>().phoneNumber,
        );
        Navigator.of(context).pop(true);
      } else {
        print('用户信息更新失败: ${response.statusCode}');
      }
    } catch (e) {
      // 發生錯誤
      print('異常: $e');
    }
  }
  Future<void> onDelete(BuildContext context, listId) async {
    String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/deleteList/$listId';
    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "確定完成",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
      } else {
        throw Exception('刪除失敗');
      }
    } catch (e) {
      print('刪除錯誤: $e');
      // 处理删除异常
    }
  }


  if (!context.mounted) return false;
  bool? clickedReserved = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      context.read<ListItemProvider>().setList(
        item.listId,
        item.userId,
        item.anotherUserId,
        item.reserved,
        item.startingLocation,
        item.destination,
        item.selectedDateTime,
        item.wantToFindRide,
        item.wantToOfferRide,
        item.notes,
        item.pay
    );

      return Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    '詳細資訊',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),textAlign: TextAlign.center
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 18.0,color: Colors.black),
                        children: [
                          const TextSpan(
                            text: '建立者： ',
                          ),
                          TextSpan(
                            text: context.watch<ListOwnerProvider>().username,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 18.0,color: Colors.black),
                        children: [
                          const TextSpan(
                            text: '性別： ',
                          ),
                          TextSpan(
                            text: context.watch<ListOwnerProvider>().gender,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18.0,color: Colors.black),
                    children: [
                      const TextSpan(
                        text: '學號： ',
                      ),
                      TextSpan(
                        text: context.watch<ListOwnerProvider>().studentId,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18.0,color: Colors.black),
                    children: [
                      const TextSpan(
                        text: '系所： ',
                      ),
                      TextSpan(
                        text: context.watch<ListOwnerProvider>().department + context.watch<ListOwnerProvider>().year,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18.0,color: Colors.black),
                    children: [
                      const TextSpan(
                        text: '地點： ',
                      ),
                      TextSpan(
                        style: const TextStyle(color: Colors.black),
                        text: '從 ${item.startingLocation} 到 ${item.destination}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18.0,color: Colors.black),
                    children: [
                      const TextSpan(
                        text: '出發時間： ',
                      ),
                      TextSpan(
                        style: const TextStyle(color: Colors.black),
                        text: DateFormat('yyyy-MM-dd HH:mm').format(item.selectedDateTime),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 18.0,color: Colors.black),
                    children: [
                      const TextSpan(
                        text: '報酬： ',
                      ),
                      TextSpan(
                        text: item.pay.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                    "備註: ",
                  style: TextStyle(fontSize: 18.0,color: Colors.black),
                ),
                item.notes.isNotEmpty ?
                SizedBox(
                  width: 200.0,
                  height: 100.0,
                  child: SingleChildScrollView(
                    child: Text(
                      item.notes,
                      style: const TextStyle(fontSize: 18.0, color: Colors.black),
                    ),
                  ),
                ) : const Text('無'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    item.userId != context.read<UserProvider>().userId ?
                    //別人建立的清單，可預約
                    ElevatedButton(
                      onPressed: () {
                        if(context.read<ListItemProvider>().anotherUserId.isNotEmpty ){
                          Fluttertoast.showToast(
                            msg: "此清單已有人預約",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0, //文本大小
                          );
                        }
                        else if(context.read<ListItemProvider>().anotherUserId == context.read<UserProvider>().userId){
                          Fluttertoast.showToast(
                            msg: "你已預約這個行程",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 16.0, //文本大小
                          );
                        }
                        //無人預約，預約該行程
                        else{
                          context.read<ListItemProvider>().setReserved(context.read<UserProvider>().userId, true);
                          editList(listId: item.listId);
                        }
                      },
                      child: item.wantToOfferRide
                          ? const Text('預約搭乘')
                          : const Text('預約提供座位')
                    )
                    :  //自己建立的行程，可完成行程並刪除
                    ElevatedButton(
                      onPressed: () {
                        //有人預約並時間已過
                        if(item.reserved == true && DateTime.now().compareTo(item.selectedDateTime) > 0){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text(
                                    "完成該行程？按下確認完成後將刪除這個行程",
                                    style: TextStyle(fontSize: 16.0)
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await onDelete(context, item.listId);
                                    },
                                    child: const Text("確認完成"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("取消"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text(
                                    '這個行程還沒有人預約或時間尚未到喔!',
                                    style: TextStyle(fontSize: 16.0)
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("確認"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: const Text('完成行程'),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('關閉'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  )?? false;
  return clickedReserved;
}