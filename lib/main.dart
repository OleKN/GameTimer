import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:wakelock/wakelock.dart';

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
  var name = "Player";
  Color bgColor = Colors.red;
  Color textColor = Colors.green;


  void setBgColor(Color color){
    bgColor = color;
    textColor = color.computeLuminance() < 0.5 ? Colors.white : Colors.black;
    notifyParent();
  }

  Player(this.name, {required this.notifyParent}) {
    var rng = Random();
    timer = PausableTimer(Duration(seconds: 1), handleTimeout);
    setBgColor(Color.fromARGB(255, rng.nextInt(255), rng.nextInt(255), rng.nextInt(255)));
  }

  void handleTimeout() {
    countDown = countDown - 1;
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
    String minuteString = minutes.toString();
    String secondString = getSecondsString(seconds);

    return '$minuteString:$secondString';
  }

  String getSecondsString(int secondsValue) {
    return secondsValue.toString().padLeft(2, '0');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var _gameIsRunning = false;
  var _gameHasStarted = false;
  int _index = 0;
  var startTime = 120.0;
  var increment = 5.0;

  CarouselController buttonCarouselController = CarouselController();
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _timeFieldController = TextEditingController();
  final TextEditingController _incrementFieldController = TextEditingController();

  refresh() {
    setState(() {});
  }

  late List<Player> players = [
    Player("Player 1", notifyParent: refresh),
    Player("Player 2", notifyParent: refresh)
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
        child: GestureDetector(
          onTap: tapCard,
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
          color: player.bgColor,
          border: Border.all(
            color: player.bgColor,
            width: 8,
          ),
          borderRadius: BorderRadius.circular(75),
        ),
        padding: EdgeInsets.all(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Container()),
                AutoSizeText(
                  player.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: player.textColor,
                    fontSize: 200
                  ),
                ),
                Expanded(child: Container()),
                Expanded(child: Container()),
                Expanded(child: Container()),
                Expanded(child: Container()),
                Expanded(child: Container()),
                Expanded(child: Container()),
              ],
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              child: Text(
                player.formattedTime(),
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: player.textColor
                ),
              ),
            ),
          ],
        ));
  }

  tapCard(){
    if(_gameIsRunning){
      buttonCarouselController.nextPage();
    } else{
      editPlayer();
    }
  }
  
  editPlayer() {
    if (!_gameIsRunning) {
      _displayTextInputDialog(context);
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    Player editingPlayer = players[_index];
    _textFieldController.text = editingPlayer.name;
    _timeFieldController.text = startTime.toString();
    _incrementFieldController.text = increment.toString();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Edit Player/Game'),
            actions: [
              TextButton(
                  child: Text('Delete'),
                  onPressed: players.length < 2 ? null : () {
                    deleteCurrentPlayer();
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    addPlayer();
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: Text('Reset'),
                  onPressed: () {
                    resetGame();
                    Navigator.of(context).pop();
                  }),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Player Name"),
                  TextField(
                    onChanged: (value) {
                      editingPlayer.name = value;
                      refresh();
                    },
                    controller: _textFieldController,
                  ),
                  const SizedBox(height: 20),
                  const Text("Time per player (seconds)"),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      startTime = double.parse(value);
                      resetGame();
                    },
                    controller: _timeFieldController,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Increment per player (seconds)"),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      increment = double.parse(value);
                      resetGame();
                    },
                    controller: _incrementFieldController,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                  const SizedBox(height: 20),
                  ColorPicker(
                    enableAlpha: false,
                    pickerColor: editingPlayer.bgColor,
                    onColorChanged: editingPlayer.setBgColor,
                  ),
                ],
            ),
          );

        });
  }

  startPauseGame() {
    _gameIsRunning = !_gameIsRunning;
    handleTimers(!_gameHasStarted);
    _gameHasStarted = true;

    if(_gameIsRunning){
      Wakelock.enable();
    } else{
      Wakelock.disable();
    }

    refresh();
  }

  onNextPlayer(int index, CarouselPageChangedReason reason) {
    _index = index;
    handleTimers(true);
  }

  deleteCurrentPlayer() {
    players.removeAt(_index);
    refresh();
  }

  addPlayer() {
    players.add(Player("Player " + (players.length + 1).toString(), notifyParent: refresh));
    setState(() {
      //buttonCarouselController.animateToPage(players.length-1);
    });
  }

  resetGame(){
    _gameIsRunning = false;
    players.forEach((element) {
      element.timer.pause();
      element.countDown = startTime;
      element.increment = increment;
    });

    refresh();
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
