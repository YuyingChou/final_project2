import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuuapp/ScooterUber/addUberList.dart';
import 'package:http/http.dart' as http;
import '../../Providers/UberList_provider.dart';
import '../detail_dialog.dart';
import 'package:nuuapp/ScooterUber/editList.dart';

void main() => runApp(const MyUberList());

class MyUberList extends StatefulWidget {
  final VoidCallback? onItemAdded;

  const MyUberList({Key? key, this.onItemAdded}) : super(key: key);

  @override
  MyUberListState createState() => MyUberListState();

  // static final GlobalKey<MyUberListState> uberListKey =
  //     GlobalKey<MyUberListState>();
}

class MyUberListState extends State<MyUberList> {
  List<UberItem> uberList = [];

  @override
  void initState() {
    super.initState();
    loadMyCards(context);
  }

  Future<void> loadMyCards(BuildContext context) async {
    String userId = context.read<UserProvider>().userId;
    try {
      List<UberItem> updatedList = await fetchData(userId);
      context.read<UberListProvider>().setList(updatedList);
    } catch (e) {
      print('載入時錯誤:$e');
    }
  }
  Future<List<UberItem>> fetchData(String userId) async {
    String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/searchMyList?userId=$userId';

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


  Future<void> onDelete(BuildContext context, listId, index) async {
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
          msg: "刪除成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        await loadMyCards(context);

        if (uberList.isNotEmpty) {
          index = index.clamp(0, uberList.length - 1);
          uberList.removeAt(index);
        }

        Navigator.of(context).pop();
      } else {
        throw Exception('刪除失敗');
      }
    } catch (e) {
      print('刪除錯誤: $e');
      // 处理删除异常
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
                              "你目前沒有建立任何清單",
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => EditUberList(index: index)),
                                        ).then((result) {
                                          if (result == true) {
                                            loadMyCards(context);
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: item.reserved == true ?
                                              const Text(
                                                '已經有人預約了你的行程，你確定要刪除嗎?',
                                                style: TextStyle(fontSize: 18),
                                              ) :
                                              const Text(
                                                '確認刪除？'
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    await onDelete(context, item.listId, index);
                                                  },
                                                  child: const Text('確認刪除'),
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        child: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddUberList()),
                          ).then((result) {
                            if (result == true) {
                              loadMyCards(context);
                            }
                          });
                        },
                      ),
                    ],
                  )
              ),
            ],
          ),
        );
      },
    );
  }
}
