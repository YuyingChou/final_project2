import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:nuuapp/trading_website/trading_website.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
Trader trader=Trader(
  id: ' ',
  name: ' ',
  studentID: ' ',
  phone: ' ',
  email: ' ',
  departmentclass: ' ',
);
class p1 extends StatefulWidget {
   final String traderid;

  p1({
    required this.traderid,
  });
  @override
  _p1State createState() => _p1State();
}
class _p1State extends State<p1> {
  bool isEditingMode = false;

  @override
  void initState() {
    super.initState();
    getTrader(widget.traderid);
  }
  Future<Trader> getTrader(String traderId) async {
    final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/traderget/$traderId';
    print(widget.traderid);
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Trader thetrader= Trader.fromJson(data['trader']);
        setState(() {
          thetrader=thetrader;
          trader = thetrader;
        });
        return trader;
      } else {
        print('Failed to load trader. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to load trader');
      }
    } catch (error) {
      print('Error loading trader: $error');
      throw Exception('Failed to load trader');
    }
  }
  void showEmptyFieldsError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("錯誤"),
        content: Text("所有資訊都必須填寫。"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('確定'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('個人資料',style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.brown,
    );

    var tname = Text("姓名: ${trader.name}",style: TextStyle(fontSize: 16));

    var tdepartmentclass = Text("科系班級:${trader.departmentclass}",style: TextStyle(fontSize: 16));
    final departmentclassController = TextEditingController();
    final departmentclass = TextField(
        controller: departmentclassController,
        decoration: const InputDecoration(
          labelText: '科系班級:',
          labelStyle: TextStyle(fontSize: 20),
          hintText: 'ex. 日資工四甲',
        )
    );
    departmentclassController.text="${trader.departmentclass}";

    var tstudentid=Text("學號: ${trader.studentID}",style: TextStyle(fontSize: 16));
    final studentidController = TextEditingController();
    final studentid= TextField(
      controller: studentidController,
      decoration: const InputDecoration(
        labelText: '學號:',
        labelStyle: TextStyle(fontSize: 20),
        hintText: 'ex. U0924060',
      ),
    );
    studentidController.text="${trader.studentID}";

    var tphone=Text("手機: ${trader.phone}",style: TextStyle(fontSize: 16));
    final phoneController = TextEditingController();
    final phone= TextField(
      controller: phoneController,
      decoration: const InputDecoration(
        labelText: '手機:',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );
    phoneController.text="${trader.phone}";

    var temail=Text("電子郵件: ${trader.email}",style: TextStyle(fontSize: 16));
    final emailController = TextEditingController();
    final email= TextField(
      controller: emailController,
      decoration: const InputDecoration(
        labelText: '電子郵件:',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );
    emailController.text="${trader.email}";

    final cancel = ElevatedButton(
        child: const Text('取消'),
        onPressed: () {
          setState(() {
            isEditingMode = false;
          });
        }
    );
    final change = ElevatedButton(
        child: const Text('修改/填寫'),
        onPressed: () {
          setState(() {
            isEditingMode = true;
          });
        }
    );
    final save = ElevatedButton(
        child: const Text('保存'),
        onPressed: () {
          if (departmentclassController.text.isEmpty ||
              studentidController.text.isEmpty ||
              phoneController.text.isEmpty ||
              emailController.text.isEmpty){
            showEmptyFieldsError(context);
            setState(() {
              isEditingMode = false;
            });
          }
          else{
            trader.departmentclass=departmentclassController.text;
            trader.studentID=studentidController.text;
            trader.phone=phoneController.text;
            trader.email=emailController.text;
            updateTrader(traderid,trader.studentID,trader.phone,trader.email,trader.departmentclass);
            setState(() {
              isEditingMode = false;
            });
          }

        }
    );

    final displaymode =Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(child: tname, alignment: Alignment.bottomLeft,margin: const EdgeInsets.all(10)),
            Container(child: tdepartmentclass,alignment: Alignment.bottomLeft, margin: const EdgeInsets.all(10)),
            Container(child: tstudentid,alignment: Alignment.bottomLeft, margin: const EdgeInsets.all(10)),
            Container(child: tphone,alignment: Alignment.bottomLeft, margin: const EdgeInsets.all(10)),
            Container(child: temail,alignment: Alignment.bottomLeft, margin: const EdgeInsets.all(10)),
            Container(child: change, alignment: Alignment.bottomRight, padding: const EdgeInsets.all(30))
          ],
        ),
      ),
    );

    final editmode =Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(child: tname,margin: const EdgeInsets.all(5),alignment: Alignment.bottomLeft,),
            Container(child: departmentclass,margin: const EdgeInsets.all(5)),
            Container(child: studentid, margin: const EdgeInsets.all(5)),
            Container(child: phone, margin: const EdgeInsets.all(5)),
            Container(child: email, margin: const EdgeInsets.all(5)),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(child: save, alignment: Alignment.bottomRight, padding: const EdgeInsets.all(30)),
                  Container(child: cancel, alignment: Alignment.bottomLeft, padding: const EdgeInsets.all(30)),
                ],
              ),
            )
          ],
        ),
      ),
    );

    final page = Scaffold(
      appBar: appBar,
      body: isEditingMode ? editmode : displaymode,
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
    );
    return page;
  }
}
Future<void> updateTrader(String traderid,String studentID,String phone,String email,String departmentclass) async {
  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/traderupdate/$traderid';
  final Map<String, dynamic> data = {
    'studentID': studentID,
    'phone': phone,
    'email': email,
    'departmentclass': departmentclass,
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
      print('Failed to update trader: ${response.statusCode}');
    }
  } catch (error) {
    print('Error updating trader: $error');
  }
}
