import 'package:flutter/material.dart';
import 'package:nuuapp/ScooterUber/UberListPage/MyUberList.dart';
import '../../AccountServices/menu.dart';
import '../../main.dart';
import 'allUberList.dart';
import 'myReservedList.dart';

void main() {
  runApp(const UberList());
}

class UberList extends StatefulWidget {
  const UberList({super.key});

  @override
  _UberListState createState() => _UberListState();
}

class _UberListState extends State<UberList> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('共乘系統'),
      ),
      endDrawer: Menu(key: scaffoldKey),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentIndex == 0 ? Colors.blue[100] : null,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    )
                  ),
                  child: const Text('所有清單'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex == 1 ? Colors.blue[100] : null,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )
                  ),
                  child: const Text('我的清單'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex == 2 ? Colors.blue[100] : null,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      )
                  ),
                  child: const Text('已預約行程'),
                ),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                Container(
                  child: AllUberList(),
                ),
                Container(
                  child: MyUberList(),
                ),
                Container(
                  child: MyReservedList()
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
