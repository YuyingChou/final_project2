import 'dart:io';
import 'dart:ui';
import 'package:nuuapp/trading_website/additem.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:nuuapp/trading_website/p1.dart';
import 'package:nuuapp/trading_website/p2.dart';
import 'package:nuuapp/trading_website/p3.dart';
import 'package:nuuapp/trading_website/p4.dart';
import 'package:nuuapp/trading_website/addBook.dart';
import 'package:nuuapp/trading_website/booksellerpage.dart';
import 'package:nuuapp/trading_website/buy.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:numberpicker/numberpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:nuuapp/AccountServices/Login.dart';

int q=0;
String traderid='';
String booksellerid='';
String loginname='';
late String name;
late String studentid;
late String phone;
late String email;
late String departmentclass;
void main() {
  runApp(const trading_website());
}

class trading_website extends StatelessWidget {
  const trading_website({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    var MyApp = MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),

      initialRoute: '/',
      routes: {
        '/': (context) =>MyHomePage(),
        '/p1' :(context) => p1(
          traderid: traderid ,
        ),
        '/p2' :(context) => p2(sellerid: traderid),
        '/p3' :(context) => p3(organizerid: traderid),
        '/p4' :(context) => p4(userid:traderid),
        '/buy' :(context) => buy(),
        '/additem' :(context) => additem(),
        '/addBook' :(context) => addBook(),
        '/booksellerpage' :(context) => booksellerpage(),
      },
    );
    return MyApp;
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key}) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin implements WidgetsBindingObserver{

  late TabController _tabController;
  List<Transaction> transactions=[];
  List<Textbook> textbooks=[];
  @override
  void initState() {
    super.initState();
    Userstore().store(context);
    fetchTransactions();
    fetchTextbooks();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    WidgetsBinding.instance!.addObserver(this);
  }
  Future<List<Transaction>> fetchTransactions() async {
    const String apiUrl= 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transaction/getstatus/0';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final List<dynamic> data = responseData['responseData']['data1'];
      print(data);
      List<Transaction> transaction = data.map((json) {
        return Transaction.fromJson(json);
      }).toList();
      //測試
      print('載入成功');
      //
      setState(() {
        transaction=transaction;
        transactions = transaction;
      });
      return transactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }
  Future<List<Textbook>> fetchTextbooks() async {
    const String apiUrl= 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookgetstatus/0';
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
  Future<void> loadTransactions() async {
    try {
      List<Transaction> fetchedTransactions = await fetchTransactions();
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
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 监听应用程序生命周期变化
    if (state == AppLifecycleState.paused) {
      updateLastLeaveTime(); // 更新用户离开时间
    }
  }
  DateTime? Time;
  void recordTime() {
    setState(() {
      Time = DateTime.now();
    });
  }
  Future<void> updatetraderLogoutTime(String Id, DateTime time) async {
    try {
      final response = await http.patch(
        Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/traderupdatelastLogoutTime/$Id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lastLogoutTime': time.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('traderLogoutTime updated successfully');
        print(jsonDecode(response.body));
        q++;
      } else {
        // Handle error
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  void updateLastLeaveTime() {
    if(traderid.isNotEmpty){
      recordTime();
      updatetraderLogoutTime(traderid,Time!);
    }
  }
  @override
  Widget build(BuildContext context) {
    final drawer = Drawer(
      child: ListView(
        children: <Widget> [
          Container(
            color: Colors.brown,
            child:Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '個人專區',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: Row(
                        children: [
                          Icon(Icons.person_pin),
                          SizedBox(width: 4),
                          Text(
                            '歡迎 $loginname!',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
              title: const Text('回主頁', style: TextStyle(fontSize: 20),),
              onTap: () async {
                Navigator.pop(context);
              }
          ),
          ListTile(
              title: const Text('交易人資料', style: TextStyle(fontSize: 20),),
              onTap: () async {
                Navigator.pop(context);
                if(traderid==''){
                  showbooksellererror(context);
                }
                else{
                  final result=await Navigator.pushNamed(context, '/p1',);
                  if(result == true){
                    refresh();
                  }
                }
              }
          ),
          ListTile(
              title: const Text('我的上架品', style: TextStyle(fontSize: 20),),
              onTap: () async {
                Navigator.pop(context);
                if(traderid==''){
                  showbooksellererror(context);
                }
                else{
                  final result=await Navigator.pushNamed(context, '/p2',);
                  if(result == true){
                    refresh();
                  }
                }
              }
          ),
          ListTile(
              title: const Text('我的代訂教科書', style: TextStyle(fontSize: 20),),
              onTap: () async {
                Navigator.pop(context,true);
                if(traderid==''){
                  showbooksellererror(context);
                }
                else{
                  final result=await Navigator.pushNamed(context, '/p3',);
                  if(result == true){
                    refresh();
                  }
                }
              }
          ),
          ListTile(
              title: const Text('通知', style: TextStyle(fontSize: 20),),
              onTap: () async {
                Navigator.pop(context);
                final result=await Navigator.pushNamed(context, '/p4');
                if(result == true){
                  refresh();
                }
              }
          ),
          ListTile(
              title: const Text('登出', style: TextStyle(fontSize: 20),),
              onTap: () async {
                context.read<UserProvider>().setUserLoggedOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );

              }
          ),
        ],
      ),
    );

    final addtransactionbuttom= ElevatedButton(
      child: const Text('上架', style: TextStyle(fontSize: 15, color: Colors.white),),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueGrey,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        elevation: 8,
      ),
      onPressed: () async {
        if(traderid==''){
          showbooksellererror(context);
        }
        else{
          final result=await Navigator.pushNamed(context, '/additem', arguments:{'traderid':traderid , 'loginname':loginname,} );
          if(result == true){
            refresh();
          }
        }
      }
    );

    final addbookbuttom= TextButton(
      child: const Text('新增書目', style: TextStyle(fontSize: 15, color: Colors.blueGrey),),
      onPressed: () async {
        if(traderid==''){
          showbooksellererror(context);
        }
        else{
          final result=await Navigator.pushNamed(context, '/addBook', arguments:{'traderid':traderid , 'loginname':loginname,} );
          if(result == true){
            refreshbook();
          }
        }
      }
    );

    // 建立AppBar
    final appBar = AppBar(
      title: const Text('二手物交易&代訂教科書平台',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: Theme(
          data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white)),
          child: Container(
            height: 30.0,alignment: Alignment.center,child: TabPageSelector(controller: _tabController),
          ),
        ),
      ),
    );

    final tabPagtransaction=Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(child: addtransactionbuttom,alignment: Alignment.bottomRight,),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: transactions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    if(traderid==''){
                      showbooksellererror(context);
                    }
                    else{
                      Transaction send=transactions[index];
                      final result=await Navigator.pushNamed(context, '/buy', arguments:  {'send': send, 'traderid': traderid,'loginname':loginname});
                      if(result == true){
                        refresh();
                      }
                    }
                  },
                  child: _transactioncard(context, index, transactions),
                );
              },
            ),
          ],
        ),
      ),
    );

    final tobooksellerpage= TextButton(
      child: const Text('書商專區', style: TextStyle(fontSize: 15, color: Colors.blueGrey),),
      onPressed: () =>
          Navigator.pushNamed(context,'/booksellerpage', arguments: booksellerid),
    );

    final tabPagbook=Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(child: addbookbuttom,alignment: Alignment.bottomRight,),
                  Container(child: tobooksellerpage,alignment: Alignment.bottomRight,margin: const EdgeInsets.all(5),),
                ],
              ),
            ),
            GridView.builder(
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
                      if(traderid==''){
                        showbooksellererror(context);
                      }
                      else{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PurchaseDialog(
                              parentContext: context,
                              index: index,
                              dataList: textbooks,
                              onDismissed: () async {
                                await refreshbook();
                              },
                            );
                          },
                        );
                      }
                    },
                    child: _bookcard(context, index, textbooks),
                  );
                }
            ),
          ],
        ),
      ),
    );

    final tabBarView= TabBarView(
      children: [tabPagtransaction,tabPagbook] ,
      physics: const BouncingScrollPhysics(),
      controller: _tabController,
    );

    final appHomePage = DefaultTabController(
      length: tabBarView.children.length,
      child: RefreshIndicator(
        onRefresh: () async {
          await refresh();
          await refreshbook();
        },
        child:Scaffold(
          appBar: appBar,
          body: tabBarView,
          drawer: drawer,
          backgroundColor:  const Color.fromARGB(255, 240,240 ,240),
        ),
      ),
    );
    return appHomePage;
  }
  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // TODO: implement didChangeLocales
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    throw UnimplementedError();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    // TODO: implement didRequestAppExit
    throw UnimplementedError();
  }
}

void shownotfound() {
  String message = '該書目已截止!' ;

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
void showagain() {
  String message = '失敗!請再試一次!' ;

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
void showaddbookquantityresult(BuildContext context,int number) {
  String message = '加入訂購數量:$number 成功!';

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

Widget _bookcard(context, index, dataList) {
  void _showbookdetailDialog(int p) {
    var dlg=AlertDialog(
      title: Text("教科書詳情"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("書名: ${dataList[p].name}\n發起人: ${dataList[p].organizer}\nISBN:${dataList[p].isbn}\n目前訂購數量:${dataList[p].quantity}\n聯絡方式: ${dataList[p].phone}\n交書地點: ${dataList[p].place}\n簡述: ${dataList[p].describe}\n預計關閉時間:${DateFormat('yyyy-MM-dd HH:mm:ss').format(dataList[p].closingTime)}"
          ),
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (context) => dlg,
    );
  }
  final bookdetail= ElevatedButton(
      child: Text("詳情", style: TextStyle(fontSize: 10)),
      style: ButtonStyle(
        padding:MaterialStateProperty.all(EdgeInsets.all(1.0)),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      onPressed: () {
        _showbookdetailDialog( index);
      }
  );
  return Card(
      color: Color.fromARGB(255, 152, 176, 187),
      child:Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book,size: 18,),
                  const Text(" "),
                  Text("${dataList[index].name}", style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
            Container(
              child: Text("ISBN:${dataList[index].isbn}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),margin: EdgeInsets.all(1),
            ),
            Container(
              child: Text("簡述:${dataList[index].describe}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),margin: EdgeInsets.all(1),
            ),
            Container(
              child: Text("關閉時間:${DateFormat('yyyy-MM-dd HH:mm:ss').format(dataList[index].closingTime)}", style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis,),margin: EdgeInsets.all(1),
            ),
            Container(
              child: bookdetail,height: 15,margin: EdgeInsets.all(2),alignment: Alignment.center,
            ),
          ],
        ),
      )
  );
}
class PurchaseDialog extends StatefulWidget {
  final BuildContext parentContext;
  final int index;
  final List<Textbook> dataList;
  final VoidCallback? onDismissed;

  PurchaseDialog({
    required this.parentContext,
    required this.index,
    required this.dataList,
    this.onDismissed,
  });

  @override
  _PurchaseDialogState createState() => _PurchaseDialogState();
}
class _PurchaseDialogState extends State<PurchaseDialog> {
  int selectedQuantity = 1;
  final phoneController = TextEditingController();
  DateTime? buttonClickTime;
  late Textbook currenttextbook;
  void recordButtonClickTime() {
    setState(() {
      buttonClickTime = DateTime.now();
    });
  }
  @override
  Widget build(BuildContext context) {
    final phone = TextField(
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
    return AlertDialog(
      title: Text("訂購數量",textAlign: TextAlign.center,),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              child: phone,
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Container(child: Text("選擇數量: $selectedQuantity"),),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: NumberPicker(
                      value: selectedQuantity,
                      minValue: 1,
                      maxValue: 50,
                      onChanged: (value) {
                        setState(() {
                          selectedQuantity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onDismissed?.call();// Close the dialog
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () async {
            if (phoneController.text.isEmpty) {
              showEmptyError(context);
            }
            else {
              Future<Textbook> fetchTextbookAtIndex(String t) async {
                late Textbook theTextbook;
                final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookgetone/$t';
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
                  theTextbook = Textbook.fromJson(responseData['data']);

                  print('載入成功');
                  theTextbook=theTextbook;
                  return theTextbook;
                } else {
                  throw Exception('Failed to load transactions Response: ${response.body}' );
                }
              }
              try{
                currenttextbook = await fetchTextbookAtIndex(widget.dataList[widget.index].id);
                if (currenttextbook.status!=1) {
                  recordButtonClickTime();
                  int total=widget.dataList[widget.index].quantity + selectedQuantity;
                  postTextbookOrder(loginname, traderid, phoneController.text,widget.dataList[widget.index].organizer,
                      widget.dataList[widget.index].organizerId,widget.dataList[widget.index].id,buttonClickTime!,selectedQuantity,widget.dataList[widget.index].phone);
                  updateTextbookQuantity(widget.dataList[widget.index].id,total);
                  Navigator.pop(context);
                  showaddbookquantityresult(context, selectedQuantity);
                } else {
                  Navigator.pop(context);
                  shownotfound();
                }
              }
              catch (error) {
                print('Error fetching data: $error');
              }
            }
            widget.onDismissed?.call();
          },
          child: Text('確定'),
        ),
      ],
    );
  }
}

Widget _transactioncard(context, index, dataList) {
  return Card(
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
              ],
            )
          ],
        ),
      )
  );
}
void showEmptyError(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("錯誤"),
      content: Text("聯絡方式不能為空。"),
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

void showbooksellererror(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("錯誤"),
      content: Text("本校學生才能進行二手交易or參與代訂!"),
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
class Userstore {
  void store(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
          name=userProvider.username;
          loginname=userProvider.username;
          studentid=userProvider.studentId;
          phone=userProvider.phoneNumber;
          email=userProvider.email;
          departmentclass="${userProvider.department}${userProvider.year}";print(name+studentid+phone+email+departmentclass);
          if(studentid.isNotEmpty){
            addTrader(name,studentid,phone,email,departmentclass,DateTime(0));
          }
          else{
            traderid.isEmpty;
            addBookseller(name,phone,email);
          }
        }
}
Future<void> addBookseller(String name, String phone, String email) async {
  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/bookseller/add';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      booksellerid=jsonResponse['message'];
      print('booksellerid: $booksellerid');
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
Future<void> addTrader(String name, String studentid, String phone, String email, String departmentclass,DateTime lastLogoutTime) async {
  final String checkUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/tradercheckStudentid/$studentid';
  final String createUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/trader/add';

  try {
    // Check if studentID already exists in the database
    final responseCheck = await http.get(Uri.parse(checkUrl));

    if (responseCheck.statusCode == 200) {
      final jsonResponse = json.decode(responseCheck.body);

      if (jsonResponse['exists']) {
        // StudentID already exists, retrieve the traderId
        traderid = jsonResponse['traderId'];
        print('StudentID already exists. TraderID: $traderid');
        return;
      }
    } else {
      // Handle errors in checking student existence
      print('Failed to check student existence: ${responseCheck.statusCode}');
      print('Response body: ${responseCheck.body}');
      return;
    }

    // If studentID doesn't exist, proceed with creating the trader
    final responseCreate = await http.post(
      Uri.parse(createUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'studentID': studentid,
        'phone': phone,
        'email': email,
        'departmentclass': departmentclass,
        'lastLogoutTime': lastLogoutTime.toUtc().toIso8601String(),
      }),
    );

    if (responseCreate.statusCode == 201) {
      final jsonResponse = json.decode(responseCreate.body);
      traderid = jsonResponse['traderId'];
      print('成功，交易人ID: $traderid');
    } else {
      // Handle errors in creating trader
      print('Failed to create trader: ${responseCreate.statusCode}');
      print('Response body: ${responseCreate.body}');
    }
  } catch (error) {
    // Handle general errors
    print('Error: $error');
  }
}
Future<void> postTextbookOrder(
    String buyer,String buyerId,String buyerphone,String organizer, String organizerId, String bookId,DateTime time,
     int quantity,String organizerphone) async {
  try {
    final response = await http.post(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbookorder/add'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'buyer': buyer,
        'buyerid': buyerId,
        'buyerphone': buyerphone,
        'organizer': organizer,
        'organizerphone': organizerphone,
        'organizerid': organizerId,
        'bookID': bookId,
        'time': time.toUtc().toIso8601String(),
        'quantity': quantity,
      }),
    );
    if (response.statusCode == 200) {
      //final jsonResponse = json.decode(response.body);
      print('成功');
      q++;
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
      q++;
    } else {
      // Handle error
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}