import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nuuapp/Providers/ListItem_provider.dart';
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../Providers/ListOwner_provider.dart';
import '../../Providers/UberList_provider.dart';
import '../detail_dialog.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() => runApp(const MyReservedList());

class MyReservedList extends StatefulWidget {
  const MyReservedList({super.key});

  @override
  MyReservedListState createState() => MyReservedListState();
}

class MyReservedListState extends State<MyReservedList> {
  List<UberItem> uberList = [];

  @override
  void initState() {
    super.initState();
    loadMyReservedCards(context);
  }

  Future<void> loadMyReservedCards(BuildContext context) async {
    String userId = context.read<UserProvider>().userId;
    try {
      List<UberItem> updatedList = await fetchData(userId);
      context.read<UberListProvider>().setList(updatedList);
    } catch (e) {
      print('載入時錯誤:$e');
    }
  }
  Future<List<UberItem>> fetchData(String userId) async {
    String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/searchMyReservedList?anotherUserId=$userId';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];

      List<UberItem> uberList = data.map((json) {
        return UberItem.fromJson(json);
      }).toList();

      return uberList;
    } else {
      throw Exception('載入失敗');
    }
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
      ..text = '預約的行程已被取消。\n\n'
          '取消預約者信息:\n'
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
    Future<http.Response> cancelReserved() {
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
      final response = await cancelReserved();

      if (response.statusCode == 200) {
        final updatedUserData = jsonDecode(response.body);
        print('取消預約成功: $updatedUserData');
        Fluttertoast.showToast(
          msg: "取消預約成功",
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
        await loadMyReservedCards(context);
        Navigator.of(context).pop();
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
    return Consumer<UberListProvider>(
      builder: (context, providerItem, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              providerItem.uberList.isEmpty
                  ? const Expanded(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "你目前沒有預約任何行程",
                        style: TextStyle(fontSize: 20.0),
                      )
                  )
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: providerItem.uberList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    final item = providerItem.uberList[index];
                    return Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Column(
                              children: [
                                const SizedBox(height: 8),
                                const Icon(Icons.directions_car),
                                Text(
                                  item.reserved ? "已預約" : "未預約",
                                  style: TextStyle(
                                    color: item.reserved
                                        ? Colors.green[900]
                                        : Colors.red[900],
                                  ),
                                ),
                              ],
                            ),
                            title: Text('從 ${item.startingLocation} 到 ${item.destination}'),
                            subtitle: Text(
                                '${DateFormat('yyyy-MM-dd HH:mm').format(item.selectedDateTime)} 出發'),
                            trailing: Text(
                              item.wantToFindRide ? '找車搭乘' : '提供搭乘',
                              style: TextStyle(
                                color: item.wantToFindRide
                                    ? Colors.orange[900]
                                    : Colors.lightBlue[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              showDetailsDialog(context, item);
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),
                          TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text("確認取消預約？"),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            context.read<ListItemProvider>().cancelReserved();
                                            editList(listId: item.listId);
                                          },
                                          child: const Text("確認取消"),
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
                              },
                              child: const Text('取消預約')
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
