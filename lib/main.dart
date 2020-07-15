import 'dart:async';
import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  AMap.init('1a83798190514cf82dbe799d6d4ac71c');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '导航',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  MapPage();

  factory MapPage.forDesignTime() => MapPage();

  @override
  _ShowMapScreenState createState() => _ShowMapScreenState();
}

class _ShowMapScreenState extends State<MapPage> {
  AMapController _controller;
  MyLocationStyle _myLocationStyle = MyLocationStyle();
  StreamSubscription _subscription;
  //相册选择
  Future _getImageFromGallery() async {
    File image=await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image);
  }
  //region 界面布局
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          '显示地图',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: AMapView(
              onAMapViewCreated: (controller) {
                _controller = controller;
                _subscription = _controller.markerClickedEvent
                    .listen((it) => print('地图点击: 坐标: $it'));
                //点击标注图标执行
                _controller.addMarker(MarkerOptions(
                  icon: 'images/place.png',
                  position: LatLng(22.2477900000, 113.5761300000),
                  title: '哈哈',
                  snippet: '呵呵',
                ),
                );
              },
              amapOptions: AMapOptions(
                compassEnabled: false,
                zoomControlsEnabled: true,
                logoPosition: LOGO_POSITION_BOTTOM_CENTER,
                camera: CameraPosition(
                  target: LatLng(22.2477900000, 113.5761300000),
                  zoom: 15,
                ),
              ),
            ),
          ),
          FlatButton(
            child: Text("圖片"),
            onPressed: _getImageFromGallery,
          ),
          Flexible(
            child: Builder(
              builder: (context) {
                return ListView(
                  children: <Widget>[
                    BooleanSetting(
                      head: '显示自己的位置 [Android, iOS]',
                      selected: false,
                      onSelected: (value) {
                        _updateMyLocationStyle(context, showMyLocation: value);
                      },
                    ),
                    RaisedButton(
                        child: Text('步行导航'),
                        onPressed: () {
                          AMapNavi().startNavi(
                            lat: 22.2477900000,
                            lon: 113.5761300000,
                            naviType: AMapNavi.walk,
                          );
                        }),
                    RaisedButton(
                        child: Text('骑行导航'),
                        onPressed: () {
                          AMapNavi().startNavi(
                            lat: 22.2477900000,
                            lon: 113.5761300000,
                            naviType: AMapNavi.ride,
                          );
                        }),
                    RaisedButton(
                        child: Text('车载导航'),
                        onPressed: () {
                          AMapNavi().startNavi(
                            lat: 22.2477900000,
                            lon: 113.5761300000,
                            naviType: AMapNavi.drive,
                          );
                        })
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  //endregion

  //region 权限申请
  void _updateMyLocationStyle(
    BuildContext context, {
    String myLocationIcon,
    double anchorU,
    double anchorV,
    Color radiusFillColor,
    Color strokeColor,
    double strokeWidth,
    int myLocationType,
    int interval,
    bool showMyLocation,
    bool showsAccuracyRing,
    bool showsHeadingIndicator,
    Color locationDotBgColor,
    Color locationDotFillColor,
    bool enablePulseAnnimation,
    String image,
  }) async {
    if (await Permissions().requestPermission()) {
      _myLocationStyle = _myLocationStyle.copyWith(
        myLocationIcon: myLocationIcon,
        anchorU: anchorU,
        anchorV: anchorV,
        radiusFillColor: radiusFillColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        myLocationType: myLocationType,
        interval: interval,
        showMyLocation: showMyLocation,
        showsAccuracyRing: showsAccuracyRing,
        showsHeadingIndicator: showsHeadingIndicator,
        locationDotBgColor: locationDotBgColor,
        locationDotFillColor: locationDotFillColor,
        enablePulseAnnimation: enablePulseAnnimation,
      );
      _controller.setMyLocationStyle(_myLocationStyle);
    } else {
      //ToastUtils.showToast( '权限不足');
    }
  }
  //endregion

  //region 销毁事件
  @override
  void dispose() {
    _controller?.dispose();
    _subscription?.cancel();
    super.dispose();
  }
//endregion

}

const SPACE_NORMAL = const SizedBox(width: 8, height: 8);
const kDividerTiny = const Divider(height: 1);



/// 二元设置
class BooleanSetting extends StatefulWidget {
  const BooleanSetting({
    Key key,
    @required this.head,
    @required this.onSelected,
    this.selected = false,
  }) : super(key: key);

  final String head;
  final ValueChanged<bool> onSelected;
  final bool selected;

  @override
  _BooleanSettingState createState() => _BooleanSettingState();
}

class _BooleanSettingState extends State<BooleanSetting> {

  bool _selected;

  @override
  void initState() {
    super.initState();

    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SwitchListTile(
          title: Text(widget.head),
          value: _selected,
          onChanged: (selected) {
            setState(() {
              _selected = selected;
              widget.onSelected(selected);
            });
          },
        ),
        kDividerTiny,
      ],
    );
  }
}

/// 输入文字
class TextSetting extends StatelessWidget {
  final String leadingString;
  final String hintString;

  const TextSetting({
    Key key,
    @required this.leadingString,
    @required this.hintString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(leadingString),
      title: TextFormField(
        decoration: InputDecoration(
          hintText: hintString,
        ),
      ),
    );
  }
}
