import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class booksellerpage extends StatefulWidget {

  const booksellerpage({Key? key}) : super(key: key);
  @override
  State<booksellerpage> createState() => _booksellerpage();
}
class _booksellerpage extends State<booksellerpage>{
  bool isdata = false;
  DateTime? buttonClickTime;
  List<Textbook> textbooks=[];
  @override
  void initState() {
    super.initState();
    fetchTextbooks();
  }
  void recordButtonClickTime() {
    setState(() {
      buttonClickTime = DateTime.now();
    });
  }

  void _confirmDialog(BuildContext context,Textbook dataList,DateTime datetime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('確認已到貨'),
          content: Text('確認書商為您，確認書籍已到並通知訂購人!'),
          actions: [
            TextButton(
              onPressed: () async {
                await updateTextbookgetbookstatus(dataList.id,1, datetime);
                Navigator.of(context).pop();
                refreshbook();
              },
              child: Text('確定'),
            ),
          ],
        );
      },
    );
  }
  Widget _hasseller(context, index,dataList){
    final arrival = ElevatedButton(
        child: const Text('已到貨'),
        onPressed: () {
          Navigator.pop(context);
          recordButtonClickTime();
          _confirmDialog(context,dataList[index],buttonClickTime!);
          refreshbook();
        }
    );
    return AlertDialog(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check,color: Colors.green,size: 30,),
          Text("  "),
          Text("此單已受理", textAlign: TextAlign.center),
        ],
      ),
      content: Form(
        key: GlobalKey<FormState>(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(child: Text("書商:${dataList[index].bookseller}")),
              Container(child: Text("單價:${dataList[index].price}")),
              Container(child: Text("聯絡方式:${dataList[index].booksellerPhone}")),
              Container(child: Text("預計到貨時間:")),
              Container(child: Text(dataList[index].bookWillArrivalTime)),
              Container(child: Text("接受訂單日/時:")),
              Container(child: Text("${DateFormat('yyyy-MM-dd HH:mm:ss').format(dataList[index].booksellerReceivedTime)}")),
              Container(child: arrival, padding: const EdgeInsets.all(8)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            refreshbook();
          },
          child: Text('確定'),
        ),
      ],
    );
  }
  Widget _hasnoseller(context, index, dataList){
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final priceController = TextEditingController();
    final timeController = TextEditingController();
    return AlertDialog(
      title:Text("接受訂單",textAlign: TextAlign.center),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                      ),
                    ),
                    labelText: '書商',
                    labelStyle: TextStyle(fontSize: 20),
                    hintText: 'ex. 高點出版',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '此欄位為必填';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                child: TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                      ),
                    ),
                    labelText: '聯絡方式',
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '此欄位為必填';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                child: TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                      ),
                    ),
                    labelText: '單價',
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '此欄位為必填';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                child: TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                      ),
                    ),
                    labelText: '預計到貨時間',
                    labelStyle: TextStyle(fontSize: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '此欄位為必填';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            refreshbook();
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()){
              recordButtonClickTime();
              await updateTextbook(dataList[index].id,int.parse(priceController.text),buttonClickTime!,nameController.text,phoneController.text,timeController.text);
              Navigator.pop(context);
              showreceive();
              refreshbook();
            }
          },
          child: Text('確定'),
        ),
      ],
    );
  }

  void checkData() {
    if (textbooks.isNotEmpty) {
      setState(() {
        isdata = true;
      });
    }
    else {
      setState(() {
        isdata = false;
      });
    }
  }
  Future<List<Textbook>> fetchTextbooks() async {
    const String apiUrl= 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookget/1/0';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> data = responseData['data'];
      print(data);
      List<Textbook> textbook = data.map((json) => Textbook.fromJson(json)).toList();
      print('載入成功');
      //
      setState(() {
        textbook=textbook;
        textbooks = textbook;
      });
      return textbooks;
    } else {
      throw Exception('Failed to load textbooks');
    }
  }
  Future<void> loadTextbooks() async {
    try {
      List<Textbook> fetchedTextbooks = await fetchTextbooks();
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
  @override
  Widget build(BuildContext context) {
    String id= ModalRoute.of(context)!.settings.arguments as String;
    checkData();
    final appBar = AppBar(
      title: const Text('書商專區',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
    );

    final widget = textbooks.isNotEmpty ?
    SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        padding:const EdgeInsets.all(8.0),
        itemCount: textbooks.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder:(context,index) {
          if (textbooks.isNotEmpty && index < textbooks.length) {
            return GestureDetector(
              onTap: () {
                if(textbooks[index].bookseller.isNotEmpty&&textbooks[index].booksellerPhone.isNotEmpty&&textbooks[index].bookWillArrivalTime.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) =>_hasseller(context, index, textbooks),
                  );
                }
                else {
                  showDialog(
                    context: context,
                    builder: (context) =>
                      _hasnoseller(context, index, textbooks),
                  );
                }
              },
              child: _BookItem(context, index, textbooks),
            );
          }
        },
      )
    ) : Container();
    var nobook=const Text("沒有訂單");
    final widgetnobook=Container(child: nobook,alignment: Alignment.center);
    final page = Scaffold(
      appBar: appBar,
      body: isdata?widget:widgetnobook,
      backgroundColor: const Color.fromARGB(255, 251, 251, 251),
    );

    return page;
  }
}
Widget _BookItem(context, index, dataList){
  return Card(
      color: Color.fromARGB(255,  152, 176, 187),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(child: Icon(Icons.assignment_outlined,size: 20,),),
            Container(
              child: Text("${dataList[index].name}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
            Container(
              child: Text("ISBN:${dataList[index].isbn}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
            Container(
              child:Text("訂購人:${dataList[index].organizer}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
            Container(
              child: Text("聯絡方式:${dataList[index].phone}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
            Container(
              child: Text("簡述:${dataList[index].describe}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
            Container(
              child: Text("地點:${dataList[index].place}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
            Container(
              child: Text("訂購數量:${dataList[index].quantity}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),
            ),
          ],
        ),
      )
  );
}
void showreceive() {
  String message = '接單成功!' ;

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
Future<void> updateTextbook(String textbookid,int price,DateTime booksellerreceivedtime,String bookseller,String booksellerphone,String bookwillarrivaltime) async {
  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookupdatemore/$textbookid';
  final Map<String, dynamic> data = {
    'price': price,
    'booksellerreceivedtime': booksellerreceivedtime.toUtc().toIso8601String(),
    'bookseller': bookseller,
    'booksellerphone': booksellerphone,
    'bookwillarrivaltime': bookwillarrivaltime,
  };
  try {
    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      //final data = json.decode(response.body);
      print("success"); // Success message from the server
    } else {
      print('Failed to update textbook: ${response.statusCode}');
    }
  } catch (error) {
    print('Error updating textbook: $error');
  }
}
Future<void> updateTextbookgetbookstatus(String textbookId, int newgetbookstatus,DateTime time) async {
  try {
    final response = await http.patch(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookupdategetbookstatus/$textbookId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'getbookstatus': newgetbookstatus,
        'bookarrivaltime': time.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print('Textbook getbookstatus updated successfully');
      print(jsonDecode(response.body));
    } else {
      // Handle error
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}