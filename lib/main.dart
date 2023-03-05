import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pausable_timer/pausable_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Player {
  var countDown = 120.0;
  var increment = 5.0;
  final Function() notifyParent;
  late PausableTimer timer;
  var name = "Player 1";

  Player({required this.notifyParent}) {
    print("Hello");
    timer = PausableTimer(Duration(milliseconds: 10), handleTimeout);
    //timer.start();
  }

  void handleTimeout() {
    countDown = countDown - 0.01;
    if (countDown > 0) {
      // we know the callback won't be called before the constructor ends, so
      // it is safe to use !
      timer
        ..reset()
        ..start();
    }
    notifyParent();
  }

  void startTurn(bool addIncrement) {
    timer.start();
    if (addIncrement) {
      countDown += increment;
    }
  }

  String formattedTime() {
    if (countDown < 0) return 'Outatime';
    int flooredValue = countDown.floor();
    int minutes = (flooredValue / 60).floor();
    int seconds = flooredValue - minutes * 60;
    double decimalValue = countDown - flooredValue;
    String minuteString = minutes.toString();
    String secondString = getSecondsString(seconds);
    String decimalString = getDecimalString(decimalValue);

    return '$minuteString:$secondString.$decimalString';
  }

  String getSecondsString(int secondsValue) {
    return secondsValue.toString().padLeft(2, '0');
  }

  String getDecimalString(double decimalValue) {
    return '${(decimalValue * 100).toInt()}'.padLeft(2, '0');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var _gameIsRunning = false;
  var _gameHasStarted = false;
  int _index = 0;
  CarouselController buttonCarouselController = CarouselController();

  refresh() {
    setState(() {});
  }

  late List<Player> players = [
    Player(notifyParent: refresh),
    Player(notifyParent: refresh)
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: CarouselSlider(
          carouselController: buttonCarouselController,
          options: CarouselOptions(
            onPageChanged: onNextPlayer,
            height: MediaQuery.of(context).size.height,
            enlargeCenterPage: true,
          ),
          items: players.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return getContainer(i);
              },
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startPauseGame,
        tooltip: 'start',
        child: _gameIsRunning
            ? const Icon(Icons.pause)
            : const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.flutter
    );
  }

  Widget getContainer(Player player) {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 50),
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(
            color: Colors.grey,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(75),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              alignment: Alignment.topCenter,
              widthFactor: 0.5,
              child: Container(
                  padding: EdgeInsets.all(20),
                  child: FittedBox(
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                    child: Text(player.name),
                  )),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              child: Text(
                player.formattedTime(),
              ),
            ),
          ],
        ));
  }

  startPauseGame() {
    _gameIsRunning = !_gameIsRunning;
    handleTimers(!_gameHasStarted);
    _gameHasStarted = true;
    refresh();
  }

  onNextPlayer(int index, CarouselPageChangedReason reason) {
    _index = index;
    handleTimers(true);
  }

  handleTimers(bool addIncrements) {
    players.forEach((element) {
      element.timer.pause();
    });
    if (_gameIsRunning) {
      players[_index].startTurn(addIncrements);
    }
  }
}
