import 'package:flutter/material.dart';
import 'package:no_todo_app/model/nodo_item.dart';
import 'package:no_todo_app/util/database_client.dart';
import 'package:no_todo_app/util/date_formatter.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();

  //database helper object
  var db = new DatabaseHelper();

  //List of notes
  final List<NoDoItem> _itemlist = <NoDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmit(String text) async {
    _textEditingController.clear();
    NoDoItem noDoItem = new NoDoItem(text, dateFormatted());
    int savedItemId = await db.saveNoDoItem(noDoItem);
    NoDoItem addedItem = await db.getNoDoItem(savedItemId);
    setState(() {
      _itemlist.insert(0, addedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: _itemlist.length,
                reverse: false,
                itemBuilder: (_, int index) {
                  return new Card(
                    color: Colors.white10,
                    child: ListTile(
                      title: _itemlist[index],
                      onLongPress: () => _updateItem(_itemlist[index], index),
                      trailing: new Listener(
                        key: new Key(_itemlist[index].itemName),
                        child: new Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                        ),
                        onPointerDown: (pointerEvent) =>
                            _deleteNoDo(_itemlist[index].id, index),
                      ),
                    ),
                  );
                }),
          ),
          new Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip: 'Add Item',
          child: new Icon(Icons.add),
          backgroundColor: Colors.redAccent,
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Item',
              hintText: "eg. Don't buy stuff",
              icon: Icon(Icons.event_note),
            ),
          ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text('Save')),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: Text('Cancel'))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getAllNoDoItems();
    items.forEach((item) {
      setState(() {
        _itemlist.add(NoDoItem.map(item));
      });
    });
  }

  _deleteNoDo(int id, int index) async {
    debugPrint('Item Deleted');
    await db.deleteNoDoItem(id);
    setState(() {
      _itemlist.removeAt(index);
    });
  }

  _updateItem(NoDoItem item, int index) {
    var alert = new AlertDialog(
      title: new Text('Update Item'),
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Item',
              hintText: "Don't buy stuff",
              icon: new Icon(Icons.system_update_alt),
            ),
          )),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () async {
              NoDoItem newUpdatedItem = NoDoItem.fromMap({
                'itemName': _textEditingController.text,
                'dateCreated': dateFormatted(),
                'id': item.id
              });

              _handleSubmitUpdate(item, index); //redrawing the screen
              await db.updateNoDoItem(newUpdatedItem); // updating the item
              setState(() {
                _readNoDoList(); //redrawing with all items of db
              });
              Navigator.pop(context);
            },
            child: new Text('Update')),
        new FlatButton(
            onPressed: () => Navigator.pop(context), child: new Text('Cancel')),
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _handleSubmitUpdate(NoDoItem item, int index) {
    setState(() {
      _itemlist.removeWhere((element) {
        // ignore: unnecessary_statements
        _itemlist[index].itemName == item.itemName;
      });
    });
  }
}
