import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nuuapp/Providers/UberList_provider.dart';
import 'package:provider/provider.dart';

class EditUberList extends StatefulWidget {
  final int index;
  const EditUberList({super.key, required this.index});

  @override
  _EditUberListState createState() => _EditUberListState();
}

class _EditUberListState extends State<EditUberList> {

  late DateTime selectedDateTime = DateTime.now();
  late bool wantToFindRide = false;
  late bool wantToOfferRide = false;

  TextEditingController startingLocationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController payTextController = TextEditingController();
  int? payValue;
  String? errorText;

  @override
  void initState() {
    super.initState();

    final int index = widget.index;
    final item = context.read<UberListProvider>().uberList[index];
    final String payText = item.pay.toString();
    startingLocationController = TextEditingController(text: item.startingLocation);
    destinationController = TextEditingController(text:  item.destination);
    selectedDateTime = item.selectedDateTime;
    wantToOfferRide = item.wantToOfferRide;
    wantToFindRide = item.wantToFindRide;
    notesController = TextEditingController(text: item.notes);
    payTextController = TextEditingController(text: payText);
  }

  Future<void> editUberList(String listId) async {
    final String startingLocation = startingLocationController.text;
    final String destination = destinationController.text;
    final String notes = notesController.text;

    Future<http.Response> editList(String startingLocation, String destination, DateTime selectedDateTime,bool wantToFindRide,bool wantToOfferRide) {
      String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/editList/$listId';

      final Map<String, dynamic> listData = {
        'startingLocation': startingLocation,
        'destination': destination,
        'selectedDateTime': selectedDateTime.toIso8601String(),
        'wantToFindRide': wantToFindRide,
        'wantToOfferRide': wantToOfferRide,
        'notes': notes,
        'pay': payValue
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
      // 調用 editList 函數發送 PUT 請求
      final response = await editList(startingLocation, destination, selectedDateTime, wantToFindRide, wantToOfferRide);

      if (response.statusCode == 200) {
        // 編輯成功
        final jsonResponse = json.decode(response.body);
        print('編輯成功，清單 ID: ${jsonResponse['_id']}');
        Fluttertoast.showToast(
          msg: "編輯成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print('編輯失敗: ${response.body}');
      }
    } catch (e) {
      // 發生錯誤
      print('編輯失敗: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final int index = widget.index;
    final listId = context.read<UberListProvider>().uberList[index].listId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯共乘需求'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    const Text(
                      '出發地：',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 20),
                        controller: startingLocationController,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Text(
                      '目的地：',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 20),
                        controller: destinationController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('出發時間：',style: TextStyle(fontSize: 20)),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime),
                          style: const TextStyle(fontSize: 20)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectDateTime(context);
                      },
                      child: const Text('選擇日期和時間',style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    const Text('我要',style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          wantToFindRide = true;
                          wantToOfferRide = false;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(wantToFindRide ? Colors.orangeAccent[200] : Colors.grey[300]),
                      ),
                      child: const Text('找車搭',style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          wantToFindRide = false;
                          wantToOfferRide = true;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(wantToOfferRide ? Colors.orangeAccent[200] : Colors.grey[300]),
                      ),
                      child: const Text('提供座位',style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Text(
                      '報酬：',
                      style: TextStyle(fontSize: 20),
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 20),
                        controller: payTextController,
                        onChanged: (value) {
                          try {
                            int intValue = int.parse(value);
                            if (isValid(intValue)) {
                              setState(() {
                                errorText = null;
                              });
                            } else {
                              setState(() {
                                errorText = '請輸入正整數';
                              });
                            }
                          } catch (e) {
                            setState(() {
                              errorText = '請輸入有效的整數';
                            });
                          }
                        },
                        decoration: InputDecoration(
                          errorText: errorText,
                        ),
                      ),
                    ),
                    const Expanded(
                        child: Text(
                          'NT\$',
                          style: TextStyle(fontSize: 20),
                        )
                    )
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '備註：',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(
                    height: 100.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextField(
                        style: const TextStyle(fontSize: 20),
                        controller: notesController,
                        decoration: const InputDecoration(
                          hintText: '請填入至多100字的備註，可能包括安全帽需求、行車習慣等',
                          hintMaxLines: 2,
                        ),
                        maxLines: null,
                      ),
                    )
                ),
              ],
            ),
          )
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () async {
            if (payTextController.text.isNotEmpty) {
              int? parsedValue = int.tryParse(payTextController.text);
              if (parsedValue != null && parsedValue >= 0) {
                // 輸入是有效的正整數
                payValue = parsedValue;
              } else {
                Fluttertoast.showToast(
                  msg: "報酬請輸入有效的正整數",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                return; // 不執行 addUberList
              }
            }
            await editUberList(listId);
            Navigator.of(context).pop(true);
          },
          child: const Text('編輯完成',style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
  bool isValid(int value) {
    return (value > 0);
  }
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (!context.mounted) return;
    if (picked != null && picked != selectedDateTime) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );
      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }
}
