import 'package:flutter/material.dart';
import 'package:vieiros/tabs/info.dart';
import 'package:vieiros/tabs/waypoints.dart';
import '../tabs/map.dart';
import '../tabs/tracks.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with TickerProviderStateMixin {
  String _title = 'Vieiros';

  int _tabIndex = 0;

  late List<Widget> tabs;
  late TabController _tabController;

  void _onTabItemTapped(int index) {
    setState(() {
      _tabIndex = index;
      _tabController.animateTo(index);
    });
  }

  @override
  void initState() {
    super.initState();
    tabs = <Widget>[
      Tracks(),
      Map(),
      Info(),
      Waypoints()
    ];
    _tabController = TabController(vsync: this, length: tabs.length, initialIndex: _tabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(_title),
            ),
            body: TabBarView(
                controller: _tabController,
                children: tabs
            ),
            bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timeline),
                    label: 'Tracks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.terrain),
                    label: 'Map',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.insert_chart_rounded),
                    label: 'Info',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flag_rounded),
                    label: 'Waypoints',
                  )
                ],
                currentIndex: _tabIndex,
                selectedItemColor: Colors.blueGrey,
                unselectedItemColor: Colors.black,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                showUnselectedLabels: true,
                onTap: _onTabItemTapped
            )
        );
  }
}
