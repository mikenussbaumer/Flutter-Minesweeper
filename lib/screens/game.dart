import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum TileState { covered, blown, open, flagged, revealed }

class GameScreen extends StatefulWidget {
  GameScreen(this.rows, this.cols, this.numberOfBombs);

  final int rows;
  final int cols;
  final int numberOfBombs;

  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<TileState>> uiState;
  List<List<bool>> tiles;

  bool alive;
  bool wonGame;
  int minesFound;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    resetBoard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int timeElapsed = stopwatch.elapsedMilliseconds ~/ 1000;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildBoard(),
          Container(
              margin: EdgeInsets.only(left: 36, top: 30),
              child: Text("Statistiken",
                  style: TextStyle(fontSize: 24, color: Colors.black))),
          Container(
            margin: EdgeInsets.only(left: 36, top: 30),
            child: Column(
              children: <Widget>[
                Text("Spielzeit: $timeElapsed Sekunden",
                    style: TextStyle(fontSize: 18, color: Colors.black)),
                Text("Gefundene Mines: $minesFound",
                    style: TextStyle(fontSize: 18, color: Colors.black))
              ],
            ),
          )
        ],
      ),
    );
  }

  /**
   * Build game board
   */
  Widget buildBoard() {
    bool hasCoveredCell = false;
    List<Row> boardRow = <Row>[];
    for (int y = 0; y < widget.rows; y++) {
      List<Widget> rowChildren = <Widget>[];
      for (int x = 0; x < widget.cols; x++) {
        TileState state = uiState[y][x];
        int count = mineCount(x, y);

        if (!alive) {
          if (state != TileState.blown)
            state = tiles[y][x] ? TileState.revealed : state;
        }

        if (state == TileState.covered || state == TileState.flagged) {
          rowChildren.add(GestureDetector(
            onLongPress: () {
              flag(x, y);
            },
            onTap: () {
              if (state == TileState.covered) probe(x, y);
            },
            child: Listener(
                child: CoveredMineTile(
              flagged: state == TileState.flagged,
              posX: x,
              posY: y,
            )),
          ));
          if (state == TileState.covered) {
            hasCoveredCell = true;
          }
        } else {
          rowChildren.add(OpenMineTile(
            state: state,
            count: count,
          ));
        }
      }
      boardRow.add(Row(
        children: rowChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }
    if (!hasCoveredCell) {
      if ((minesFound == widget.numberOfBombs) && alive) {
        wonGame = true;
        stopwatch.stop();
        _setHighScore(minesFound);
      }
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 10, left: 1, right: 1),
      child: Column(
        children: boardRow,
      ),
    );
  }

  /**
   * Save highscore to local storage
   */
  void _setHighScore(foundBombs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int currentHighScore =
        prefs.getInt("highScore") == null ? 0 : prefs.getInt("highScore");

    if (currentHighScore < foundBombs) {
      prefs.setInt("highScore", (currentHighScore + foundBombs));
    }
  }

  /**
   * 
   */
  void probe(int x, int y) {
    if (!alive) return;
    if (uiState[y][x] == TileState.flagged) return;
    setState(() {
      if (tiles[y][x]) {
        uiState[y][x] = TileState.blown;
        alive = false;
        timer.cancel();
        stopwatch.stop();

        _setHighScore(minesFound);
      } else {
        open(x, y);
        if (!stopwatch.isRunning) stopwatch.start();
      }
    });
  }

  /**
   * Function called when field is clicked
   */
  void open(int x, int y) {
    if (!inBoard(x, y)) return;
    if (uiState[y][x] == TileState.open) return;
    uiState[y][x] = TileState.open;

    if (mineCount(x, y) > 0) return;

    open(x - 1, y);
    open(x + 1, y);
    open(x, y - 1);
    open(x, y + 1);
    open(x - 1, y - 1);
    open(x + 1, y + 1);
    open(x + 1, y - 1);
    open(x - 1, y + 1);
  }

  /**
   * Flag a tile on the board
   */
  void flag(int x, int y) {
    if (!alive) return;
    setState(() {
      if (uiState[y][x] == TileState.flagged) {
        uiState[y][x] = TileState.covered;
        --minesFound;
      } else {
        uiState[y][x] = TileState.flagged;
        ++minesFound;
      }
    });
  }

  /**
   * Reset board to default state
   */
  void resetBoard() {
    alive = true;
    wonGame = false;
    minesFound = 0;
    stopwatch.reset();

    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {});
    });

    uiState = new List<List<TileState>>.generate(widget.rows, (row) {
      return new List<TileState>.filled(widget.cols, TileState.covered);
    });

    tiles = new List<List<bool>>.generate(widget.rows, (row) {
      return new List<bool>.filled(widget.cols, false);
    });

    Random random = Random();
    int remainingMines = widget.numberOfBombs;
    while (remainingMines > 0) {
      int pos = random.nextInt(widget.rows * widget.cols);
      int row = pos ~/ widget.rows;
      int col = pos % widget.cols;
      if (!tiles[row][col]) {
        tiles[row][col] = true;
        remainingMines--;
      }
    }
  }

  int mineCount(int x, int y) {
    int count = 0;
    count += bombs(x - 1, y);
    count += bombs(x + 1, y);
    count += bombs(x, y - 1);
    count += bombs(x, y + 1);
    count += bombs(x - 1, y - 1);
    count += bombs(x + 1, y + 1);
    count += bombs(x + 1, y - 1);
    count += bombs(x - 1, y + 1);
    return count;
  }

  int bombs(int x, int y) => inBoard(x, y) && tiles[y][x] ? 1 : 0;
  bool inBoard(int x, int y) =>
      x >= 0 && x < widget.cols && y >= 0 && y < widget.rows;
}

/**
 * Build outer tile
 */
Widget buildTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1),
    height: 40.0,
    width: 40.0,
    color: Colors.green[400],
    margin: EdgeInsets.all(0.5),
    child: child,
  );
}

/**
 * Build inner tile
 */
Widget buildInnerTile(Widget child) {
  return Container(
    padding: EdgeInsets.all(1.0),
    margin: EdgeInsets.all(2.0),
    height: 20.0,
    width: 20.0,
    child: child,
  );
}

class CoveredMineTile extends StatelessWidget {
  final bool flagged;
  final int posX;
  final int posY;

  CoveredMineTile({this.flagged, this.posX, this.posY});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if (flagged) {
      text = buildInnerTile(Icon(MdiIcons.flag));
    }
    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(0.5),
      height: 20.0,
      width: 20.0,
      color: Colors.green[200],
      child: text,
    );

    return buildTile(innerTile);
  }
}

class OpenMineTile extends StatelessWidget {
  final TileState state;
  final int count;
  OpenMineTile({this.state, this.count});

  @override
  Widget build(BuildContext context) {
    Widget text;

    if (state == TileState.open) {
      if (count != 0) {
        text = Center(
            child: RichText(
          text: TextSpan(
            text: '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          textAlign: TextAlign.center,
        ));
      }
    } else {
      text = Icon(
        MdiIcons.bomb,
        color: Colors.red[800],
      );
    }
    return buildTile(buildInnerTile(text));
  }
}
