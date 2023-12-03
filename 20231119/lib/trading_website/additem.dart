import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuuapp/trading_website/data.dart';
import 'package:fluttertoast/fluttertoast.dart';

String selectedCategory = '';

class additem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<additem> {
  final ValueNotifier<XFile?> _imageFile = ValueNotifier(null);
  final ImagePicker _imagePicker = ImagePicker();
  final nameController = TextEditingController();
  final tnameController = TextEditingController();
  final numController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  final placeController = TextEditingController();
  final otherController = TextEditingController();
  late String name1;
  late String tname1;
  late int number1;
  late int price1;
  late String time1;
  late String phone1;
  late String place1;
  late String other1;
  late File image1;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> a = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    String loginname = a['loginname'];
    String i= a['traderid'];
    // 建立AppBar
    final appBar = AppBar(
      title: const Text('上架交易品資訊',style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.brown,
    );

    final btnD=_Dropdownwidge();

    final tname= TextField(
      controller: tnameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: '交易物名稱',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    var text1=const Text('類別:',style: TextStyle(fontSize: 20),);
    final number= TextField(
      controller: numController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: '數量',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    final price= TextField(
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
        labelText: '交易地點',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    final other= TextField(
      controller: otherController,
      maxLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2.0,
          ),
        ),
        labelText: '輸入交易品敘述',
        labelStyle: TextStyle(fontSize: 20),
      ),
    );

    File? imagePath=null;
    Future<void> _getImage(ImageSource imageSource) async {
      XFile? imgFile = await _imagePicker.pickImage(source: imageSource);
      if (imgFile!=null){
        _imageFile.value = imgFile;
        imagePath=File(imgFile.path);
      }
      else {
        imagePath = null;
      }
    }

    final btnCameraImage = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blueGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        '相機拍照',
        style: TextStyle( color: Colors.white,),
      ),
      onPressed: () => _getImage(ImageSource.camera),
    );

    final btnGalleryImage = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.blueGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        '挑選相簿照片',
        style: TextStyle( color: Colors.white,),
      ),
      onPressed: () => _getImage(ImageSource.gallery),
    );

    var text=const Text('圖片:');
    final btn = ElevatedButton(
        child: const Text('確定'),
        onPressed: () async {
          if (tnameController.text.isEmpty ||
              numController.text.isEmpty ||
              priceController.text.isEmpty ||
              phoneController.text.isEmpty ||
              placeController.text.isEmpty||
              otherController.text.isEmpty){
            showEmptyFieldsError(context);
          }else{
            tname1=tnameController.text;
            number1=int.parse(numController.text);
            price1=int.parse(priceController.text);
            phone1=phoneController.text;
            place1=placeController.text;
            other1=otherController.text;
            image1=imagePath!;
            await posttransactionData(tname1, selectedCategory, number1, price1,phone1,place1,other1,image1,loginname,i,0);
            Navigator.pop(context,true);
            showadditemResult(context);
          }
        }
    );

    final btn1 = ElevatedButton(
        child: const Text('取消'),
        onPressed: () {
          Navigator.pop(context,true);
        }
    );

    Widget _imageBuilder(BuildContext context, XFile? imageFile, Widget? child) {
      final wid = imageFile == null ?
      const Text('沒有照片'):
      Image.file(File(imageFile.path), fit: BoxFit.contain,);
      return wid;
    }

    final widget =Container(
        height:1000,
        child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: tname,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              child: text1,
                            ),
                            Container(
                              margin: const EdgeInsets.all(5),
                              child: btnD,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.all(5),
                                child: number,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.all(5),
                                child: price,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: phone,width: 400,margin: const EdgeInsets.all(10),
                      ),
                      Container(
                        child: place,width: 400,margin: const EdgeInsets.all(10),
                      ),
                      Container(
                        child: other,width: 600,padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      )
                    ],
                  ),
                ),
                Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: text,width: 40,margin: const EdgeInsets.all(5),
                          ),
                        ),
                        Container(
                            child: Column(
                              children: [Container(
                                child: btnCameraImage,
                                margin: const EdgeInsets.all(5),
                              ),
                                Container(
                                  child: btnGalleryImage,
                                  margin: const EdgeInsets.all(5),
                                ),
                              ],
                            )
                        ),
                        Expanded(
                          child: ValueListenableBuilder<XFile?>(
                            builder: _imageBuilder,
                            valueListenable: _imageFile,
                          ),
                        )
                      ],
                    )
                ),
                Container(
                    child: Row(
                      children: [
                        Container(
                          child: btn1,margin: const EdgeInsets.all(8),
                        ),
                        Expanded(
                            child:Container(
                              child: btn,alignment: Alignment.bottomRight,margin: const EdgeInsets.all(8),
                            )
                        )
                      ],
                    )
                ),
              ],
            )
        )
    );

    //final wid
    // 結合AppBar和App操作畫面
    final page = Scaffold(
      appBar: appBar,
      body: widget,
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
          child:  Text('書籍', style: TextStyle(fontSize: 20),),
          value: 1,
        ),
        DropdownMenuItem(
          child:  Text('生活用品', style: TextStyle(fontSize: 20),),
          value: 2,
        ),
        DropdownMenuItem(
          child:  Text('電子產品', style: TextStyle(fontSize: 20),),
          value: 3,
        ),
        DropdownMenuItem(
          child:  Text('其他', style: TextStyle(fontSize: 20),),
          value: 4,
        )
      ],
      onChanged: (dynamic value) {
        setState(() {
          selectedValue = value as int;
          selectedCategory = getCategory(value);
        });
      },

      hint: const Text('請選擇', style: TextStyle(fontSize: 20)),
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

void showadditemResult(BuildContext context) {
  String message =  '上架成功!' ;

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