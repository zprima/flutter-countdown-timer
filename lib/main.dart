import 'dart:ffi';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as v_math;

final int _twoHoursInSec = 7200; //2 * 60 * 60

class TimerViewModel extends ChangeNotifier {
  int _value = _twoHoursInSec;
  int get value => _value;

  Timer _timer;

  void startTimer(AnimationController controller) {
    if (_timer != null) {
      _timer.cancel();
      _value = _twoHoursInSec;
    }

    _timer = new Timer.periodic(
      new Duration(seconds: 1),
      timerCallback,
    );

    if (controller.isAnimating) {
      controller.stop();
    }

    controller.value = 0.0;
    controller.repeat();
  }

  void stopTimer(AnimationController controller) {
    if (_timer != null) {
      _timer.cancel();
    }

    controller.stop();
  }

  void timerCallback(Timer callbackTimer) {
    if (_value <= 0) {
      callbackTimer.cancel();
    } else {
      _value--;
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TimerContent(),
        ),
      ),
    );
  }
}

class TimerContent extends StatefulWidget {
  final Duration duration = Duration(seconds: 1);

  @override
  _TimerContentState createState() => _TimerContentState();
}

class _TimerContentState extends State<TimerContent>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _growAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        setState(() {});
      });

    _growAnimation = Tween<double>(begin: 0, end: 360).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TimerViewModel>(context);

    return Column(
      children: [
        FlatButton(
          onPressed: () => {vm.startTimer(_controller)},
          child: Text("Start"),
          color: Colors.green,
        ),
        FlatButton(
          onPressed: () => {vm.stopTimer(_controller)},
          child: Text("Stop"),
          color: Colors.red,
        ),
        Text("VM value: ${vm.value}"),
        Text("Animation value: ${_growAnimation.value.round()}"),
        Text("Canvas with arc"),
        CustomPaint(
          size: Size(200.0, 200.0),
          painter: ArcPainter(_growAnimation.value),
        ),
        Text("Circular progress indicator"),
        SizedBox(
          height: 200.0,
          width: 200.0,
          child: CircularProgressIndicator(
              strokeWidth: 4, value: _growAnimation.value / 360.0),
        ),
      ],
    );
  }
}

class ArcPainter extends CustomPainter {
  double _aniValue = 0.0;

  ArcPainter(aniValue) {
    this._aniValue = aniValue;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double startAngle = -math.pi / 2;
    final double sweepAngle = v_math.radians(this._aniValue);

    final rect = Rect.fromLTRB(10, 10, size.width, size.height);

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
