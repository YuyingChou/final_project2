import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:fluttertoast/fluttertoast.dart';

class addBook extends StatefulWidget {
  @override
  _addBook createState() => _addBook();
}
class _addBook extends State<addBook> {
  late String bookname1;
  late String isbn1;
  late String phone1;
  late String place1;
  late String describe1;

  final booknameController = TextEditingController();
  final isbnController = TextEditingController();
  final phoneController = TextEditingController();
  final placeController = TextEditingController();
  final describeController = TextEditingController();

  DateTime selectedDateTime =DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> a = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    String loginname = a['loginname'];
    String i= a['traderid'];
    final appBar = AppBar(
      title: const Text('訂購教科書資訊',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
    );

    final bookname= TextField(
      controller: booknameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: '書名',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    final isbn= TextField(
      controller: isbnController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: 'ISBN',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    final phone= TextField(
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
    );

    final place= TextField(
      controller: placeController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: '取書地點',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    final describe= TextField(
      controller: describeController,
      maxLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: '簡述',
        labelStyle: TextStyle(fontSize: 20),
        hintText: 'ex. 資工四甲用書',
      ),
    );

    final transactionadd = ElevatedButton(
        child: const Text('確定'),
        onPressed: () async {
          if (booknameController.text.isEmpty ||
              isbnController.text.isEmpty ||
              phoneController.text.isEmpty ||
              placeController.text.isEmpty||
              describeController.text.isEmpty){
            showEmptyFieldsError(context);
          }
          else{
            bookname1=booknameController.text;
            isbn1=isbnController.text;
            phone1=phoneController.text;
            place1=placeController.text;
            describe1=describeController.text;
            await posttextbookData(bookname1,isbn1,0,0,loginname,i,place1,phone1,0,selectedDateTime,describe1,DateTime(0),"","","",0,DateTime(0));
            Navigator.pop(context,true);
            showaddbookResult(context);
          }
        }
    );
    final cancel = ElevatedButton(
        child: const Text('取消'),
        onPressed: () {
          Navigator.pop(context,true);
        }
    );

    final widget =Container(
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.all(5),
                  child: bookname),
              Container(
                  margin: const EdgeInsets.all(5),
                  child: isbn),
              Container(
                  margin: const EdgeInsets.all(5),
                  child: phone),
              Container(
                  margin: const EdgeInsets.all(5),
                  child: place),
              Container(
                child: Row(
                  children: [
                    Text(
                      '預計關閉時間: ${selectedDateTime.toLocal()}',
                      style: TextStyle(fontSize: 15),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context),
                      child: Text('選擇'),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: const EdgeInsets.all(5),
                  child: describe),
              Container(
                child: Row(
                  children: [
                    Container(
                      child: cancel,margin: const EdgeInsets.all(8),
                    ),
                    Expanded(
                        child:Container(
                          child: transactionadd,alignment: Alignment.bottomRight,margin: const EdgeInsets.all(8),
                        )
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );

    final page = Scaffold(
      appBar: appBar,
      body: widget,
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
    );

    return page;
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
void showaddbookResult(BuildContext context) {
  String message =  '書目新增成功!' ;

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