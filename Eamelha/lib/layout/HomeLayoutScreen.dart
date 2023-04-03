import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';


import '../shared/components/components.dart';
import '../shared/cubit/todo_cubit.dart';
import '../shared/cubit/todo_states.dart';

class HomeLayout extends StatelessWidget {
  // keys
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  // controllers
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // context in create function is refers to BlocProvider
      // create used to create an object of Bloc to use it
      // the .. here to deal with TodoCubit() like an object
      // and be able to access its attributes and methods
      create: (context) => TodoCubit()..createDatabase(),

      // Bloc Consumer is used to update the UI in response to changes in the state of the Bloc.
      // it needs the cubit work on and the states that it will listen to
      // according to listening result it will rebuild specific place
      child: BlocConsumer<TodoCubit, TodoStates>(
        // context in listener and builder refers to the parent widget that use the Bloc consumer
        // which in our case is bloc provider so context in listener and builder refers to Bloc provider

        // When a state happened listener listen it
        // state is object of CounterStates
        listener: (BuildContext context, TodoStates state) {
          if (state is InsertIntoDatabaseState) {
            Navigator.pop(context);
          }
        },

        // In builder we return the design of the screen
        // according to listener, builder will rebuild
        builder: (context, state) {
          // context send to BlocProvider.of(context) ---by passing it to getTodoCubit function--- is the context that refers to parent of BlocConsumer
          // which in our case it is the BlocProvider which means
          // context sent to BlocProvider.of(context) ---by passing it to getTodoCubit function--- is the context of BlocProvider

          TodoCubit todoCubit = TodoCubit.getTodoCubit(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                todoCubit.appBarTitles[todoCubit.currentIndex],
              ),
              centerTitle: true,
            ),
            body: todoCubit.screens[todoCubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (todoCubit.showAddButton) {
                  // validate on inserted data
                  if (formKey.currentState!.validate()) {
                    // Insert values into database
                    todoCubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  }
                } else {
                  // open bottom sheet
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                          (context) => bottomSheetContent(context))
                      .closed
                      .then((value) {
                    todoCubit.changeBottomSheetState(
                      showAddButton2: false,
                      fabIcon2: const Icon(Icons.edit),
                    );
                  });
                  todoCubit.changeBottomSheetState(
                    showAddButton2: true,
                    fabIcon2: const Icon(Icons.add),
                  );
                }
              },
              child: todoCubit.fabIcon,
            ),
            bottomNavigationBar: BottomNavigationBar(
              // onTap is an anonymous function that gives me the index of pressed bottom navbar item
              onTap: (index) {
                todoCubit.changeScreenIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              currentIndex: todoCubit.currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.task_rounded,
                  ),
                  label: "New",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_rounded,
                  ),
                  label: "Done",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_rounded,
                  ),
                  label: "Archived",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Content of bottomSheet
  Widget bottomSheetContent(context) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task title
              myTextFormField(
                borderRadius: 0,
                textController: titleController,
                keyboardType: TextInputType.text,
                prefixIcon: const Icon(
                  Icons.title,
                ),
                label: "Title",
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Task title must not be empty";
                  } else {
                    return null;
                  }
                },
              ),

              verticalSeparator(value: 15),

              // Task time
              myTextFormField(
                borderRadius: 0,
                textController: timeController,
                keyboardType: TextInputType.datetime,
                prefixIcon: const Icon(Icons.watch_later_outlined),
                label: "Time",
                myOnTap: () {
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ).then((dynamic value) {
                    timeController.text = value.format(context);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Task time must not be empty";
                  } else {
                    return null;
                  }
                },
              ),

              verticalSeparator(value: 15),

              // Task date
              myTextFormField(
                borderRadius: 0,
                textController: dateController,
                keyboardType: TextInputType.datetime,
                prefixIcon: const Icon(Icons.calendar_today),
                label: "Date",
                myOnTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.parse('2030-12-30'),
                  ).then((value) {
                    dateController.text =
                        DateFormat.yMMMd().format(value!);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Task date must not be empty";
                  } else {
                    return null;
                  }
                },
              ),
            ],
          ),
        ),
      );
}


/*ConditionalBuilder(
              // context builder and fallback is the context of Conditional builder
              condition: true,

              // when condition is true
              builder: (context) => todoCubit.screens[todoCubit.currentIndex],

              // when condition is false
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            )*/