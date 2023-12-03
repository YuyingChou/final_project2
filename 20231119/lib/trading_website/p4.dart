import 'package:flutter/material.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

late Transaction transactions;
late Textbook textbooks;
class p4 extends StatefulWidget {
  final String userid;

  p4({required this.userid});
  @override
  _p4 createState() => _p4();
}
class _p4 extends State<p4> {
  List<dynamic> transactionOrdersbuy = [];
  List<dynamic> transactionOrdersSell = [];
  List<dynamic> textbookOrdersbuy = [];
  List<dynamic> textbookarrive = [];
  List<TextbookOrder> textbookorders=[];
  @override
  void initState() {
    super.initState();
    fetchTransactionOrderbuy();
    fetchTransactionOrdersell();
    fetchTextbookOrderbuyer();
    fetchTextbookarrive();
  }
  Future<List<TextbookOrder>> fetchpeoplewhobuy(String textbookId) async {
    final response = await http.get(
      Uri.parse(
          'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookordergetbybookid/$textbookId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      List<TextbookOrder> sometextbookorders= data.map((json) {
        return TextbookOrder.fromJson(json);
      }).toList();
      setState(() {
        sometextbookorders=sometextbookorders;
        textbookorders = sometextbookorders;
      });
      return textbookorders;

    } else {
      throw Exception(
          'Failed to fetch textbook details. Status Code: ${response.statusCode}');
    }
  }
  Future<void> fetchTextbookarrive() async {
    final response = await http.get(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookgetbook/${widget.userid}/1'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          textbookarrive = data['data'];
        });
      } else {
        // Handle error
        print('Error: ${data['error']}');
      }
    } else {
      // Handle error
      print('Failed to load data. Status Code: ${response.statusCode}');
    }
  }
  Future<void> fetchTextbookOrderbuyer() async {
    final response = await http.get(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookordergetbybuyer/${widget.userid}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          textbookOrdersbuy = data['textbookorders'];
        });
      } else {
        // Handle error
        print('Error: ${data['error']}');
      }
    } else {
      // Handle error
      print('Failed to load data. Status Code: ${response.statusCode}');
    }
  }
  Future<void> fetchTransactionOrderbuy() async {
    final response = await http.get(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionordergetbybuyer/${widget.userid}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          transactionOrdersbuy = data['transactionorder'];
        });
      } else {
        // Handle error
        print('Error: ${data['error']}');
      }
    } else {
      // Handle error
      print('Failed to load data. Status Code: ${response.statusCode}');
    }
  }
  Future<void> fetchTransactionOrdersell() async {
    final response = await http.get(
      Uri.parse(
          'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionordergetbyseller/${widget.userid}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          transactionOrdersSell = data['transactionorder'];
        });
      } else {
        // Handle error
        print('Error: ${data['error']}');
      }
    } else {
      // Handle error
      print('Failed to load data. Status Code: ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: const Text('通知',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
    );
    print('transactionOrdersbuy: $transactionOrdersbuy');
    print('transactionOrdersSell: $transactionOrdersSell');
    Widget buildList(List<dynamic> List) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: List.length,
        itemBuilder: (context, index) {
          var order = List[index];
          String orderType;

          if (transactionOrdersbuy.contains(order)) {
            orderType = '購買單';
            return Container(
              color: Color.fromRGBO(214, 186, 150, 1),
              child: ListTile(
                onTap: () async {
                  await fetchTransactionDetails(order['transactionid']);
                  _showdetail(context,transactions);
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$orderType\n購買日/時: ${order['time']}'),
                    Container(
                      width: 30,
                      child: ElevatedButton(
                        onPressed: () async{
                          await fetchTransactionDetails(order['transactionid']);
                          if(transactions.status==1){
                            updateTransactionstatus(transactions.id,0);
                          }
                          int a=order['quantity'];
                          int b=transactions.quantity;
                          updateTransactionQuantity(transactions.id,a+b);
                          deleteTransactionOrder(order['_id']);
                          setState(() async {
                            await fetchTransactionOrderbuy();
                            await fetchTransactionOrdersell();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(2),
                        ),
                        child: Text('退貨',style: TextStyle(fontSize: 8),),
                      ),
                    )
                  ],
                ),
                subtitle: Text('交易物編號: ${order['transactionid']}\n購買數量: ${order['quantity']}\n總價: ${order['sum']}\n賣方: ${order['seller']}\n賣方聯絡方式: ${order['sellerphone']}'),
              ),
            );
          } else if (transactionOrdersSell.contains(order)) {
            orderType = '售出單';
            return Container(
              color: Color.fromRGBO(214, 186, 150, 1),
              child: ListTile(
                onTap: () async {
                  await fetchTransactionDetails(order['transactionid']);
                  _showdetail(context,transactions);
                },
                title: Text('$orderType\n購買日/時: ${order['time']}'),
                subtitle: Text('交易物編號: ${order['transactionid']}\n賣出數量: ${order['quantity']}\n總價: ${order['sum']}\n備註: ${order['notes']}\n賣方: ${order['buyer']}\n買方聯絡方式: ${order['buyerphone']}'),
              ),
            );
          } else if (textbookOrdersbuy.contains(order)) {
            orderType = '訂購單';
            return Container(
              color: Color.fromRGBO(214, 186, 150, 1),
              child: ListTile(
                onTap: () async {
                  await fetchTextbookDetails(order['bookID']);
                  _showbookdetail(context,textbooks,order['quantity']);
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$orderType\n購買日/時: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(order['time']))}'),
                    ElevatedButton(
                      onPressed: () async{
                        await fetchTextbookDetails(order['bookID']);
                         if(textbooks.status==1){
                           showError(context);
                         }
                         else{
                           int a=textbooks.quantity;
                           int b=order['quantity'];
                           updateTextbookQuantity(textbooks.id,a-b);
                           deleteTextbookOrder(order['_id']);
                           setState(()  {
                              fetchTextbookOrderbuyer();
                           });
                         }
                      },
                      child: Text('退訂'),
                    ),
                  ],
                ),
                subtitle: Text('書籍編號: ${order['bookID']}\n訂購數量: ${order['quantity']}\n發起人: ${order['organizer']}\n發起人聯絡方式: ${order['organizerphone']}'),
              ),
            );
          }
          else if (textbookarrive.contains(order)) {
            orderType = '到貨單';
            return Container(
              color: Color.fromRGBO(214, 186, 150, 1),
              child: ListTile(
                onTap: () async {
                  await fetchpeoplewhobuy(order['_id']);
                  _showpeople(context,textbookorders);
                },
                title: Text('$orderType\n到貨日/時: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(order['bookarrivaltime']))}'),
                subtitle: Text('書籍編號: ${order['_id']}\n書籍名稱: ${order['name']}\nISBN:${order['isbn']}\n總數: ${order['quantity']}\n單價:${order['price']}\n總金額: ${order['quantity']*order['price']}\n交貨地點:${order['place']}\n書商: ${order['bookseller']}\n書商聯絡方式: ${order['booksellerphone']}'),
              ),
            );
          }
          return Container(); // Return an empty container if the order type is not recognized
        },
      );
    }

    final listView = ListView(
      children: [
         ListTile(
          title: Container(
            child: const Row(
              children: [
                Icon(Icons.notifications,size: 18,),
                Text(" "),
                Text('二手交易明細'),
              ],
            ),
          ),
        ),
        buildList(transactionOrdersbuy),
        buildList(transactionOrdersSell),
        ListTile(
          title: Container(
            child: const Row(
              children: [
                Icon(Icons.notifications,size: 18,),
                Text(" "),
                Text('訂購教科書'),
              ],
            ),
          ),
        ),
        buildList(textbookOrdersbuy),
        ListTile(
          title: Container(
            child: const Row(
              children: [
                Icon(Icons.notifications,size: 18,),
                Text(" "),
                Text('教科書訂單已到貨'),
              ],
            ),
          ),
        ),
        buildList(textbookarrive),
      ],
    );

    final page = Scaffold(
      appBar: appBar,
      body: listView,
      backgroundColor: const Color.fromARGB(255, 220, 220, 220),
    );

    return page;
  }
}
Future<Transaction> fetchTransactionDetails(String transactionId) async {
  final response = await http.get(
    Uri.parse(
        'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionget/$transactionId'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (data['success']) {
      transactions=Transaction.fromJson(data['data']);
      return transactions;
    } else {
      throw Exception('Failed to fetch transaction details: ${data['error']}');
    }
  } else {
    throw Exception(
        'Failed to fetch transaction details. Status Code: ${response.statusCode}');
  }
}
_showdetail(context,Transaction dataList){
  var dlg=AlertDialog(
    title:Text(dataList.transactionname),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height:60,
          child: Image.memory(Uint8List.fromList(dataList.image.data),height: 50,width: 50,),
        ),
        const Divider(),
        Text("剩餘數量: ${dataList.quantity}\n類別: ${dataList.category}\n單價: ${dataList.price}元\n聯絡方式: ${dataList.contact}\n交易地點: ${dataList.place}\n交易品敘述: ${dataList.description}\n上架人: ${dataList.seller}"
        ),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dlg,
  );
}
Future<Textbook> fetchTextbookDetails(String textbookId) async {
  final response = await http.get(
    Uri.parse(
        'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookgetone/$textbookId'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (data['success']) {
      textbooks=Textbook.fromJson(data['data']);
      return textbooks;
    } else {
      throw Exception('Failed to fetch textbook details: ${data['error']}');
    }
  } else {
    throw Exception(
        'Failed to fetch textbook details. Status Code: ${response.statusCode}');
  }
}
_showbookdetail(context,Textbook dataList,int q){
  var dlg=AlertDialog(
    title:Text(dataList.name),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ISBN:${dataList.isbn}\n訂購總數:${dataList.quantity}\n拿書地點: ${dataList.place}\n簡述: ${dataList.describe}"
        ),
        Text(dataList.status==0?'狀態:開放訂購中':'狀態:已截止',),
        Text(dataList.bookseller.isNotEmpty?'書商已受理:\n書商:${dataList.bookseller}\n單價:${dataList.price}\n總金額:${dataList.price*q}\n書商聯絡方式:${dataList.booksellerPhone}\n'
            '書商受理時間:\n${DateFormat('yyyy-MM-dd HH:mm:ss').format(dataList.booksellerReceivedTime)}\n預計到貨時間:\n${dataList.bookWillArrivalTime}':'未有書商受理'),
        Text(dataList.getbookstatus==0?'到貨狀態:未到貨':'到貨狀態:已到貨\n到貨時間:${DateFormat('yyyy-MM-dd HH:mm:ss').format(dataList.bookArrivalTime)}'),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dlg,
  );
}
_showpeople(context,List<TextbookOrder> dataList){
  var dlg=AlertDialog(
    title:Text("訂購人"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: dataList.map((order) => Text("${order.buyer} - 聯絡方式:${order.buyerPhone} - 訂購數量:${order.quantity}")).toList(),
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dlg,
  );
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
Future<void> deleteTransactionOrder(String orderId) async {
  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transactionorderdelete/$orderId';

  try {
    final response = await http.delete(
      headers: {'Content-Type': 'application/json'},
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {
      // Transaction order successfully deleted
      final data = jsonDecode(response.body);
      print(data['message']);
    } else if (response.statusCode == 404) {
      // Transaction order not found
      final data = jsonDecode(response.body);
      print(data['message']);
    } else {
      // Handle other status codes
      print('Error: ${response.statusCode}');
    }
  } catch (error) {
    // Handle errors
    print('Error: $error');
  }
}
void showError(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("錯誤"),
      content: Text("訂單已截止，不可退訂!"),
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
Future<void> updateTextbookQuantity(String textbookId, int newQuantity) async {
  try {
    final response = await http.patch(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookupdatequantity/$textbookId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'quantity': newQuantity,
      }),
    );

    if (response.statusCode == 200) {
      print('Textbook quantity updated successfully');
      print(jsonDecode(response.body));
    } else {
      // Handle error
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}
Future<void> deleteTextbookOrder(String orderId) async {
  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookorderdelete/$orderId';

  try {
    final response = await http.delete(
      headers: {'Content-Type': 'application/json'},
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {
      // Transaction order successfully deleted
      final data = jsonDecode(response.body);
      print(data['message']);
    } else if (response.statusCode == 404) {
      // Transaction order not found
      final data = jsonDecode(response.body);
      print(data['message']);
    } else {
      // Handle other status codes
      print('Error: ${response.statusCode}');
    }
  } catch (error) {
    // Handle errors
    print('Error: $error');
  }
}