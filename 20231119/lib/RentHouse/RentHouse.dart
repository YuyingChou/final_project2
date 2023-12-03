import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../AccountServices/Home.dart';
import 'package:provider/provider.dart';
import '../Providers/user_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(YourApp());
}

class YourApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '租屋資訊平台',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const YourHomePage(),
    );
  }
}

class YourHomePage extends StatefulWidget {
  const YourHomePage({super.key});

  @override
  _YourHomePageState createState() => _YourHomePageState();
}

class _YourHomePageState extends State<YourHomePage> {
  List<dynamic> rentItems = [];
  List<dynamic> filteredRentItems = [];
  late TextEditingController searchController;
  String selectedRoomTypeFilter = 'All';
  List<String> selectedFacilitiesFilter = [];
  String selectedUserRoleFilter = '學生分享'; // 新增：初始值為 '學生分享'
  List<String> sortOptions = ['日期大到小', '日期小到大', '價格大到小', '價格小到大'];
  String selectedSortOption = '日期大到小'; // 初始排序方式
  late String currentUsername;

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController = TextEditingController();

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    currentUsername = userProvider.username;
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/Info/getRentItems'));
    if (response.statusCode == 200) {
      setState(() {
        rentItems = json.decode(response.body)['data'];
        // 新增：初始只顯示 department 不等於 'other' 的資料
        filteredRentItems = rentItems.where((item) => item['department'] != 'other').toList();
      });
    } else {
      throw Exception('無法加載租屋信息');
    }
  }

  void applyRoomTypeFilter(String roomType) {
    setState(() {
      selectedRoomTypeFilter = roomType;
      updateFilteredItems();
    });
  }

  void applyUserRoleFilter(String userRole) {
    setState(() {
      selectedUserRoleFilter = userRole;
      updateFilteredItems();
    });
  }

  void applyFacilitiesFilter(List<String> selectedFacilities) {
    setState(() {
      selectedFacilitiesFilter = selectedFacilities;
      updateFilteredItems();
    });
  }

  void _handlePublish() {
    fetchData(); // 或任何其他刷新數據的邏輯
    updateFilteredItems();
    setState(() {}); // 這將觸發 UI 的重建
  }

  void updateFilteredItems() {
    // Apply filters based on room type, user role, and facilities
    filteredRentItems = rentItems.where((item) {
      bool roomTypeFilter = selectedRoomTypeFilter == 'All' || item['roomType'] == selectedRoomTypeFilter;

      bool userRoleFilter =
          selectedUserRoleFilter == '學生分享' && item['department'] != 'other' ||
              selectedUserRoleFilter == '房東租屋' && item['department'] == 'other' ||
              selectedUserRoleFilter == '自己分享' && item['username'] == currentUsername;

      bool facilitiesFilter = true;
      if (selectedFacilitiesFilter.isNotEmpty) {
        facilitiesFilter = selectedFacilitiesFilter.every(
              (facility) => item['facilities'].contains(facility),
        );
      }

      return roomTypeFilter && userRoleFilter && facilitiesFilter;
    }).toList();

    // Apply sorting based on selectedSortOption
    switch (selectedSortOption) {
      case '日期大到小':
        filteredRentItems.sort((a, b) => b['publishTime'].compareTo(a['publishTime']));
        break;
      case '日期小到大':
        filteredRentItems.sort((a, b) => a['publishTime'].compareTo(b['publishTime']));
        break;
      case '價格大到小':
        filteredRentItems.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case '價格小到大':
        filteredRentItems.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      default:
        break;
    }
  }

  Future<void> _handleRefresh() async {
    await fetchData();
    updateFilteredItems();
    setState(() {}); // This will trigger a rebuild of the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('租屋資訊'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: selectedUserRoleFilter,
                  items: ['學生分享', '房東租屋', '自己分享'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    applyUserRoleFilter(value ?? '學生分享');
                  },
                ),
                DropdownButton<String>(
                  value: selectedRoomTypeFilter,
                  items: ['All', '套房', '雅房'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    applyRoomTypeFilter(value ?? 'All');
                  },
                ),
                DropdownButton<String>(
                  value: selectedSortOption,
                  items: sortOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedSortOption = value;
                        updateFilteredItems();
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(
                        rentItems,
                        () {
                          // 定義刷新邏輯
                          print('Refresh logic here');
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: MultiSelectChip(
                  options: const [
                    '洗衣機',
                    '陽台',
                    '冷氣',
                    '冰箱',
                    '網路',
                    '床',
                    '衣櫃',
                    '熱水器',
                    '機車位',
                    '汽車位'
                  ],
                  onSelectionChanged: applyFacilitiesFilter,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRentItems.length,
                itemBuilder: (context, index) {
                  final rentItem = filteredRentItems[index];
                  final titleWithPublisher = "${rentItem['title']}";
                  final publisherName = "${rentItem['username']}";

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(titleWithPublisher),
                          Text(publisherName), // 發布者名稱放在最右邊
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('地點: ${rentItem['location']}'),
                          Text('房型: ${rentItem['roomType']}'),
                          Text('價格: ${rentItem['price']}'),
                          Text(
                              '發布時間:${formatPublishTime(rentItem['publishTime'])}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HouseDetailsPage(
                              houseDetails: rentItem,
                              onRefresh: _handleRefresh,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  YourPublishHousePage(onPublish: _handlePublish),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

String formatPublishTime(String publishTime) {
  final parsedTime = DateTime.parse(publishTime);
  final taiwanTime =
      parsedTime.toUtc().add(const Duration(hours: 8)); // 轉換為台灣時間

  final formatter = DateFormat('yyyy-MM-dd HH:mm', 'en_US'); // 指定格式和語言環境
  return formatter.format(taiwanTime);
}

class MultiSelectChip extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectChip(
      {super.key, required this.options, required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChips = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: widget.options.map((String facility) {
        return FilterChip(
          label: Text(facility),
          selected: selectedChips.contains(facility),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedChips.add(facility);
              } else {
                selectedChips.remove(facility);
              }
              widget.onSelectionChanged(selectedChips);
            });
          },
        );
      }).toList(),
    );
  }
}

class HouseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> houseDetails;
  final Function onRefresh;

  const HouseDetailsPage({Key? key, required this.houseDetails, required this.onRefresh}) : super(key: key);

  Future<void> _handleEditSave(BuildContext context, Map<String, dynamic> editedData) async {
    print('更新的數據: $editedData');
    await updateHouseInBackend(editedData);
    await fetchData();
    onRefresh();
    Navigator.of(context).pop();
  }

  Future<void> fetchData() async {
    print('從後端獲取更新的數據...');
    // 在這裡加入獲取其他相同地址租房資料的邏輯，例如:
    // List<Map<String, dynamic>> similarHouses = await fetchSimilarHouses(houseDetails['location']);
    // 這裡假設 fetchSimilarHouses 是一個獲取相同地址租房資料的方法
  }

  Future<List<Map<String, dynamic>>> fetchSimilarHouses(String location) async {
    try {
      final response = await http.get(
        Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/Info/getSimilarHouses/$location'),
      );

      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          dynamic data = responseData['data'];

          if (data is List && data.every((element) => element is Map<String, dynamic>)) {
            // Cast each element to Map<String, dynamic>
            return List<Map<String, dynamic>>.from(data);
          } else {
            print('獲取相同地址租房資料失敗: 返回的資料不是 List<Map<String, dynamic>>，原始資料: $data');
            throw Exception('獲取相同地址租房資料失敗: 返回的資料不是 List<Map<String, dynamic>>');
          }
        } else {
          print('獲取相同地址租房資料失敗: API 返回的 success 不是 true，原始資料: $responseData');
          throw Exception('獲取相同地址租房資料失敗: API 返回的 success 不是 true');
        }
      } else {
        print('獲取相同地址租房資料失敗，狀態碼: ${response.statusCode}');
        throw Exception('獲取相同地址租房資料失敗，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      print('錯誤: $e');
      throw Exception('獲取相同地址租房資料失敗: $e');
    }
  }



  void editHouse(BuildContext context) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String currentUsername = userProvider.username;

    if (currentUsername == houseDetails['username']) {
      final editedData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditHousePage(houseDetails: houseDetails),
        ),
      );

      if (editedData != null) {
        print('更新的數據: $editedData');
        await _handleEditSave(context, editedData);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('您無權編輯這個資訊'),
        ),
      );
    }
  }

  Future<void> updateHouseInBackend(Map<String, dynamic> editedData) async {
    final response = await http.put(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/Info/editHouse/${houseDetails['title']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(editedData),
    );

    if (response.statusCode == 200) {
      print('編輯成功');
      onRefresh();
    } else {
      print('編輯失敗: ${response.body}');
    }
  }

  void deleteHouse(BuildContext context) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String currentUsername = userProvider.username;

    if (currentUsername == houseDetails['username']) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("確認刪除"),
            content: Text("確定要刪除這個租屋信息嗎？"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () async {
                  await http.delete(
                    Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/Info/deleteRentItem/${houseDetails['title']}'),
                  );

                  Navigator.of(context).pop();
                  onRefresh();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => YourApp()),
                  );
                },
                child: Text("確定"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('您無權刪除這個資訊'),
        ),
      );
    }
  }

  void reserveHouse(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String applicantName = userProvider.username;
    String applicantphoneNumber = userProvider.phoneNumber;
    String applicantgender = userProvider.gender;
    String applicantemail = userProvider.email;

    Map<String, dynamic> landlordInfo = {
      'landlordName': houseDetails['username'],
      'landlordContact': houseDetails['landlordContact'],
      'landlordEmail': houseDetails['email'],
    };

    if (houseDetails['department'] == 'other') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("確認預約看房"),
            content: Text("確定要通知房東預約看房嗎？"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  sendReservationEmail(
                    houseDetails['email'],
                    applicantName,
                    applicantphoneNumber,
                    applicantgender,
                    applicantemail,
                    landlordInfo,
                  );
                  Navigator.of(context).pop();
                },
                child: Text("確定"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('您無法預約看房'),
        ),
      );
    }
  }

  Future<void> sendReservationEmail(
      String recipientEmail,
      String applicantName,
      String applicantContact,
      String applicantgender,
      String applicantemail,
      Map<String, dynamic> landlordInfo,
      ) async {
    String username = 'nuuappemailsender@gmail.com';
    String password = 'evhb ahun gikp ffgd';

    final smtpServer = gmail(username, password);

    final messageToApplicant = Message()
      ..from = Address(username, 'NuuApp')
      ..recipients.add(applicantemail)
      ..subject = '預約看房通知'
      ..text = '您已成功預約看房。\n\n'
          '預約者姓名: $applicantName\n\n'
          '房東信息:\n'
          '姓名: ${landlordInfo['landlordName']}\n'
          '電話: ${landlordInfo['landlordContact']}\n'
          'Email: ${landlordInfo['landlordEmail']}\n\n'
          '備註: 如果房東沒有主動回信，請自行連絡房東';

    final messageToLandlord = Message()
      ..from = Address(username, 'NuuApp')
      ..recipients.add(recipientEmail)
      ..subject = '新的預約看房通知'
      ..text = '您有一個新的預約看房的通知。\n\n'
          '預約者姓名: $applicantName\n'
          '聯絡方式: $applicantContact\n'
          '預約者性別: $applicantgender\n'
          '預約者Email: $applicantemail\n';

    try {
      final sendReportToApplicant = await send(messageToApplicant, smtpServer);
      final sendReportToLandlord = await send(messageToLandlord, smtpServer);

      print('郵件發送成功給預約者: ${sendReportToApplicant.toString()}');
      print('郵件發送成功給房東: ${sendReportToLandlord.toString()}');
    } on MailerException catch (e) {
      print('郵件發送失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLandlord = houseDetails['department'] == 'other';

    return Scaffold(
      appBar: AppBar(
        title: Text('詳細信息'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              editHouse(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteHouse(context);
            },
          ),
          if (isLandlord) // 只有非房東才顯示預約按鈕
            IconButton(
              icon: Icon(Icons.add_box),
              onPressed: () {
                reserveHouse(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('標題: ${houseDetails['title']}'),
                  ),
                  Expanded(
                    child: Text(
                      '${formatPublishTime(houseDetails['publishTime'])}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      launch('https://www.google.com/maps/search/?api=1&query=${houseDetails['location']}');
                    },
                    child: Text('地點: ${houseDetails['location']}',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'By: ${houseDetails['username']}',
                    textAlign: TextAlign.right,
                  ),
                ),
              ]),
              Text('房間類型: ${houseDetails['roomType']}'),
              Text('價格: ${houseDetails['price']}'),
              Text('房東姓名: ${houseDetails['landlordName']}'),
              Text('房東聯絡方式: ${houseDetails['landlordContact']}'),
              Text('退租日期/可入住日期: ${houseDetails['expectedEndDate']}'),

              if (!isLandlord) // 只有非房東才顯示評分
                Text('評分: ${houseDetails['rating']}'),

              Text('評論/注意事項: ${houseDetails['comment']}'),
              Text('設施: ${houseDetails['facilities'].join(', ')}'),
              Center(
                child: houseDetails['image'] != null
                    ? Image.memory(
                  base64Decode(houseDetails['image']),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                )
                    : Container(),
              ),
              SizedBox(height: 16), // 添加一個空白間隔
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchSimilarHouses(houseDetails['location']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('錯誤: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('沒有其他相同地址的租房資料');
                  } else {
                    // 對 snapshot.data 進行排序，根據 'publishTime' 降序排列
                    snapshot.data!.sort((a, b) => b['publishTime'].compareTo(a['publishTime']));

                    // 顯示其他相同地址的租房資料列表
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '其他相同地址的租房資料',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        for (int index = 0; index < snapshot.data!.length; index++) ...[
                          if (snapshot.data![index]['publishTime'] != houseDetails['publishTime']) ...[
                            GestureDetector(
                              onTap: () async {
                                // 導向到 HouseDetailsPage 並傳遞相應的租房資料
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseDetailsPage(
                                      houseDetails: snapshot.data![index],
                                      onRefresh: onRefresh,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '評論/注意事項: ${snapshot.data![index]['comment']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (snapshot.data![index]['department'] != 'other') // 只有非房東才顯示評分
                                        Expanded(
                                          child: Text(
                                            '評分: ${snapshot.data![index]['rating']}',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '發布時間: ${formatPublishTime(snapshot.data![index]['publishTime'])}',
                                      ),
                                      Text(
                                        'By: ${snapshot.data![index]['username']} ${snapshot.data![index]['department'] == 'other' ? '(房東)' : ''}',
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditHousePage extends StatefulWidget {
  final Map<String, dynamic> houseDetails;

  EditHousePage({required this.houseDetails});

  @override
  _EditHousePageState createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController landlordNameController = TextEditingController();
  TextEditingController landlordContactController = TextEditingController();
  TextEditingController expectedEndDateController = TextEditingController();
  TextEditingController commentController = TextEditingController(); // 新增評論的TextEditingController
  double ratingValue = 0.0;
  String selectedRoomType = '套房';
  List<String> selectedFacilities = [];
  DateTime selectedDate = DateTime.now();
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.houseDetails['title'];
    locationController.text = widget.houseDetails['location'];
    priceController.text = widget.houseDetails['price'].toString();
    landlordNameController.text = widget.houseDetails['landlordName'];
    landlordContactController.text = widget.houseDetails['landlordContact'];
    expectedEndDateController.text = widget.houseDetails['expectedEndDate'];
    ratingValue = widget.houseDetails['rating']?.toDouble() ?? 0.0;
    selectedRoomType = widget.houseDetails['roomType'];
    selectedFacilities = List<String>.from(widget.houseDetails['facilities']);
    commentController.text = widget.houseDetails['comment'] ?? ''; // 初始化評論內容
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('編輯房屋信息'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedRoomType,
              items: ['套房', '雅房'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedRoomType = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: '房型'),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '標題'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: '地點'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: '價格'),
            ),
            TextField(
              controller: landlordNameController,
              decoration: InputDecoration(labelText: '房東姓名'),
            ),
            TextField(
              controller: landlordContactController,
              decoration: InputDecoration(labelText: '房東聯絡方式'),
            ),
            Row(
              children: [
                Text(
                  '退租日期/可入住日期:     ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  style: TextStyle(fontSize: 16, height: 4.0),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
            Center(
              child: Column(
                children: [
                  Text('評分', style: TextStyle(fontSize: 16)),
                  Slider(
                    value: ratingValue,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: ratingValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        ratingValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Text('選擇設施:'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: ['洗衣機', '陽台', '冷氣', '冰箱', '網路', '床', '衣櫃', '熱水器', '機車位', '汽車位'].map((facility) {
                return FilterChip(
                  label: Text(facility),
                  selected: selectedFacilities.contains(facility),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedFacilities.add(facility);
                      } else {
                        selectedFacilities.remove(facility);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  _pickImage();
                },
                child: Column(
                  children: [
                    Text('選擇圖片', style: TextStyle(fontSize: 16)),
                    Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: _buildImage(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 4, // 設定評論的輸入框可以多行
              decoration: InputDecoration(labelText: '評論'),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _handleEditSave();
                },
                child: Text('保存編輯'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        expectedEndDateController.text =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      });
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  Widget _buildImage() {
    if (selectedImage != null) {
      return Image.file(
        File(selectedImage!.path),
        height: 200,
        width: 200,
        fit: BoxFit.cover,
      );
    } else if (widget.houseDetails['image'] != null) {
      return Image.memory(
        base64Decode(widget.houseDetails['image']),
        height: 200,
        width: 200,
        fit: BoxFit.cover,
      );
    } else {
      return Center(child: Icon(Icons.add_a_photo));
    }
  }

  Future<void> _handleEditSave() async {
    DateTime currentTime = DateTime.now();
    DateTime taiwanTime = currentTime.add(Duration(hours: 8));
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_TW');
    String formattedTime = formatter.format(taiwanTime);

    Map<String, dynamic> editedData = {
      'roomType': selectedRoomType,
      'title': titleController.text,
      'location': locationController.text,
      'price': int.parse(priceController.text),
      'landlordName': landlordNameController.text,
      'landlordContact': landlordContactController.text,
      'expectedEndDate': expectedEndDateController.text,
      'rating': ratingValue,
      'facilities': selectedFacilities,
      'publishTime': formattedTime,
      'comment': commentController.text,
    };

    if (selectedImage != null) {
      List<int> imageBytes = await selectedImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      editedData['image'] = base64Image;
    }

    Navigator.pop(context, editedData);
  }
}

class YourPublishHousePage extends StatefulWidget {
  final Function onPublish;

  YourPublishHousePage({required this.onPublish});

  @override
  _YourPublishHousePageState createState() => _YourPublishHousePageState();
}

class _YourPublishHousePageState extends State<YourPublishHousePage> {
  late DateTime selectedDate;
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController landlordNameController = TextEditingController();
  TextEditingController landlordContactController = TextEditingController();
  TextEditingController expectedEndDateController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  double ratingValue = 0.0;
  String selectedRoomType = '套房';
  List<String> roomTypeOptions = ['套房', '雅房'];
  List<String> facilitiesOptions = [
    '洗衣機',
    '陽台',
    '冷氣',
    '冰箱',
    '網路',
    '床',
    '衣櫃',
    '熱水器',
    '機車位',
    '汽車位',
  ];
  List<String> selectedFacilities = [];
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        expectedEndDateController.text =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    bool isOtherDepartment = userProvider.department == 'other';

    return Scaffold(
      appBar: AppBar(
        title: Text('發布'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedRoomType,
              items: roomTypeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedRoomType = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: '房型'),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '標題'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: '地點'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: '價格'),
            ),
            TextField(
              controller: landlordNameController,
              decoration: InputDecoration(labelText: '房東姓名'),
            ),
            TextField(
              controller: landlordContactController,
              decoration: InputDecoration(labelText: '房東聯絡方式'),
            ),
            Row(
              children: [
                Text(
                  '退租日期/可入住日期:     ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                  style: TextStyle(fontSize: 16, height: 4.0),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
              ],
            ),
            if (!isOtherDepartment)
              Center(
                child: Column(
                  children: [
                    Text('評分', style: TextStyle(fontSize: 16)),
                    Slider(
                      value: isOtherDepartment ? 10.0 : ratingValue,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: (isOtherDepartment ? 10 : ratingValue.round()).toString(),
                      onChanged: (double value) {
                        if (!isOtherDepartment) {
                          setState(() {
                            ratingValue = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            Text('選擇設施:'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: facilitiesOptions.map((facility) {
                  return FilterChip(
                    label: Text(facility),
                    selected: selectedFacilities.contains(facility),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedFacilities.add(facility);
                        } else {
                          selectedFacilities.remove(facility);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(labelText: '評論/注意事項'),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Column(
                  children: [
                    Text('選擇圖片', style: TextStyle(fontSize: 16)),
                    Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: selectedImage != null
                          ? Image.file(
                        File(selectedImage!.path),
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      )
                          : Center(
                        child: Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  publishHouse(context);
                },
                child: Text('發布'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> publishHouse(BuildContext context) async {
    // 檢查必填欄位是否有缺漏
    if (
    titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        priceController.text.isEmpty ||
        landlordNameController.text.isEmpty ||
        landlordContactController.text.isEmpty ||
        expectedEndDateController.text.isEmpty ||
        selectedFacilities.isEmpty ||
        selectedImage == null
    ) {
      // 顯示提示訊息
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('請填寫所有必填欄位'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('確定'),
              ),
            ],
          );
        },
      );
      return;
    }

    String? base64Image;

    if (selectedImage != null) {
      List<int> imageBytes = await selectedImage!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    DateTime currentTime = DateTime.now();

    UserProvider userProvider =
    Provider.of<UserProvider>(context, listen: false);
    String currentUsername = userProvider.username;
    String currentDepartment = userProvider.department;
    String currentemail = userProvider.email;

    final response = await http.post(
      Uri.parse('https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/Info/publishHouse'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': currentUsername,
        'department': currentDepartment,
        'email': currentemail,
        'roomType': selectedRoomType,
        'title': titleController.text,
        'location': locationController.text,
        'price': priceController.text,
        'landlordName': landlordNameController.text,
        'landlordContact': landlordContactController.text,
        'expectedEndDate': expectedEndDateController.text,
        'rating': ratingValue,
        'image': base64Image,
        'facilities': selectedFacilities,
        'comment': commentController.text,
        'publishTime': currentTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      widget.onPublish();
      Navigator.pop(context);
    } else {
      print('發布失敗: ${response.body}');
    }
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<dynamic> rentItems;
  final Function onRefresh;

  CustomSearchDelegate(this.rentItems, this.onRefresh);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<dynamic> searchResults = rentItems
        .where((item) =>
            item['title'].toLowerCase().contains(query.toLowerCase()) ||
            item['location'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(searchResults[index]['title']),
            subtitle: Text(searchResults[index]['location']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HouseDetailsPage(
                    houseDetails: searchResults[index],
                    onRefresh: onRefresh,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> searchResults = rentItems
        .where((item) =>
            item['title'].toLowerCase().contains(query.toLowerCase()) ||
            item['location'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]['title']),
          subtitle: Text(searchResults[index]['location']),
          onTap: () {
            query = searchResults[index]['title'];
            showResults(context);
          },
        );
      },
    );
  }
}
