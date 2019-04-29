import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int highScore = 0;

  /**
   * Get high score from local Storage
   */
  _getHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      highScore =
          prefs.getInt('highScore') == null ? 0 : prefs.getInt('highScore');
    });
  }

  /**
   * Returns the Game page when clicking on the "Start new game" button
   */
  _getNewPageRoute(rows, cols, numberOfBombs) {
    final pageRoute = MaterialPageRoute<dynamic>(builder: (context) {
      return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: new Scaffold(
            appBar: AppBar(
              title: Text("Minesweeper"),
              backgroundColor: Colors.green,
              leading: Container(),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () => {
                        showDialog<String>(
                          context: context,
                          barrierDismissible:
                              false, // dialog is dismissible with a tap on the barrier
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  'Wollen Sie das Spiel wirklich beenden?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Abbruch'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text('Jetzt beenden'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    _getHighScore();
                                  },
                                )
                              ],
                            );
                          },
                        )
                      },
                )
              ],
            ),
            body: GameScreen(rows, cols, numberOfBombs),
          ));
    });

    return pageRoute;
  }

  @override
  void initState() {
    super.initState();
    _getHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        // alles
        child: Column(
          children: <Widget>[
            // welcome section
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: <Widget>[
                  Icon(MdiIcons.bomb, size: 150),
                  Text(
                    "Wilkommen zu Minesweeper!",
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            ),

            // highscore section
            Container(
              margin: EdgeInsets.only(top: 100),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Highscore",
                          style: TextStyle(fontSize: 20, color: Colors.black))),
                  Card(
                    elevation: 8,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            left: 80, bottom: 10, top: 10, right: 80),
                        child: Text("$highScore Punkte",
                            style: TextStyle(fontSize: 25))),
                  )
                ],
              ),
            ),

            // new game section
            Container(
              margin: EdgeInsets.only(top: 25),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    child: Text("Start new Game",
                        style: TextStyle(color: Colors.white)),
                    elevation: 8,
                    color: Colors.green,
                    onPressed: () =>
                        {Navigator.of(context).push(_getNewPageRoute(9, 9, 9))},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
