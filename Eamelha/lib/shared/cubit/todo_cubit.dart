import 'package:bloc/bloc.dart';
import 'package:eamelha/shared/cubit/todo_states.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';

import '../../modules/archived_tasks/ArchivedTasksScreen.dart';
import '../../modules/done_tasks/DoneTasksScreen.dart';
import '../../modules/new_tasks/NewTasksScreen.dart';
import '../components/components.dart';

class TodoCubit extends Cubit<TodoStates> {
  // send to Cubit the states that you will move between them
  TodoCubit() : super(InitialState());

  // function that returns an object from me
  // context passed to BlocProvider.of(context) is the context that refers to parent of BlocConsumer
  // which in our case it is the BlocProvider which means:
  // context sent to BlocProvider.of(context) is the context of BlocProvider
  static TodoCubit getTodoCubit(context) => BlocProvider.of(context);

  // variables
  int currentIndex = 0;
  bool showAddButton = false;
  Icon fabIcon = const Icon(Icons.edit);
  late Database databaseObj; // create an instance of Database

  // list of screens
  List<Widget> screens = const [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  // list of appBar titles
  List<String> appBarTitles = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];

  // list of new tasks
  List<Map> newTasks = [];

  // list of done tasks
  List<Map> doneTasks = [];

  // list of archived tasks
  List<Map> archivedTasks = [];

  // change screen index in navbar
  void changeScreenIndex(index) {
    currentIndex = index;
    emit(ChangeBottomNavBarState());
  }

  // Deal with database part

  // path is the db name
  final String path = "Todo.db";

  // create and open the database
  createDatabase() async {
    // this variable filled when openDatabase function finished its work
    openDatabase(
      path,
      // the version of the db
      // when you change the db structure the version changed

      version: 1,
      // onCreate is an anonymous function that gives me an object from db and its version
      // the _database instance that onCreate gives it me filled when onCreate finishes its work
      // database0 is the same of the _database at the above but it differs when each of them will be filled with data
      // onCreate called only once

      onCreate: (database, version) {
        print("\ndatabase created!\n");

        // When creating the db, create the table
        String sql = 'CREATE TABLE Tasks ('
            'ID INTEGER PRIMARY KEY,'
            'title TEXT,'
            'date TEXT,'
            'time TEXT,'
            'status TEXT'
            ')';
        database
            .execute(
          sql,
        )
            .then((value) {
          print("\ntable created successfully\n");
        }).catchError((error) {
          print("\nerror when creating table is: ${error.toString()}\n");
        });
      },

      // onOpen is an anonymous function that gives me an object from db
      onOpen: (database) {
        // get data from database
        getFromDatabase(database);
        print("\ndatabase opened!\n");
      },
    ).then((value) {
      databaseObj = value;
      emit(CreateDatabaseState());
    });
  }

  // insert into database
  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await databaseObj.transaction((txn) async {
      String sql =
          'INSERT INTO Tasks(title, time, date, status) VALUES("$title", "$time", "$date", "new")';
      txn.rawInsert(sql).then((value) {
        print("\n\n${value}: inserted successfully\n\n");
        emit(InsertIntoDatabaseState());

        // get data after inserting again
        getFromDatabase(databaseObj);
      }).catchError((error) {
        separator();
        print("\n\nerror when inserting new record:  ${error.toString()}\n\n");
        separator();
      });
    });
  }

  // get data from database
  getFromDatabase(Database database) {
    emit(GetFromDatabaseLoadingState());

    // clear lists before adding the new values in them
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    String sql = 'SELECT * FROM Tasks';
    database.rawQuery(sql).then((tasks) {
      // value here is the list of map and each map is record in database
      for (var element in tasks) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      }
      print("\n\n$tasks\n\n");

      emit(GetFromDatabaseState());
    }).catchError((error) {
      print("\n\nerror when getting records : ${error.toString()}\n\n");
    });
  }

  // update record
  void updateRecord({
    required String status,
    required int id,
  }) async {
    databaseObj.rawUpdate(
      // replace all ? with value from the list
      'UPDATE Tasks SET status = ? WHERE ID = ?',
      [status, id],
    ).then((value) {
      emit(UpdateRecordState());
      getFromDatabase(databaseObj);
    });
  }

  // delete record
  void deleteRecord(int id) async {
    databaseObj.rawDelete('DELETE FROM Tasks WHERE ID = ?', [id]).then((value) {
      emit(DeleteRecordState());
      getFromDatabase(databaseObj);
    });
  }

  // drop the database
  Future<void> deleteDatabase() async {
    databaseFactory.deleteDatabase('Todo.db');
  }

  void changeBottomSheetState({
    required bool showAddButton2,
    required Icon fabIcon2,
  }) {
    showAddButton = showAddButton2;
    fabIcon = fabIcon2;
    emit(ChangeBottomSheetState());
  }
}
