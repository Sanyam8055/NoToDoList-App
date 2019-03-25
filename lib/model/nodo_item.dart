import 'package:flutter/material.dart';

class NoDoItem extends StatelessWidget {
  String _itemName;
  String _dateCreated;
  int _id;

  NoDoItem(this._itemName, this._dateCreated);

  String get itemName => _itemName;

  String get dateCreated => _dateCreated;

  int get id => _id;

  NoDoItem.map(dynamic obj) {
    this._itemName = obj['itemName'];
    this._dateCreated = obj['dateCreated'];
    this._id = obj['id'];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['itemName'] = this._itemName;
    map['dateCreated'] = this._dateCreated;
    if (id != null) map['id'] = this._id;
    return map;
  }

  NoDoItem.fromMap(Map<String, dynamic> map) {
    this._itemName = map['itemName'];
    this._dateCreated = map['dateCreated'];
    this._id = map['id'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _itemName,
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          new Container(
            margin: EdgeInsets.only(top: 5.0),
            child: Text(
              'Date Created: $_dateCreated',
              style: new TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
