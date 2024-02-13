import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(TabataApp());

class TabataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final musica = AudioPlayer();
  String potente = 'musica/potente.mp3';
  String flojo = 'musica/flojo.mp3';

  @override
  void initState() {
    super.initState();
    _timerController = StreamController<int>();
  }

  Color getCircleColor() {
    return _isFirstTimer ? Colors.green : Colors.red;
  }

  double calculateProgress() {
    double totalTime = _isFirstTimer ? 4 : 3;
    double elapsedRatio =
        (_isFirstTimer ? _secondsLeft : (3 - _secondsLeft)) / totalTime;
    return 1 - elapsedRatio;
  }

  Future<void> startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timerController.add(_currentCycle);

        if (_isFirstTimer) {
          musica.stop();
          _secondsLeft = 4;
          await musica.play(UrlSource(flojo));
          _isFirstTimer = false;
        } else {
          _currentCycle++;

          if (_currentCycle <= _totalCycles) {
            musica.stop();
            _secondsLeft = 5;
            await musica.play(UrlSource(potente));
            _isFirstTimer = true;
          } else {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<int>(
            stream: _timerController.stream,
            builder: (context, snapshot) {
              return Text(
                'Cicle $_currentCycle/$_totalCycles',
                style: TextStyle(fontSize: 24, color: Colors.white),
              );
            },
          ),
          SizedBox(height: 10),
          _secondsLeft >= 0
              ? Text(
                  '$_secondsLeft seconds',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                )
              : Container(),
          SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: calculateProgress(),
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(getCircleColor()),
                strokeWidth: 10,
                semanticsLabel: 'Timer Progress',
              ),
            ),
          ),
          SizedBox(height: 10),
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
          SizedBox(height: 10),
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
    );
  }

  @override
  void dispose() {
    _timerController.close();
    super.dispose();
  }
}
