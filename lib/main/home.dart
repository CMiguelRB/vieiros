import 'package:flutter/material.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/tabs/info.dart';
import 'package:vieiros/tabs/settings.dart';
import '../tabs/map.dart';
import 'package:vieiros/tabs/tracks.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _tabIndex = 0;
  Icon _fabIcon = Icon(Icons.add);

  late List<Widget> tabs;
  late TabController _tabController;
  late CurrentTrack _currentTrack = CurrentTrack();

  final _mapKey = GlobalKey<MapState>();
  final _trackKey = GlobalKey<TracksState>();

  void _onTabItemTapped(int index) {
    setState(() {
      _tabIndex = index;
      _tabController.animateTo(index);
    });
    if(index == 1){
      if(_mapKey.currentState != null){
        _mapKey.currentState!.loadCurrentTrack();
        if(_currentTrack.isRecording()){
          _fabIcon = Icon(Icons.stop);
          return;
        }
      }
      _fabIcon = Icon(Icons.play_arrow);
    }else{
      _fabIcon = Icon(Icons.add);
    }
  }

  void _setPlayFabIcon(){
    setState(() {
      _fabIcon = Icon(Icons.play_arrow);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    tabs = <Widget>[
      Tracks(key: _trackKey, toTabIndex: _onTabItemTapped, currentTrack: _currentTrack),
      Map(key: _mapKey, setPlayIcon: _setPlayFabIcon, currentTrack: _currentTrack),
      Info(currentTrack: _currentTrack),
      Settings()
    ];
    _tabController = TabController(vsync: this, length: tabs.length, initialIndex: _tabIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed && _tabIndex == 1 && _mapKey.currentState != null){
      _mapKey.currentState!.getLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  _onFabPressed(index){
    if(index == 0 && _trackKey.currentState != null){
      _trackKey.currentState!.openFile();
    }
    if(index == 1 && _mapKey.currentState != null){
      if(!_currentTrack.isRecording()){
        _mapKey.currentState!.startRecording();
        setState(() {
          _fabIcon = Icon(Icons.stop);
        });
      }else{
        _mapKey.currentState!.stopRecording();
      }
    }
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
            body: TabBarView(
                controller: _tabController,
                children: tabs
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _tabIndex <= 1 ? FloatingActionButton(
              heroTag: null,
              child: _fabIcon,
              onPressed: () => _onFabPressed(_tabIndex),
            ):null,
            bottomNavigationBar: BottomAppBar(
                shape: CircularNotchedRectangle(),
                notchMargin: 4.0,
                clipBehavior: Clip.antiAlias,
                child: BottomNavigationBar(
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
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  )
                ],
                currentIndex: _tabIndex,
                selectedItemColor: Colors.blueGrey,
                unselectedItemColor: Colors.black,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                showUnselectedLabels: true,
                onTap: _onTabItemTapped
            ))
        );
  }
}
