import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nuuapp/Providers/UberList_provider.dart';


class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  _SearchBottomSheetState createState() => _SearchBottomSheetState();

}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  List<UberItem> uberList = [];

  DateTime selectedDateTime = DateTime.now();
  bool wantToFindRide = false;
  bool wantToOfferRide = false;

  TextEditingController startingLocationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  //預設不選取checkbox，會將所有需求回傳
  bool wantToFindRideChecked = true;
  bool wantToOfferRideChecked = true;

  @override
  void initState() {
    super.initState();
    startingLocationController = TextEditingController();
    destinationController = TextEditingController();
  }

  Future<void> search(BuildContext context) async {
    final String startingLocation = startingLocationController.text;
    final String destination = destinationController.text;

    Future<http.Response> searchList(
        String startingLocation,
        String destination,
        DateTime selectedDateTime,
        bool wantToFindRideChecked,
        bool wantToOfferRideChecked) {
      // 使用函數參數中的搜尋條件
      String query = '';
      if(startingLocationController.text.isNotEmpty){
        query += 'startingLocation=$startingLocation&';
      }

      if (destinationController.text.isNotEmpty) {
        query += 'destination=${destinationController.text}&';
      }

      query += 'selectedDateTime=${selectedDateTime.toIso8601String()}&';

      if (wantToFindRideChecked == true && wantToOfferRideChecked == false) {
        query += 'wantToFindRide=true&';
      }

      if (wantToOfferRideChecked == true && wantToFindRideChecked == false) {
        query += 'wantToOfferRide=true&';
      }

      String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/searchList?$query';

      return http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
    }

    try {
      // 調用 searchList 函數發送 GET 請求
      final response = await searchList(
          startingLocation,
          destination,
          selectedDateTime,
          wantToFindRideChecked,
          wantToOfferRideChecked
      );


      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];

        uberList = data.map((json) {
          return UberItem.fromJson(json);
        }).toList();

        Provider.of<UberListProvider>(context, listen: false)
            .setList(uberList);
        Navigator.of(context).pop();
      } else {
        print('搜尋失敗: ${response.body}');
      }
    } catch (e) {
      // 發生錯誤
      print('異常: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    controller: startingLocationController,
                    decoration: const InputDecoration(
                      hintText: '出發地關鍵字',
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    controller: destinationController,
                    decoration: const InputDecoration(
                      hintText: '目的地關鍵字',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('出發時間:', style: TextStyle(fontSize: 20)),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime)} 之後',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _selectDateTime(context);
                    },
                    child: const Text('選擇日期和時間', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                CheckboxForRide(
                  onChanged: (value) {
                    setState(() {
                      wantToFindRideChecked = value!;
                      wantToOfferRideChecked = false;
                    });
                  },
                ),
                const SizedBox(width: 16.0),
                const Text('我要找車搭乘', style: TextStyle(fontSize: 20)),
                CheckboxForRide(
                  onChanged: (value) {
                    setState(() {
                      wantToOfferRideChecked = value!;
                      wantToFindRideChecked = false;
                    });
                  },
                ),
                const SizedBox(width: 16.0),
                const Text('我要提供座位', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  search(context);
                },
                child: const Text('開始搜尋', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );

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

class CheckboxForRide extends StatefulWidget {
  final ValueChanged<bool?> onChanged;

  const CheckboxForRide({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<CheckboxForRide> createState() => _CheckboxForRideState();
}

class _CheckboxForRideState extends State<CheckboxForRide> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.green;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
        widget.onChanged(value);
      },
    );
  }
}
