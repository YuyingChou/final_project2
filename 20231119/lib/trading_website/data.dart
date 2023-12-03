import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
class Trader {
   String id;
   String name;
   String studentID;
   String phone;
   String email;
   String departmentclass;

  Trader({
    required this.id,
    required this.name,
    required this.studentID,
    required this.phone,
    required this.email,
    required this.departmentclass,
  });

  factory Trader.fromJson(Map<String, dynamic> json) {
    return Trader(
      id: json['_id'],
      name: json['name'],
      studentID: json['studentID'],
      phone: json['phone'],
      email: json['email'],
      departmentclass: json['departmentclass'],
    );
  }
}
class TransactionImage {
  final String type;
  final List<int> data;

  TransactionImage({
    required this.type,
    required this.data,
  });

  factory TransactionImage.fromJson(Map<String, dynamic> json) {
    return TransactionImage(
      type: json['type'] as String,
      data: List<int>.from(json['data']),
    );
  }
}

class Transaction {
  String id;
  String transactionname;
  String category;
  int quantity;
  int price;
  String description;
  String contact;
  String place;
  TransactionImage image;
  String seller;
  String sellerid;
  int status;

  Transaction({
    required this.id,
    required this.transactionname,
    required this.category,
    required this.quantity,
    required this.price,
    required this.description,
    required this.contact,
    required this.place,
    required this.image,
    required this.seller,
    required this.sellerid,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id:json['_id'],
      transactionname: json['transactionname'],
      category: json['category'] ,
      quantity: json['quantity'] ,
      price: json['price'] ,
      description: json['description'],
      contact: json['contact'],
      place: json['place'] ,
      image: TransactionImage.fromJson(json['image'] ?? {}),
      seller: json['seller'] ,
      sellerid: json['sellerid'] ,
      status: json['status'] ,
    );
  }
}
class Textbook {
  String id;
  String name;
  String isbn;
  int quantity;
  int price;
  String phone;
  String place;
  DateTime closingTime;
  DateTime booksellerReceivedTime;
  String organizer;
  String organizerId;
  String describe;
  int status;
  String bookseller;
  String booksellerPhone;
  String bookWillArrivalTime;
  int getbookstatus;
  DateTime bookArrivalTime;

  Textbook({
    required this.id,
    required this.name,
    required this.isbn,
    required this.quantity,
    required this.price,
    required this.phone,
    required this.place,
    required this.closingTime,
    required this.booksellerReceivedTime,
    required this.organizer,
    required this.organizerId,
    required this.describe,
    required this.status,
    required this.bookseller,
    required this.booksellerPhone,
    required this.bookWillArrivalTime,
    required this.getbookstatus,
    required this.bookArrivalTime,
  });

  // Factory constructor to create a Textbook instance from a JSON object
  factory Textbook.fromJson(Map<String, dynamic> json) {
    return Textbook(
      id:json['_id'],
      name: json['name'],
      isbn: json['isbn'],
      quantity: json['quantity'],
      price: json['price'],
      organizer: json['organizer'],
      organizerId: json['organizerid'],
      place: json['place'],
      phone: json['phone'],
      describe: json['describe'],
      status: json['status'],
      closingTime: DateTime.parse(json['closingtime']),
      booksellerReceivedTime: DateTime.parse(json['booksellerreceivedtime']),
      bookseller: json['bookseller'],
      booksellerPhone: json['booksellerphone'],
      bookWillArrivalTime: json['bookwillarrivaltime'],
      getbookstatus: json['getbookstatus'],
      bookArrivalTime: DateTime.parse(json['bookarrivaltime']),
    );
  }
}
Future<void> posttextbookData(String name,String isbn,int number,int price,String organizer,String organizerid,String place,String phone,int status,DateTime closingTime,String describe,DateTime booksellerReceivedTime,String bookseller,String booksellerPhone,String bookwillArrivalTime,int getbookkstatus,DateTime bookArrivalTime) async{
  try {
    // 調用 createAlbum 函數發送 POST 請求
    final response = await textbook(name,isbn,number,price,organizer,organizerid,place,phone,status,closingTime,describe,booksellerReceivedTime,bookseller,booksellerPhone,bookwillArrivalTime,getbookkstatus,bookArrivalTime);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final String textbookId = jsonResponse['textbookId'];
      print('成功，textbook ID: $textbookId');
    } else {
      print("失敗:${response.body} ");
    }
  } catch (e) {
    // 發生錯誤
    print('失敗: $e');
  }
}
Future<http.Response> textbook(String name,String isbn,int number,int price,String organizer,String organizerid,String place,String phone,int status,DateTime closingTime,String describe,DateTime booksellerReceivedTime,String bookseller,String booksellerPhone,String bookwillArrivalTime,int getbookstatus,DateTime bookArrivalTime) async {

  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/textbook/add';

  Map<String, dynamic> textbookData ={
    'name': name,
    'isbn': isbn,
    'quantity': number,
    'price': price,
    'phone': phone,
    'place': place,
    'closingtime': closingTime.toUtc().toIso8601String(),
    'booksellerreceivedtime': booksellerReceivedTime.toUtc().toIso8601String(),
    'organizer': organizer,
    'organizerid': organizerid,
    'describe': describe,
    'status': status,
    'bookseller': bookseller,
    'booksellerphone': booksellerPhone,
    'bookwillarrivaltime': bookwillArrivalTime,
    'getbookstatus': getbookstatus,
    'bookarrivaltime':bookArrivalTime.toUtc().toIso8601String(),
  };
  print(textbookData);
  return http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(textbookData),
  );
}
Future<void> posttransactionData(String tname,String category,int number,int price,String phone,String place,String other,File image,String seller,String sellerid,int status ) async{
  try {
    // 調用 createAlbum 函數發送 POST 請求
    final response = await createAlbum(tname,category,number,price,phone,place,other,image,seller,sellerid,status);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final String transactionId = jsonResponse['transactionId'];
      print('成功，交易物 ID: $transactionId');
    } else {
      print("失敗:${response.body} ");
    }
  } catch (e) {
    // 發生錯誤
    print('失敗: $e');
  }
}
Future<http.Response> createAlbum(String tname,String category,int number,int price,String phone,String place,String other,File image,String seller,String sellerid,int status) async {

  List<int> imageBytes = await image.readAsBytes();
  int quality = 50;
  Uint8List uint8ImageBytes = Uint8List.fromList(imageBytes);
  List<int> compressedBytes = await FlutterImageCompress.compressWithList(
    uint8ImageBytes,
    minHeight: 640,
    minWidth: 640,
    quality: quality,
    rotate: 0,
  );
  Uint8List compressedImage = Uint8List.fromList(compressedBytes);
  List<int> intList = compressedImage.toList();
  final String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/transactions/transaction/add';

  final Map<String, dynamic> transactionData = {
    'transactionname': tname,
    'category': category,
    'quantity': number,
    'price': price,
    'description': other,
    'place': place,
    'contact': phone,
    'image': intList,
    'seller': seller,
    'sellerid': sellerid,
    'status': status,
  };
  print(transactionData);
  return http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(transactionData),
  );
}
class TextbookOrder {
  final String buyer;
  final String buyerId;
  final String buyerPhone;
  final String organizer;
  final String organizerPhone;
  final String organizerId;
  final String bookId;
  final DateTime time;
  final int quantity;

  TextbookOrder({
    required this.buyer,
    required this.buyerId,
    required this.buyerPhone,
    required this.organizer,
    required this.organizerPhone,
    required this.organizerId,
    required this.bookId,
    required this.time,
    required this.quantity,
  });

  factory TextbookOrder.fromJson(Map<String, dynamic> json) {
    return TextbookOrder(
      buyer: json['buyer'],
      buyerId: json['buyerid'],
      buyerPhone: json['buyerphone'],
      organizer: json['organizer'],
      organizerPhone: json['organizerphone'],
      organizerId: json['organizerid'],
      bookId: json['bookID'],
      time: DateTime.parse(json['time']),
      quantity: json['quantity'],
    );
  }
}