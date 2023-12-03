import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
String time="";
class p3 extends StatefulWidget {
  final String organizerid;

  p3({required this.organizerid});
  @override
  _p3 createState() => _p3();
}
class _p3 extends State<p3> {
  bool isdata = false;
  List<Textbook> textbooks=[];
  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> loadTextbooks() async {
    try {
      List<Textbook> fetchedTextbooks = await fetchData();
      setState(() {
        textbooks = fetchedTextbooks;
      });
    } catch (error) {
      print("Error loading textbooks: $error");
    }
  }
  Future<void> refreshbook() async {
    await loadTextbooks();
  }
  Future<List<Textbook>> fetchData() async {
    String apiUrl='https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookgetsomething/${widget.organizerid}';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      // Check if the response body is not empty
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> data = responseData['data'];
      print(data);
      List<Textbook> textbook = data.map((json) {
        return Textbook.fromJson(json);
      }).toList();
      print('載入成功');
      setState(() {
        textbook=textbook;
        textbooks = textbook;
      });
      return textbooks;
    } else {
      throw Exception('Failed to load transactions');
    }
  }
  void checkData() {
    if (textbooks.isNotEmpty) {
      setState(() {
        isdata = true;
      });
    } else {
      setState(() {
        isdata = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    checkData();
    final appBar = AppBar(
      title: const Text('我的代訂書',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
    );
     _OrganizeBookCard(context, index, dataList) {
      void _showTimeDialog(int p) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("更新關閉時間:"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(child: Text("原關閉時間:${DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      dataList[p].closingTime)}"),),
                  Container(child: DateTimePickerWidget(),),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await updateTextbookclosingtime(
                        dataList[p].id, DateTime.parse(time));
                    Navigator.pop(context);
                    showupdate();
                    refreshbook();
                  },
                  child: const Text("確定"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    refreshbook();
                  },
                  child: const Text("取消"),
                ),
              ],
            );
          },
        );
      }
      final ordernumber = ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(1),
        ),
        child: Text("目前訂購數量: ${dataList[index].quantity}", style: const TextStyle(fontSize: 3)),
        onPressed: () => _showTimeDialog(index),
      );

      final delete = ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(const EdgeInsets.all(1.0)),
        ),
        child: const Text('刪除', style: TextStyle(fontSize: 5)),
        onPressed: () {
          setState(() {
            deleteTextbook(dataList[index].id);
            deletesomeTextbookOrder(dataList[index].id);
            refreshbook();
          });
          showdelete();
        },
      );

     // final endCompute = ElevatedButton(
     //   style: ButtonStyle(
     //     padding: MaterialStateProperty.all(const EdgeInsets.all(1.0)),
     //     backgroundColor: MaterialStateProperty.all<Color>(
     //         Colors.white),
      //  ),
     //   child: const Text(
     //       '結束統計', style: TextStyle(fontSize: 5, color: Colors.black)),
      //  onPressed: () {
      //    showDialog(
      //      context: context,
       //       return AlertDialog(
      //          title: const Text('確認結束統計'),
      //          content: const Text('您確定要結束統計嗎？(即將送出訂單給書商，一旦送出不可刪除!)'),
      //          actions: <Widget>[
      //            TextButton(
      //              onPressed: () {
      //                Navigator.of(context).pop();
      //                refreshbook();
      //              },
      //              child: const Text('取消'),
      //            ),
      //            TextButton(
      //              onPressed: () async {
      //              await updateTextbookstatus(dataList[index].id, 1);
      //                Navigator.of(context).pop();
      //                  setState(() {
      //                  refreshbook();
      //                });
      //              },
      //              child: const Text('確定'),
       //           ),
      //          ],
      //        );
      //      },
      //    );
      //  },
      //);

      if (dataList[index].status == 1) {
        return Card(
            color: Color.fromARGB(255, 152, 176, 187),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(2),
                    child: Text("${dataList[index].name}",
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    child: Text("ISBN:${dataList[index].isbn}",
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    child: Text("簡述:${dataList[index].describe}",
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Container(
                            child: Text("訂購數量:${dataList[index].quantity}", style: const TextStyle(fontSize: 8),)
                        ),
                        Container(child: Text("   ")),
                        Container(
                            child: const Text("統計已截止",
                              style: TextStyle(fontSize: 8, color: Colors.red),)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
        );
      }
      else {
        return Card(
            color: Color.fromARGB(255, 255, 255, 255),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(2),
                    child: Text("${dataList[index].name}",
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    child: Text("ISBN:${dataList[index].isbn}",
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    child: Text("簡述:${dataList[index].describe}",
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: ordernumber,height: 15, width: 30, margin: const EdgeInsets.all(1),
                        ),
                        Container(
                          child: delete, height: 15, width: 30, margin: const EdgeInsets.all(1),
                        ),
                        //Container(
                        //  child: endCompute, height: 15, width: 30, margin: const EdgeInsets.all(1),),
                      ],
                    ),
                  ),
                ],
              ),
            )
         );
       }
    }

    final widget =SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        padding:const EdgeInsets.all(8.0),
        itemCount: textbooks.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder:(context,index) {
          return GestureDetector(
              onTap: () {
                _showbookdetailDialog(context,textbooks[index]);
              },
              child: _OrganizeBookCard(context, index, textbooks,)
          );
        },
      )
    );

    var nobook=const Text("沒有代訂書目");
    final widget1=Container(child: nobook,alignment: Alignment.center);

    final page = Scaffold(
      appBar: appBar,
      body: isdata?widget:widget1,
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
    );

    return page;
  }
}
void _showbookdetailDialog(context,datalist) {
  var dlg=AlertDialog(
    title: const Text("教科書詳情"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("書名: ${datalist.name}\n發起人: ${datalist.organizer}\nISBN:${datalist.isbn}\n聯絡方式: ${datalist.phone}\n"
            "交書地點: ${datalist.place}\n簡述: ${datalist.describe}\n預計關閉時間:${DateFormat('yyyy-MM-dd HH:mm:ss').format(datalist.closingTime)}"
        ),
        Text(datalist.bookseller.isNotEmpty?'書商已受理:\n書商:${datalist.bookseller}\n書商聯絡方式:${datalist.booksellerPhone}\n單價:${datalist.price}\n預計到貨時間:\n${datalist.bookWillArrivalTime}':'書商未受理'),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dlg,
  );
}
class DateTimePickerWidget extends StatefulWidget {
  @override
  _DateTimePickerWidgetState createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          time=_selectedDateTime.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Row(
            children: [
              Container(child: Text("選擇時間"),),
              Container(
                child: Text('${_selectedDateTime.toString()}',),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => _selectDateTime(context),
          child: const Text('選擇',style: TextStyle(fontSize: 15 )),
        ),
      ],
    );
  }
}
void showdelete() {
  String message = '書目已下架!' ;

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 20.0,
  );
}
void showupdate() {
  String message = '關閉時間更新成功!' ;

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 20.0,
  );
}
Future<void> deleteTextbook(String id) async {
  final response = await http.delete(
    Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookdeletesomething/$id'),
  );

  if (response.statusCode == 200) {
    print('Textbook deleted successfully');
  } else {
    print('Failed to delete textbook. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to delete textbook');
  }
}
Future<void> updateTextbookstatus(String textbookId, int newstatus) async {
  try {
    final response = await http.patch(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookupdatestatus/$textbookId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': newstatus,
      }),
    );

    if (response.statusCode == 200) {
      print('Textbook status updated successfully');
      print(jsonDecode(response.body));
    } else {
      // Handle error
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}
Future<void> updateTextbookclosingtime(String textbookId, DateTime newclosingtime) async {
  try {
    final response = await http.patch(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookupdateclosingtime/$textbookId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'closingtime': newclosingtime.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print('Textbook closingtime updated successfully');
      print(jsonDecode(response.body));
    } else {
      // Handle error
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}
Future<void> deletesomeTextbookOrder(String bookID) async {
  final url = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookorderdeletesome/$bookID';

  try {
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        // Textbook order deleted successfully
        print('教科書訂單已成功刪除');
      } else {
        // Error handling for unsuccessful deletion
        print('刪除失敗: ${responseData['message']}');
      }
    } else {
      // Handle other status codes
      print('Error ${response.statusCode}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error: $error');
  }
}