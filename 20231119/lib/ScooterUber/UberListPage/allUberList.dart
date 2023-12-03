import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuuapp/ScooterUber/addUberList.dart';
import 'package:nuuapp/ScooterUber/SearchBottomSheet.dart';
import 'package:http/http.dart' as http;
import '../../Providers/UberList_provider.dart';
import '../detail_dialog.dart';

void main() => runApp(const AllUberList());

class AllUberList extends StatefulWidget {
  final VoidCallback? onItemAdded;

  const AllUberList({Key? key, this.onItemAdded}) : super(key: key);

  @override
  AllUberListState createState() => AllUberListState();

  static final GlobalKey<AllUberListState> uberListKey =
      GlobalKey<AllUberListState>();
}

class AllUberListState extends State<AllUberList> {
  List<UberItem> uberList = [];

  @override
  void initState() {
    super.initState();
    loadCards(context);
  }

  Future<void> loadCards(BuildContext context) async {
    try {
      List<UberItem> updatedList = await fetchData();
      context.read<UberListProvider>().setList(updatedList);
    } catch (e) {
      print('載入時錯誤:$e');
    }
  }

  Future<List<UberItem>> fetchData() async {
    const String apiUrl = 'https://c57d84a7c52ef7e92c1f78c1b3f9b4b3.serveo.net/api/uberList/getAllList';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'];

      List<UberItem> uberList = data.map((json) {
        return UberItem.fromJson(json);
      }).toList();

      return uberList;
    } else {
      throw Exception('載入失敗');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UberListProvider>(
      builder: (context, providerItem, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              providerItem.uberList.isEmpty
                  ? const Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "目前沒有任何清單",
                            style: TextStyle(fontSize: 20.0),
                          )
                      )
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: providerItem.uberList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final item = providerItem.uberList[index];
                          return Card(
                            child: ListTile(
                              leading: Column(
                                children: [
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const Icon(Icons.directions_car),
                                  Text(
                                    item.reserved ? "已預約" : "未預約",
                                    style: TextStyle(
                                      color: item.reserved
                                          ? Colors.green[900]
                                          : Colors.red[900],
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                  '從 ${item.startingLocation} 到 ${item.destination}'),
                              subtitle: Text(
                                  '${DateFormat('yyyy-MM-dd HH:mm').format(item.selectedDateTime)} 出發'),
                              trailing: Text(
                                item.wantToFindRide ? '找車搭乘' : '提供搭乘',
                                style: TextStyle(
                                  color: item.wantToFindRide
                                      ? Colors.orange[900]
                                      : Colors.lightBlue[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                showDetailsDialog(context, item).then((result) {
                                  if( result == true){
                                    Future.microtask(() => loadCards(context));
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // FloatingActionButton(
                      //   child: const Icon(Icons.add),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => const AddUberList()),
                      //     ).then((result) {
                      //       if (result == true) {
                      //         loadCards(context);
                      //       }
                      //     });
                      //   },
                      // ),
                      BottomAppBar(
                        shape: const CircularNotchedRectangle(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) =>
                                      const SearchBottomSheet(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}
