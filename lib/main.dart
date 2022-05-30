import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

import 'package:exercise_3/ball.dart';
import 'package:exercise_3/paddle.dart';
import 'package:exercise_3/powerup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum Type {
  Health,
  Speed,
  Size,
}

class PowerUp {
  double x;
  double y;
  Color c;
  Type t;
  box? b;
  PowerUp(this.x, this.y, this.c, this.t) {
    b = box(x, y, c);
  }
  updateBox() => b = box(x, y, c);
  getX() => x;
  getY() => y;
  modX(val) => x += val;
  void modY(val) {
    y += val;
    updateBox();
  }
}

class BallHolder {
  double x;
  double y;
  Color color;
  ball? b;
  BallHolder(this.x, this.y, this.color) {
    b = ball(x, y, color);
  }
  updateBall() => b = ball(x, y, color);
  getX() => x;
  getY() => y;
  modX(val) => x += val;
  void modY(val) {
    y += val;
    updateBall();
  }
}

class Player {
  double x;
  double mov_spd;
  double size = 1;
  Color color;
  paddle? p;
  Player(this.x, this.color, this.mov_spd) {
    p = paddle(x, color, size);
  }
  updatePlayer() => p = paddle(x, color, size);
  getX() => x;
  modX(val, maxX) {
    var x_ = 2 * (val / maxX) - 1;
    if (x_ != x) {
      if (x_ > 0) {
        if (x < 1) {
          x += mov_spd;
        }
      }
      if (x_ <= 0) {
        if (x > -1) {
          x -= mov_spd;
        }
      }
      updatePlayer();
    }
  }

  getsize() => size;
  modSize(val) {
    if (size < 4) size += val;
    updatePlayer();
  }

  getMovSpd() => mov_spd;
  modMovSpd(val) {
    if (mov_spd < 10) mov_spd += val;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const move(),
    );
  }
}

class move extends StatefulWidget {
  const move({Key? key}) : super(key: key);

  @override
  State<move> createState() => _moveState();
}

class _moveState extends State<move> with TickerProviderStateMixin {
  List<Color> colors = [
    Colors.orange,
    Colors.cyan,
    Colors.yellow,
    Color.fromARGB(255, 93, 0, 255),
    Color.fromARGB(255, 0, 38, 255)
  ];

  bool started = false;
  bool lost = false;
  List<BallHolder> ListOfBalls = [];
  List<PowerUp> ListOfPowerUps = [];

  Player player = Player(0, Color.fromARGB(255, 0, 255, 8), 0.01);
  var tapLocation = 0.0;
  var lives = 10;
  var score = 0;
  var last_score = 0;

  var multipler = 1;
  var count = 0;
  var count_m = 0;

  var holding = false;
  late final Ticker _ticker;

  _onTapDown(TapDownDetails details) {
    tapLocation = details.globalPosition.dx;
    holding = true;
    print("Holding " + holding.toString());
  }

  _onTapUp(TapUpDetails details) {
    tapLocation = details.globalPosition.dx;
    holding = false;
    print("Holding " + holding.toString());
  }

  void spawnBalls() {
    if (count > (100 / multipler) && (ListOfBalls.length < 15)) {
      count = 0;
      count_m++;
      if (count_m % 10 == 0) {
        multipler++;
        print('raising multipler');
      }
      ListOfBalls.add(BallHolder(2 * math.Random().nextDouble() - 1, -1,
          colors[math.Random().nextInt(colors.length)]));
    }
    count++;
  }

  void moveBalls() {
    setState(() {
      for (var i in ListOfBalls) {
        if (multipler < 50 && multipler > 10) {
          i.modY(0.001 * multipler);
        } else if (multipler <= 10) {
          i.modY(0.01);
        } else {
          i.modY(0.05);
        }
      }
    });
  }

  void removeBalls() {
    for (int i = 0; i < ListOfBalls.length; i++) {
      if (ListOfBalls[i].getY() >= 0.9) {
        if (collisionBall(i)) continue;
      }
      if (ListOfBalls[i].getY() >= 1) {
        ListOfBalls.removeAt(i);
        lives--;
      }
    }
  }

  List<ball> listget() {
    List<ball> b = [];
    for (var i in ListOfBalls) {
      b.add(i.b!);
    }
    return b;
  }

  Container getLevel() {
    return Container(
      child: Text('Level: $multipler',
          style: GoogleFonts.pressStart2p(
              color: const Color.fromARGB(255, 0, 255, 8), fontSize: 10)),
    );
  }

  Container getLives() {
    return Container(
        child: Text('Lives: $lives',
            style: GoogleFonts.pressStart2p(
                color: const Color.fromARGB(255, 0, 255, 8), fontSize: 10)));
  }

  Container getScore() {
    return Container(
        child: Text('Score: $score',
            style: GoogleFonts.pressStart2p(
                color: const Color.fromARGB(255, 0, 255, 8), fontSize: 10)));
  }

  Container getPlayer() {
    movePlayer();
    return Container(child: player.p);
  }

  movePlayer() {
    if (holding == true) {
      player.modX(tapLocation, MediaQuery.of(context).size.width);
    }
  }

  bool collisionBall(int i) {
    var element = ListOfBalls.elementAt(i);
    if (element.x > (player.x - 0.1 * player.size) &&
        element.x < (player.x + 0.1 * player.size)) {
      ListOfBalls.removeAt(i);
      print("removed element: " + i.toString());
      score++;
      return true;
    }
    return false;
  }

  void SpawnPowerUps() {
    if (count_m % 2 == 0) {
      if (math.Random().nextDouble() < 0.01 && ListOfPowerUps.length < 4) {
        var i = math.Random().nextInt(3);
        if (lives < 4) {
          i = 0;
        }
        print("Spawning power up of type: " + i.toString());
        switch (i) {
          case 0:
            ListOfPowerUps.add(PowerUp(2 * math.Random().nextDouble() - 1, -1,
                Color.fromARGB(255, 255, 0, 0), Type.Health));
            break;
          case 1:
            ListOfPowerUps.add(PowerUp(2 * math.Random().nextDouble() - 1, -1,
                Color.fromARGB(255, 0, 255, 8), Type.Size));
            break;
          case 2:
            ListOfPowerUps.add(PowerUp(2 * math.Random().nextDouble() - 1, -1,
                Color.fromARGB(255, 0, 0, 255), Type.Speed));
            break;
          default:
        }
      }
    }
  }

  void movePowerUps() {
    setState(() {
      for (var i in ListOfPowerUps) {
        if (multipler < 50 && multipler > 10) {
          i.modY(0.001 * multipler);
        } else if (multipler <= 10) {
          i.modY(0.01);
        } else {
          i.modY(0.05);
        }
      }
    });
  }

  void removePowerUps() {
    for (int i = 0; i < ListOfPowerUps.length; i++) {
      if (ListOfPowerUps[i].getY() >= 0.9) {
        if (collisionPowerUps(i)) continue;
      }
      if (ListOfPowerUps[i].getY() >= 1) {
        ListOfPowerUps.removeAt(i);
      }
    }
  }

  bool collisionPowerUps(int i) {
    var element = ListOfPowerUps.elementAt(i);
    if (element.x > (player.x - 0.1 * player.size) &&
        element.x < (player.x + 0.1 * player.size)) {
      ListOfPowerUps.removeAt(i);
      print("removed element: " + i.toString());
      switch (element.t) {
        case Type.Health:
          lives += 10;
          break;
        case Type.Size:
          player.modSize(player.getsize() * 0.1);
          break;
        case Type.Speed:
          player.modMovSpd(player.getMovSpd() * 0.1);
          break;
      }
      return true;
    }
    return false;
  }

  List<box> getPowerUps() {
    List<box> b = [];
    for (var i in ListOfPowerUps) {
      b.add(i.b!);
    }
    return b;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (started) {
        spawnBalls();
        moveBalls();
        removeBalls();

        SpawnPowerUps();
        movePowerUps();
        removePowerUps();
        if (lives <= 0) {
          resetGame();
        }
      }
    });
    _ticker.start();
  }

  resetGame() {
    ListOfBalls.clear();
    ListOfPowerUps.clear();
    tapLocation = 0.0;
    lives = 10;
    last_score = score;
    score = 0;

    multipler = 1;
    count = 0;
    count_m = 0;

    holding = false;
    started = false;
    lost = true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> l = [];
    l.addAll(listget());
    l.add(getPlayer());
    l.addAll(getPowerUps());
    return GestureDetector(
        onTap: () {
          if (!started) {
            started = true;
            if (lost) {
              lost = false;
            }
          }
        },
        onTapDown: (TapDownDetails details) => _onTapDown(details),
        onTapUp: (TapUpDetails details) => _onTapUp(details),
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            actions: [
              Expanded(
                  flex: 3,
                  child: Center(
                    child: ((() {
                      if (!lost) {
                        return Row(
                          children: [
                            const SizedBox(width: 10),
                            getLevel(),
                            const SizedBox(
                              width: 10,
                            ),
                            getLives(),
                            const SizedBox(
                              width: 10,
                            ),
                            getScore(),
                          ],
                        );
                      }
                      if (!started && lost) {
                        return Text('SCORE: $last_score',
                            style: GoogleFonts.pressStart2p(
                                color: const Color.fromARGB(255, 0, 255, 8),
                                fontSize: 15));
                      }
                    }())),
                  )),
            ],
          ),
          body: (() {
            if (!started && lost) {
              return Text('YOU LOSE!',
                  style: GoogleFonts.pressStart2p(
                      color: const Color.fromARGB(255, 0, 255, 8),
                      fontSize: 25));
            }
            if (started) return Stack(children: l);
            if (!started) {
              return Center(
                child: Text(
                  'Tap To Play',
                  style: GoogleFonts.pressStart2p(
                      color: const Color.fromARGB(255, 0, 255, 8),
                      fontSize: 25),
                ),
              );
            }
          }()),
        ));
  }
}
