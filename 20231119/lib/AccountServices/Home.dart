import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../RentHouse/RentHouse.dart';
import '../ScooterUber/UberListPage/UberList.dart';
import '../main.dart';
import '../trading_website/trading_website.dart';
import 'Login.dart';
import 'menu.dart';
import 'package:nuuapp/Providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('主頁面'),
        ),
        drawer: Menu(key: scaffoldKey),
        body: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 16.0,
          children: <Widget>[
            _buildNavigationButton(context, const UberList(), Icons.motorcycle_outlined, '共乘系統'),
            _buildNavigationButton(context, const trading_website(), Icons.shopping_cart, '二手物交易'),
            _buildNavigationButton(context, YourApp(), Icons.house_outlined, '租屋資訊平台'),
            _buildUrlButton('https://www.nuu.edu.tw/', Icons.link, '聯合大學總網'),
            _buildUrlButton('https://eap10.nuu.edu.tw/Login.aspx?logintype=S', Icons.link, '校務資訊系統'),
            _buildUrlButton('https://elearning.nuu.edu.tw/mooc/index.php', Icons.link, '聯合數位學園'),
            _buildUrlButton('https://sso.nuu.edu.tw/index.php?p=%E5%AD%B8%E7%94%9F%E5%B0%88%E5%8D%80', Icons.link, '單一簽入入口'),
            _buildUrlButton('https://curr.nuu.edu.tw/p/404-1076-6482.php', Icons.link, '行事曆'),
            _buildDynamicButton(context, userProvider.department),  // 新增的動態按鈕
            // 添加更多按鈕...
          ],
        ),
      );
    } else {
      return LoginPage();
    }
  }

  Widget _buildNavigationButton(BuildContext context, Widget page, IconData icon, String label) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildUrlButton(String url, IconData icon, String label) {
    return ElevatedButton(
      onPressed: () async {
        launch(url);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildDynamicButton(BuildContext context, String userDepartment) {
    String departmentUrl = getDepartmentUrl(userDepartment);
    return _buildUrlButton(departmentUrl, Icons.link, '學系網站');
  }

  String getDepartmentUrl(String userDepartment) {
    switch (userDepartment) {
      case '臺灣語文與傳播學系':
        return 'https://tlc.nuu.edu.tw/';
      case '華語文學系':
        return 'https://cll.nuu.edu.tw/';
      case '文化創意與數位行銷學系':
        return 'https://ccdm.nuu.edu.tw/';
      case '文化觀光產業學系':
        return 'https://doct.nuu.edu.tw/';
      case '工業設計學系':
        return 'https://id.nuu.edu.tw/';
      case '建築學系':
        return 'https://arch.nuu.edu.tw/';
      case '經營管理學系':
        return 'https://bm.nuu.edu.tw/';
      case '財務金融學系':
        return 'https://finance.nuu.edu.tw/';
      case '資訊管理學系':
        return 'https://impost.nuu.edu.tw/';
      case '電機工程學系':
        return 'https://ee.nuu.edu.tw/';
      case '電子工程學系':
        return 'https://deeweb.nuu.edu.tw/';
      case '光電工程學系':
        return 'https://eo.nuu.edu.tw/';
      case '資訊工程學系':
        return 'https://csie.nuu.edu.tw/';
      case '機械工程學系':
        return 'https://mech.nuu.edu.tw/';
      case '土木與防災工程學系':
        return 'https://civil.nuu.edu.tw/';
      case '化學工程學系':
        return 'https://che.nuu.edu.tw/';
    // 其他系所的映射...
      default:
        return 'https://www.nuu.edu.tw/';
    }
  }
}