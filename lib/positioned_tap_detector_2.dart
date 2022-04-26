import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'positioned_tap_detector_2.dart';
//import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

typedef TapPositionCallback(TapPosition position);

class PositionedTapDetector2 extends StatefulWidget {
  PositionedTapDetector2({
    Key? key,
    this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.doubleTapDelay = _defaultDelay,
    this.behavior,
    this.controller,
  }) : super(key: key);

  static const _defaultDelay = Duration(milliseconds: 250);
  static const _doubleTapMaxOffset = 48.0;

  final Widget? child;
  final HitTestBehavior? behavior;
  final TapPositionCallback? onTap;
  final TapPositionCallback? onDoubleTap;
  final TapPositionCallback? onLongPress;
  final Duration doubleTapDelay;
  final PositionedTapController? controller;

  @override
  _TapPositionDetectorState createState() => _TapPositionDetectorState();
}

class _TapPositionDetectorState extends State<PositionedTapDetector2> {
  StreamController<TapDownDetails> _controller = StreamController();

  Stream<TapDownDetails> get _stream => _controller.stream;

  Sink<TapDownDetails> get _sink => _controller.sink;

  PositionedTapController? _tapController;
  TapDownDetails? _pendingTap;
  TapDownDetails? _firstTap;

  @override
  void initState() {
    _updateController();
    _stream
        .timeout(widget.doubleTapDelay)
        .handleError(_onTimeout, test: (e) => e is TimeoutException)
        .listen(_onTapConfirmed);
    super.initState();
  }

  @override
  void didUpdateWidget(PositionedTapDetector2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateController();
    }
  }

  void _updateController() {
    _tapController?._state = null;
    if (widget.controller != null) {
      widget.controller!._state = this;
      _tapController = widget.controller;
    }
  }

  void _onTimeout(dynamic error) {
    if (_firstTap != null && _pendingTap == null) {
      _postCallback(_firstTap!, widget.onTap);
    }
  }

  void _onTapConfirmed(TapDownDetails details) {
    if (_firstTap == null) {
      _firstTap = details;
    } else {
      _handleSecondTap(details);
    }
  }

  void _handleSecondTap(TapDownDetails secondTap) {
    if (_isDoubleTap(_firstTap!, secondTap)) {
      _postCallback(secondTap, widget.onDoubleTap);
    } else {
      _postCallback(_firstTap!, widget.onTap);
      _postCallback(secondTap, widget.onTap);
    }
  }

  bool _isDoubleTap(TapDownDetails d1, TapDownDetails d2) {
    final dx = (d1.globalPosition.dx - d2.globalPosition.dx);
    final dy = (d1.globalPosition.dy - d2.globalPosition.dy);
    return sqrt(dx * dx + dy * dy) <=
        PositionedTapDetector2._doubleTapMaxOffset;
  }

  void _onTapDownEvent(TapDownDetails details) {
    _pendingTap = details;
  }

  void _onTapEvent() {
    if (widget.onDoubleTap == null) {
      _postCallback(_pendingTap!, widget.onTap);
    } else {
      _sink.add(_pendingTap!);
    }
    _pendingTap = null;
  }

  void _onLongPressEvent() {
    final pending = _pendingTap;
    if (pending != null) {
      if (_firstTap == null) {
        _postCallback(pending, widget.onLongPress);
      } else {
        _sink.add(pending);
        _pendingTap = null;
      }
    }
  }

  void _postCallback(
      TapDownDetails details, TapPositionCallback? callback) async {
    _firstTap = null;
    if (callback != null) {
      callback(_getTapPositions(details));
    }
  }

  TapPosition _getTapPositions(TapDownDetails details) {
    final topLeft = _getWidgetTopLeft();
    final global = details.globalPosition;
    final relative = topLeft != null ? global - topLeft : null;
    return TapPosition(global, relative);
  }

  Offset? _getWidgetTopLeft() {
    final translation =
        context.findRenderObject()?.getTransformTo(null).getTranslation();
    return translation != null ? Offset(translation.x, translation.y) : null;
  }

  @override
  void dispose() {
    _controller.close();
    _tapController?._state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) {
      if (widget.child != null) {
        return widget.child!;
      } else {
        return Container();
      }
    }
    return GestureDetector(
      child: widget.child,
      behavior: (widget.behavior ??
          (widget.child == null
              ? HitTestBehavior.translucent
              : HitTestBehavior.deferToChild)),
      onTap: _onTapEvent,
      onLongPress: _onLongPressEvent,
      onTapDown: _onTapDownEvent,
    );
  }
}

class PositionedTapController {
  _TapPositionDetectorState? _state;

  void onTap() => _state?._onTapEvent();

  void onLongPress() => _state?._onLongPressEvent();

  void onTapDown(TapDownDetails details) => _state?._onTapDownEvent(details);
}

class TapPosition {
  TapPosition(this.global, this.relative);

  Offset global;
  Offset? relative;

  @override
  bool operator ==(dynamic other) {
    if (other is! TapPosition) return false;
    final TapPosition typedOther = other;
    return global == typedOther.global && relative == other.relative;
  }

  @override
  int get hashCode => hashValues(global, relative);
}

void _onLongPress(TapPosition position) {
  var objects = [
    {
      "xmin": 13.4,
      "ymin": 26,
      "xmax": 577.4783935547,
      "ymax": 971.469543457,
      "confidence": 0.5053740144,
      "class": 15,
      "name": "cat"
    },
    {
      "xmin": 14.6,
      "ymin": 587.4,
      "xmax": 584.1717529297,
      "ymax": 314.2608642578,
      "confidence": 0.3363454342,
      "class": 75,
      "name": "vase"
    }
  ];

  var objects2 = {'image_array': objects, 'google_api_name': "name"};
  var temp = position.relative.toString();
  var parse = temp.split('(');
  parse = parse[1].split(',');
  double x = double.parse(parse[0]);
  parse = parse[1].split(')');
  double y = double.parse(parse[0]);
  int index = get_near_object(objects2["image_array"], x, y);
  print(index);
  String url = 'https://www.google.com/';
  // open_url(url);

  print('onneeeeeeeeeeeeeeeeeeeee');
  launchURL(url);
  print('twwoooooooooooooooooooooo');

  // WebView(
  //   initialUrl: url,
  //   javascriptMode: JavascriptMode.unrestricted,
  // );
  //String url =
  // "https://www.google.com/searchbyimage?site=search&sa=X&image_url={domain}/image_search/${objects2["google_api_name"]}${objects2["image_array"][index]["xmin"]}${objects2["image_array"][index]["ymin"]}${objects2["image_array"][index]["xmax"]}${objects2["image_array"][index]["ymax"]}.jpg";
}

// void _onLongPress(TapPosition position) =>
//     _updateState('long press', position);

int get_near_object(var objects, double x, double y) {
  double distance = 4294967296;
  double temp;
  int index = 0;
  for (int i = 0; i < objects.length; i++) {
    temp = ((x - objects[i]["xmin"]) * (x - objects[i]["xmin"])) +
        ((y - objects[i]["ymin"]) * (y - objects[i]["ymin"]));
    if (temp < distance) {
      distance = temp;
      index = i;
    }
  }
  return index;
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}
