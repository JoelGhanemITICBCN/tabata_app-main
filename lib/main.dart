import 'package:flutter/material.dart';

void main() => runApp(TabataApp());

class TabataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: TabataTimer(),
    );
  }
}

class TabataTimer extends StatefulWidget {
  @override
  _TabataTimerState createState() => _TabataTimerState();
}

class _TabataTimerState extends State<TabataTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late CountdownTimer _countdownTimer;
  int _currentCycle = 1;
  int _totalCycles = 4;
  bool _isFirstTimer = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _countdownTimer = CountdownTimer(
      controller: _animationController,
      onEnd: () => _handleTimerEnd(),
    );
  }

  void _startTimer() {
    _countdownTimer.start();
  }

  void _resetTimer() {
    _countdownTimer.reset();
    setState(() {
      _currentCycle = 1;
      _isFirstTimer = true;
    });
  }

  void _handleTimerEnd() {
    setState(() {
      _currentCycle++;

      if (_isFirstTimer) {
        _animationController.duration = Duration(seconds: 3);
        _isFirstTimer = false;
      } else {
        if (_currentCycle <= _totalCycles) {
          _animationController.duration = Duration(seconds: 4);
          _isFirstTimer = true;
        } else {
          _resetTimer();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabata Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Cycle $_currentCycle/$_totalCycles',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                LinearProgressIndicator(
                  value: _animationController.value,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 50,
                ),
                Text(
                  '${_animationController.duration!.inSeconds - _animationController.value.floor()} seconds',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _startTimer();
              },
              child: Text('Start', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _resetTimer();
              },
              child: Text('Reset', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CountdownTimer {
  final AnimationController controller;
  final VoidCallback onEnd;

  CountdownTimer({required this.controller, required this.onEnd});

  void start() {
    controller.forward(from: 0.0);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onEnd();
      }
    });
  }

  void reset() {
    controller.stop();
    controller.reset();
  }
}
