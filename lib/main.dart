import 'package:flutter/material.dart';
import 'dart:async';

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

class _TabataTimerState extends State<TabataTimer> {
  late StreamController<int> _timerController;
  late Timer _timer;
  int _currentCycle = 1;
  int _totalCycles = 4;
  int _secondsLeft = 4;
  bool _isFirstTimer = true;

  @override
  void initState() {
    super.initState();
    _timerController = StreamController<int>();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timerController.add(_currentCycle);

        if (_isFirstTimer) {
          // Start the second countdown (3 seconds)
          _secondsLeft = 4;
          _isFirstTimer = false;
        } else {
          // Start the next cycle
          _currentCycle++;

          if (_currentCycle <= _totalCycles) {
            // Start the first countdown (4 seconds) for the next cycle
            _secondsLeft = 5;
            _isFirstTimer = true;
          } else {
            // Reset the timer when all cycles are completed
            resetTimer();
          }
        }
      }
    });
  }

  void resetTimer() {
    _timer.cancel();
    setState(() {
      _currentCycle = 1;
      _secondsLeft = 4;
      _isFirstTimer = true;
    });
    _timerController.add(_currentCycle);
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
            StreamBuilder<int>(
              stream: _timerController.stream,
              builder: (context, snapshot) {
                return Text(
                  'Cycle $_currentCycle/$_totalCycles',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                );
              },
            ),
            SizedBox(height: 20),
            _secondsLeft >= 0
                ? Text(
                    '$_secondsLeft seconds',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  )
                : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                startTimer();
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
                resetTimer();
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
    _timerController.close();
    super.dispose();
  }
}
