import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nuuapp/Providers/user_provider.dart';

import 'Login.dart';
import 'ProfileSetting.dart';


class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text( context.watch<UserProvider>().username ),
            accountEmail: Text( context.watch<UserProvider>().email ),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage("assets/avatar.jpg"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("主頁面"),
            onTap: () {
              // Handle the Home menu item tap
              Navigator.pop(context);
              },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("編輯個人檔案"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSetting()),
              );
            // Handle the Profile menu item tap
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("設定"),
            onTap: () {
            // Handle the Settings menu item tap
            Navigator.pop(context);
              },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("登出"),
            onTap: () {
              context.read<UserProvider>().setUserLoggedOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

