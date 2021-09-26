import 'dart:io';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vieiros/components/vieiros_notification.dart';
import 'package:vieiros/model/loaded_track.dart';
import 'package:flutter/material.dart';
import 'package:vieiros/model/current_track.dart';
import 'package:vieiros/resources/i18n.dart';
import 'package:vieiros/tabs/info.dart';
import 'package:vieiros/tabs/settings.dart';
import '../tabs/map.dart';
import 'package:vieiros/tabs/tracks.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  final LoadedTrack loadedTrack;

  Home({Key? key, required this.prefs, required this.loadedTrack})
      : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  static const platform =
  const MethodChannel('com.rabocorp.vieiros/opened_file');

  void getOpenedFile() async {
      String? gpxStringFile = await platform.invokeMethod("getOpenedFile");
      if(gpxStringFile == null) return;
      _trackKey.currentState!.openFileFromIntent(gpxStringFile);
  }

  int _tabIndex = 0;
  Icon _fabIcon = Icon(Icons.add);

  late List<Widget> _tabs;
  late TabController _tabController;
  late CurrentTrack _currentTrack = CurrentTrack();

  final _mapKey = GlobalKey<MapState>();
  final _trackKey = GlobalKey<TracksState>();
  final _infoKey = GlobalKey<InfoState>();

  void _onTabItemTapped(int index) async {
    if (index == 1) {
      if (_mapKey.currentState != null) {
        String? path = widget.prefs.getString('currentTrack');
        if (path != null && widget.loadedTrack.path != path) {
          widget.loadedTrack.clear();
          _mapKey.currentState!.loadTrack(path);
          if (_infoKey.currentState != null) {
            _infoKey.currentState!.clearScreen();
          }
        }
        if (path != null && widget.loadedTrack.path == path) {
          _mapKey.currentState!.navigateTrack(path);
        }
        if (_currentTrack.isRecording) {
          _fabIcon = const Icon(Icons.stop);
          if (this.mounted)
            setState(() {
              _tabIndex = index;
              _tabController.animateTo(index);
            });
          return;
        }
      } else {
        String? path = widget.prefs.getString('currentTrack');
        if (path != null && widget.loadedTrack.path != path) {
          await widget.loadedTrack.loadTrack(path);
        }
      }
      _fabIcon = const Icon(Icons.play_arrow);
    } else if (index == 2) {
      if (_infoKey.currentState != null) {
        String? path = widget.prefs.getString('currentTrack');
        if (path != null && _infoKey.currentState!.currentPath != path) {
          widget.loadedTrack.clear();
          _infoKey.currentState!.loadTrack(path);
        }
      }
    } else {
      _fabIcon = const Icon(Icons.add);
    }
    if (this.mounted)
      setState(() {
        _tabIndex = index;
        _tabController.animateTo(index);
      });
  }

  void _setPlayFabIcon() {
    setState(() {
      _fabIcon = const Icon(Icons.play_arrow);
    });
  }

  void _clearTrack() {
    if (_mapKey.currentState != null) {
      _mapKey.currentState!.clearTrack();
    }
    if (_infoKey.currentState != null) {
      _infoKey.currentState!.clearLoaded();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    getOpenedFile();
    _tabs = <Widget>[
      Tracks(
          key: _trackKey,
          prefs: widget.prefs,
          toTabIndex: _onTabItemTapped,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack,
          clearTrack: _clearTrack),
      Map(
          key: _mapKey,
          prefs: widget.prefs,
          setPlayIcon: _setPlayFabIcon,
          currentTrack: _currentTrack,
          loadedTrack: widget.loadedTrack),
      Info(
          key: _infoKey,
          currentTrack: _currentTrack,
          prefs: widget.prefs,
          loadedTrack: widget.loadedTrack),
      Settings(prefs: widget.prefs)
    ];
    _tabController = TabController(
        vsync: this, length: _tabs.length, initialIndex: _tabIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  _onFabPressed(index) {
    if (index == 0 && _trackKey.currentState != null) {
      _trackKey.currentState!.openFile();
    }
    if (index == 1 && _mapKey.currentState != null) {
      if (!_currentTrack.isRecording) {
        _mapKey.currentState!.startRecording();
        if (this.mounted)
          setState(() {
            _fabIcon = Icon(Icons.stop);
          });
      } else {
        _mapKey.currentState!.stopRecording();
      }
    }
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems(){
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.timeline),
        label: I18n.translate('appbar_tab_tracks'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.terrain),
        label: I18n.translate('appbar_tab_map'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.insert_chart_rounded),
        label: I18n.translate('appbar_tab_info'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: I18n.translate('appbar_tab_settings'),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: _tabs),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _tabIndex <= 1
            ? FloatingActionButton(
                heroTag: null,
                child: _fabIcon,
                onPressed: () => _onFabPressed(_tabIndex),
              )
            : null,
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 4.0,
            clipBehavior: Clip.antiAlias,
            child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: _bottomNavigationBarItems(),
                currentIndex: _tabIndex,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                showUnselectedLabels: true,
                onTap: _onTabItemTapped)));
  }
}
