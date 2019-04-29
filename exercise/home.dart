import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {


  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        CustomCard(text: "Texxt1"),
        CustomCard(text: "Texxt2"),
        CustomCard(text: "Texxt3")
      ],),
    );
  }
}

class CustomCard extends StatelessWidget {

  CustomCard({@required String this.text});

  final String text;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => {
        },
        child: Card(
          child: Padding(padding: EdgeInsets.all(20), child: Text(this.text)),
          color: Colors.white,
          elevation: 5,
        ),
      ),
    );
  }
}
