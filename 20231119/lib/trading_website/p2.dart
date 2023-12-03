import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

String selectedCategory = '';
int delete=0;
late String trader;
class p2 extends StatefulWidget {
  final String sellerid;

  p2({required this.sellerid});
  @override
  _p2 createState() => _p2();
}
class _p2 extends State<p2> {
  bool isdata = false;
  List<Transaction> transactions=[];

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> loadTransactions() async {
    try {
      List<Transaction> fetchedTransactions = await fetchData();
      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (error) {
      print("Error loading transactions: $error");
    }
  }
  Future<void> refresh() async {
    await loadTransactions();
  }
  Future<List<Transaction>> fetchData() async {
    String apiUrl='https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactiongetsomeone/${widget.sellerid}/0';
    print(widget.sellerid);
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      // Check if the response body is not empty
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> data = responseData['responseData']['data'];
      print(data);
      List<Transaction> transaction = data.map((json) {
        return Transaction.fromJson(json);
      }).toList();
      print('載入成功');
      setState(() {
        transaction=transaction;
        transactions = transaction;
      });
      return transactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }
  void _deleteProduct(String index) async {
    setState(() {
      updateTransactionQuantity(index,0);
    });
    if(delete==1){
      showdelete();
    }
  }
  Future<void> _editProduct(int index) async {
    selectedCategory=transactions[index].category;

    final TextEditingController tnameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController placeController = TextEditingController();
    final TextEditingController otherController = TextEditingController();
    final category=const Text('類別: ',style: TextStyle(fontSize:13),);

    tnameController.text = transactions[index].transactionname;
    numberController.text = transactions[index].quantity.toString();
    priceController.text = transactions[index].price.toString();
    phoneController.text = transactions[index].contact;
    placeController.text = transactions[index].place;
    otherController.text = transactions[index].description;

    final name=Text("上架人:${transactions[index].seller}");
    final btnd = _Dropdownwidge();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("修改交易品資料"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                name,
                TextField(controller: tnameController,
                    decoration: InputDecoration(labelText: "交易品名稱")),
                Container(
                  child: Row(
                    children: [
                      Container(child: category),
                      Container(child: btnd),
                    ],
                  ),
                ),
                TextField(controller: numberController,
                    decoration: InputDecoration(labelText: "交易品數量")),
                TextField(controller: priceController,
                    decoration: InputDecoration(labelText: "交易品單價")),
                TextField(controller: phoneController,
                    decoration: InputDecoration(labelText: "聯絡方式")),
                TextField(controller: placeController,
                    decoration: InputDecoration(labelText: "交易地點")),
                TextField(controller: otherController,
                    decoration: InputDecoration(labelText: "交易品敘述")),
              ],
            ),
          ),

          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                refresh();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if(tnameController.text!=""&&selectedCategory!=""&&numberController.text!=""&&priceController.text!=""&&phoneController.text!=""&&placeController.text!=""&&otherController.text!=""){
                  setState(() {
                    updateTransaction(transactions[index].id, tnameController.text,selectedCategory,  int.parse(numberController.text), int.parse(priceController.text),otherController.text, placeController.text, phoneController.text);
                  });
                  Navigator.of(context).pop();
                  showmodifyResult(context,true);
                }
                else{
                  Navigator.of(context).pop();
                  showmodifyResult(context,false);
                }
                refresh();
              },
              child: Text("保存"),
            ),
          ],
        );
      },
    );
  }
  Widget _personalsellitem(context, index, dataList) {
    final delete = ElevatedButton(
        child: const Text('刪除',style: TextStyle(fontSize:5)),
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(1.0)),),
        onPressed: () {
          _deleteProduct(dataList[index].id);
          updateTransactionstatus(dataList[index].id,1);
          refresh();
        }
    );
    final modify = ElevatedButton(
        child: const Text('修改',style: TextStyle(fontSize:5)),
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(1.0)),),
        onPressed: () {
          _editProduct(index);
          refresh();
        }
    );

    return Card(
        color: Color.fromARGB(255, 255,255, 255),
        child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      child: Container(
                        child: Image.memory(Uint8List.fromList(dataList[index].image.data),
                          fit: BoxFit.fill,
                        ),
                      )
                  ),
                  Container(
                    child: Text(dataList[index].transactionname,style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    child: Text("類別: ${dataList[index].category}",style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    child: Text("數量: ${dataList[index].quantity}  單價: ${dataList[index].price}元",style: TextStyle(fontSize: 10),overflow: TextOverflow.ellipsis,),
                  ),
                  Expanded(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(child: delete, height: 20, width: 25),
                            Container(),
                            Container(child: modify, height: 20, width: 25, alignment: Alignment.bottomRight,)
                          ],
                        ),
                      )
                  )
                ],
              )
            ],
          ),
        )
    );
  }
  void checkData() {
    if (transactions.isNotEmpty) {
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
      title: const Text('我的上架物',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
    );

    final widget =
    SingleChildScrollView(
      child:GridView.builder(
        shrinkWrap: true,
        padding:const EdgeInsets.all(8.0),
        itemCount: transactions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder:(context,index) {
          return GestureDetector(
            onTap: () {
              _showdetail(context, index, transactions);
            },
            child: _personalsellitem(context, index,  transactions),
          );
        },
      )
    );

    var nodata=const Text("沒有已上架交易物");
    final widget1=Container(child: nodata,alignment: Alignment.center);

    final page = Scaffold(
      appBar: appBar,
      body: isdata?widget:widget1,
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
    );

    return page;
  }
}

class _Dropdownwidge extends StatefulWidget{
  @override
  _Dropdownwidgestate createState() => _Dropdownwidgestate();
}
class _Dropdownwidgestate extends State<_Dropdownwidge> {

  int? selectedValue;

  @override
  Widget build(BuildContext context) {
    final btn = DropdownButton(
      items: const <DropdownMenuItem> [
        DropdownMenuItem(
          child:  Text('書籍', style: TextStyle(fontSize: 13),),
          value: 1,
        ),
        DropdownMenuItem(
          child:  Text('生活用品', style: TextStyle(fontSize: 13),),
          value: 2,
        ),
        DropdownMenuItem(
          child:  Text('電子產品', style: TextStyle(fontSize: 13),),
          value: 3,
        ),
        DropdownMenuItem(
          child:  Text('其他', style: TextStyle(fontSize: 13),),
          value: 4,
        )
      ],
      onChanged: (dynamic value) {
        setState(() {
          selectedValue = value as int;
          selectedCategory = getCategory(value);
        });
      },

      hint: Text(selectedCategory, style: TextStyle(fontSize: 13),),
      value: selectedValue,
    );

    return btn;
  }
  String getCategory(value) {
    if (value == 1) {
      return '書籍';
    } else if (value == 2) {
      return '生活用品';
    } else if (value == 3) {
      return '電子產品';
    } else {
      return '其他';
    }
  }
}
void showmodifyResult(BuildContext context, bool success) {
  String message = success ? '交易物資料修改成功!' : '所有資料都須填寫!';

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
void showdelete() {
  String message = '交易物已下架!' ;

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
_showdetail(context, index, dataList){
  var dlg=AlertDialog(
    title:Text(dataList[index].transactionname),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height:60,
          child: Image.memory(Uint8List.fromList(dataList[index].image.data),height: 50,width: 50,),
        ),
        const Divider(),
        Text("數量: ${dataList[index].quantity}\n類別: ${dataList[index].category}\n單價: ${dataList[index].price}元\n聯絡方式: ${dataList[index].contact}\n交易地點: ${dataList[index].place}\n交易品敘述: ${dataList[index].description}\n上架人: ${dataList[index].seller}"
        ),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dlg,
  );
}

Future<void> updateTransaction(String transactionid,String transactionname,String category,int quantity,int price,String description,String place,String contact) async {
  final url = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionupdatemore/$transactionid';

  final Map<String, dynamic> data = {
    'transactionname': transactionname,
    'category': category,
    'quantity': quantity,
    'price': price,
    'description': description,
    'place': place,
    'contact': contact,
  };
  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body:jsonEncode(data),
    );
    if (response.statusCode == 200) {
      delete=1;
      //final data = json.decode(response.body);
      print("success");
    } else {
      print('Failed to update transaction: ${response.statusCode}');
    }
  } catch (error) {
    print('Error updating transaction: $error');
  }
}
Future<void> updateTransactionQuantity(String transactionId, int newQuantity) async {
  try {
    final response = await http.patch(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionupdatequantity/$transactionId'),
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
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionupdatestatus/$transactionId'),
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