import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

late bool b;
final ValueNotifier<String> _total = ValueNotifier('');
int buyquantity=0,oneprice=0;
class buy extends StatefulWidget {
  @override
  _buyState createState() => _buyState();
}
class _buyState extends State<buy> {

  late String name1;
  late String phone1;
  late String note1;
  DateTime? buttonClickTime;
  late Transaction currentTransaction;
  void recordButtonClickTime() {
    setState(() {
      buttonClickTime = DateTime.now();
    });
  }
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  @override
  void initState() {
    super.initState();
    b=false;
  }
  Future<Transaction> fetchTransactionAtIndex(String t) async {
    late Transaction theTransaction;
    final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionget/$t';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Check if the response body is not empty
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      //print(jsonDecode(response.body));
      //print(responseData);
      print(responseData['data']);
      theTransaction = Transaction.fromJson(responseData['data']);

      print('載入成功');
      theTransaction=theTransaction;
      return theTransaction;
    } else {
      throw Exception('Failed to load transactions Response: ${response.body}' );
    }
  }
  Future<void> fetchData(String t) async {
    try {
      currentTransaction = await fetchTransactionAtIndex(t);
      print(currentTransaction);
    } catch (error) {
      print('Error fetching data: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> a = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    Transaction receivedTransaction = a['send'];
    String buyerid= a['traderid'];
    String loginname=a['loginname'];
    setState(() {
      fetchData(receivedTransaction.id);
    });
    bool checksame(Transaction previoustransaction,Transaction currenttransaction) {
      if(previoustransaction.transactionname==currenttransaction.transactionname&&previoustransaction.category==currenttransaction.category
          && previoustransaction.price==currenttransaction.price&&previoustransaction.description==currenttransaction.description
          &&previoustransaction.contact==currenttransaction.contact&&previoustransaction.place==currenttransaction.place&&previoustransaction.quantity<=currenttransaction.quantity
      ){
      return true;
      }
      else{
        return false;
      }
    }
    oneprice=receivedTransaction.price;
    String index=receivedTransaction.id;print(index);
    final appBar = AppBar(
      title: const Text('確認交易內容',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
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
    final detail= TextButton(
      child: const Text('商品詳情', style: TextStyle(fontSize: 15, color: Colors.blueGrey),),
      onPressed: () =>
          _transactiondetail(context, receivedTransaction),
    );
    var text=const Text('選擇交易數量:',style: TextStyle(fontSize: 20),);
    final btnD=_Dropdownwidge(receivedTransaction.quantity);
    var text1=const Text('單價:',style: TextStyle(fontSize: 20),);
    var text2= Text("$oneprice元",style: TextStyle(fontSize: 20),);
    var text3=const Text('總金額:',style: TextStyle(fontSize: 20),);
    var text4=const Text('交易地點:',style: TextStyle(fontSize: 20),);
    var text5= Text(receivedTransaction.place,style: TextStyle(fontSize: 20),);
    var text6=const Text('賣方聯絡方式:',style: TextStyle(fontSize: 20),);
    var text7= Text(receivedTransaction.contact,style: TextStyle(fontSize: 20),);
    var text8=const Text('上架人:',style: TextStyle(fontSize: 20),);
    var text9= Text(receivedTransaction.seller,style: TextStyle(fontSize: 20),);
    final buyitem = ElevatedButton(
        child: const Text('確定'),
        onPressed: () async {
          if (phoneController.text.isEmpty||buyquantity==0){
            showEmptyFieldsError(context);
          }
          else{
            //if(buyerid==receivedTransaction.sellerid){
            //  showError(context);
            //}
            //else{

              bool Same =await checksame(receivedTransaction,currentTransaction);
              name1=nameController.text;
              phone1=phoneController.text;
              note1=notesController.text;
              if(Same==true){
                recordButtonClickTime();
                int modify=receivedTransaction.quantity-buyquantity;
                TransactionManager transactionManager = TransactionManager();
                transactionManager.postTransactionOrder(loginname, buyerid,receivedTransaction.id, buttonClickTime.toString(),buyquantity, buyquantity*oneprice, receivedTransaction.seller,receivedTransaction.sellerid, note1,phone1, receivedTransaction.contact);
                if(receivedTransaction.quantity-buyquantity==0){
                  transactionManager.updateTransactionQuantity(index,0);
                  transactionManager.updateTransactionstatus(index,1);
                }
                else{
                  transactionManager.updateTransactionQuantity(index,modify);
                }
                Navigator.pop(context, true);
                showbuyResult(context, true);
              }
              else{
              Navigator.pop(context,true);
              showbuyResult(context, false);
              }
            //}
          }
        }
    );

    final cancel = ElevatedButton(
      child: const Text('取消'),
      onPressed: () => Navigator.pop(context,true),
    );

    final widget =Container(
      child: SingleChildScrollView(
          child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  child: detail,
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: phone,
                ),
                Container(
                  child: Row(children: [
                    Container(child: text,margin: const EdgeInsets.all(8)),
                    Container(child: btnD,margin: const EdgeInsets.all(8)),]),
                ),
                Container(
                  child: Row(children: [
                    Container(child: text1,margin: const EdgeInsets.all(8)),
                    Container(child: text2,margin: const EdgeInsets.all(8)),]),
                ),
                Container(
                  child: Row(children: [
                    Container(child: text3,margin: const EdgeInsets.all(8)),
                    Container(child: _showtotal(context, _total.value, null),margin: const EdgeInsets.all(8)),]),
                ),
                Container(
                  child: Row(children: [
                    Container(child: text6,margin: const EdgeInsets.all(8)),
                    Container(child: text7)]),
                ),
                Container(
                  child: Row(children: [
                    Container(child: text4,margin: const EdgeInsets.all(8)),
                    Container(child: text5)]),
                ),
                Container(
                  child: Row(children: [
                    Container(child: text8,margin: const EdgeInsets.all(8)),
                    Container(child: text9)]),
                ),
                TextField(controller: notesController,
                  decoration: const InputDecoration(
                      labelText: "備註",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0, // 设置边框宽度
                        ),
                      )
                  ),
                ),
                Container(
                    child: Row(
                      children: [
                        Container(
                          child: cancel,margin: const EdgeInsets.all(8),
                        ),
                        Expanded(
                            child:Container(
                              child: buyitem,alignment: Alignment.bottomRight,margin: const EdgeInsets.all(8),
                            )
                        )
                      ],
                    )
                )
              ]
          )
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

class _Dropdownwidge extends StatefulWidget{
  final int id;
  _Dropdownwidge(this.id);

  @override
  State<StatefulWidget> createState() {
    return _Dropdownwidgestate();
  }
}
class _Dropdownwidgestate extends State<_Dropdownwidge> {
  int? selectedValue;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> items = List.generate(widget.id, (index) {
      return DropdownMenuItem<int>(
        value: index + 1,
        child: Text((index + 1).toString(), style: TextStyle(fontSize: 20)),
      );
    });
    _total.value='';
    return
      DropdownButton<int>(
        items: items,
        value: selectedValue,
        onChanged: (int? value) {
          setState(() {
            selectedValue = value;
            buyquantity=value!;
            _total.value = (buyquantity*oneprice).toString();
          });
        },
        hint: const Text('請選擇', style: TextStyle(fontSize: 20)),
      );
  }
}
Widget _showtotal(BuildContext context, String total,Widget? child) {
  final widget = Text("$total元",
      style: const TextStyle(fontSize: 20));
  return widget;
}
void showbuyResult(BuildContext context, bool success) {
  String message = success ? '交易成功!' : '交易失敗!該商品已變更/下架';

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
void showEmptyFieldsError(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("錯誤"),
      content: Text("聯絡方式和數量須填寫。"),
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
void showError(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("錯誤"),
      content: Text("買方和賣方相同!"),
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
class TransactionManager {
  static const String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions';

  Future<void> postTransactionOrder(
      String buyer,String buyerid, String transactionid, String time, int quantity, int sum,
      String seller,String sellerid, String notes, String buyerphone, String sellerphone) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/transactionorder/add'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'buyer': buyer,
          'buyerid': buyerid,
          'seller': seller,
          'sellerid': sellerid,
          'transactionid': transactionid,
          'time': time,
          'quantity': quantity,
          'sum': sum,
          'notes': notes ?? '',
          'buyerphone': buyerphone,
          'sellerphone': sellerphone,
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final String transactionorderId = jsonResponse['transactionorderid'];
        print(transactionorderId);
        print('成功');
        // Handle the response if needed
      } else {
        print("失敗:${response.body} ");
        // Handle the error response
      }
    } catch (error) {
      print('Error: $error');
      // Handle other errors
    }
  }

  Future<void> updateTransactionQuantity(String transactionId, int newQuantity) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/transactionupdatequantity/$transactionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        print('Transaction quantity updated successfully');
        print(jsonDecode(response.body));
      } else {
        // Handle error
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> updateTransactionstatus(String transactionId, int newstatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/transactionupdatestatus/$transactionId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status': newstatus,
        }),
      );

      if (response.statusCode == 200) {
        print('Transaction status updated successfully');
        print(jsonDecode(response.body));
      } else {
        // Handle error
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}
void _transactiondetail(context, dataList) {

  var dlg=AlertDialog(
    title:Text(dataList.transactionname),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 60,child: Image.memory(Uint8List.fromList(dataList.image.data),height: 60,width: 60,)),
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
        Text("數量: ${dataList.quantity}\n類別: ${dataList.category}\n單價: ${dataList.price}元\n聯絡方式: ${dataList.contact}\n交易地點: ${dataList.place}\n交易品敘述: ${dataList.description}\n上架人: ${dataList.seller}"
        ),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dlg,
  );
}