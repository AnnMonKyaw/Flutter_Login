import 'dart:async';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:firebase_todo/model/todo.dart';
import 'package:firebase_todo/services/authentication.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback signOutCallback;
  final String userId;

  const HomePage({Key key, this.auth, this.signOutCallback, this.userId})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;
  Query _todoQuery;

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(onEntryAdded);
    _onTodoChangedSubscription =
        _todoQuery.onChildChanged.listen(onEntryChange);
  }

  onEntryChange(Event event) {
    var oldEntry = _todoList.singleWhere((element) {
      return element.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnaoshot(event.snapshot);
    });
  }

  onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnaoshot(event.snapshot));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onTodoChangedSubscription.cancel();
    _onTodoAddedSubscription.cancel();
  }

  addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = Todo(todoItem.toString(), false, widget.userId);
      print(todo);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  updateTodo(Todo todo) {
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child(todoId).remove().then((_) {
      //database remove
      setState(() {
        _todoList.removeAt(index); // UI index Remove from List
      });
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.signOutCallback();
    } catch (e) {
      print(e);
    }
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          String todoId = _todoList[index].key;
          String subject = _todoList[index].subject;
          bool completed = _todoList[index].completed;
          String userId = _todoList[index].userId;
          return Dismissible(
            // delete
            key: Key(todoId),
            background: Container(
              color: Colors.red,
            ),
            onDismissed: (direction) async {
              deleteTodo(todoId, index);
            },
            child: ListTile(
              title: Text(
                subject,
                style: TextStyle(fontSize: 20),
              ),
              trailing: IconButton(
                  onPressed: () {
                    updateTodo(_todoList[index]);
                  },
                  icon: (completed)
                      ? Icon(
                          Icons.done_outline,
                          color: Colors.green,
                          size: 20,
                        )
                      : Icon(
                          Icons.done_outline,
                          color: Colors.grey,
                          size: 20,
                        )),
            ),
          );
        },
        itemCount: _todoList.length,
      );
    } else {
      return Center(
        child: Text(
          "Your list is empty.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
        ),
      );
    }
  }

  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    autofocus: true,
                    decoration: InputDecoration(hintText: "Add New Todo"),
                  ),
                )
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  addNewTodo(_textEditingController.text.toString());
                  Navigator.pop(context);
                },
                child: Text('Save'),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo"),
        actions: [
          FlatButton(
            onPressed: signOut,
            child: Text(
              'Sign Out',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
      ),
      body: showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTodoDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
