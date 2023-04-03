import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

import '../cubit/todo_cubit.dart';

// custom TextFormField
Widget myTextFormField({
  required TextEditingController textController,
  required TextInputType keyboardType,
  bool isPassword = false,
  required Icon prefixIcon,
  IconButton? suffixIcon,
  required String label,
  required Function(String?) validator,
  Function(String value)? myOnFieldSubmitted,
  Function(String value)? myOnChanged,
  VoidCallback? myOnTap,
  double borderRadius = 25.0,
  bool myEnabled = true,
}) {
  return TextFormField(
    controller: textController,
    keyboardType: keyboardType,
    obscureText: isPassword,
    validator: (String? value) => validator(value),
    decoration: InputDecoration(
      prefixIcon: prefixIcon,
      labelText: label,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    onFieldSubmitted: myOnFieldSubmitted,
    onChanged: myOnChanged,
    onTap: myOnTap,
    enabled: myEnabled,
  );
}

// custom button
Widget myButton({
  double width = double.infinity,
  Color textColor = Colors.black,
  Color backgroundColor = Colors.grey,
  bool isUpperCase = false,
  double radius = 25.0,
  double textSize = 20.0,
  required Function() onPressed,
  required String text,
}) =>
    Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
          ),
        ),
      ),
    );

// search bar
Widget searchBar() => Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: TextFormField(
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            filled: true,
            focusColor: Colors.blue,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(
                width: 3.0,
                color: Colors.blue,
              ),
            ),
            prefixIcon: IconButton(
              icon: Icon(
                Icons.search,
                size: 20,
                color: Colors.grey[600],
              ),
              onPressed: () {},
            ),
            hintText: "Search",
          ),
          onFieldSubmitted: (value) {},
        ),
      ),
    );

Widget verticalSeparator({double value = 10}) => SizedBox(height: value);

Widget horizontalSeparator({double value = 10}) => SizedBox(width: value);

// custom icon
Widget myIcon(
        {Color iconColor = Colors.white,
        Color? backgroundColor,
        required Icon icon,
        Function()? onPressed}) =>
    CircleAvatar(
      backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.6),
      child: IconButton(
        disabledColor: iconColor,
        icon: icon,
        onPressed: onPressed,
      ),
    );

// navigation button
Widget navButton({
  required context,
  required Widget destination,
  required String name,
}) =>
    TextButton(
        child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => destination,
            ),
          );
        });

BoxDecoration decorateContainer() => BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(25),
    );

// print statements divisor
void separator() => print(
    '____________________________________________________________________________________________');

// build task component
Widget buildTask(Map task, context) => Dismissible(
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          TodoCubit.getTodoCubit(context).deleteRecord(task['ID']);
        } else {
          TodoCubit.getTodoCubit(context)
              .updateRecord(status: 'archived', id: task['ID']);
        }
      },
      background: slideToLeftContainer(),
      secondaryBackground: slideToRightContainer(),
      key: Key(task['ID'].toString()),
      child: Row(
        children: [
          // time
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.purple,
            child: Text(
              "${task['time']}",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          horizontalSeparator(value: 20),

          Expanded(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,

              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [
                // title

                Text(
                  "${task['title']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                // date

                Text(
                  "${task['date']}",
                  style: const TextStyle(color: Colors.purple, fontSize: 12),
                ),
              ],
            ),
          ),

          horizontalSeparator(),

          IconButton(
            onPressed: () {
              TodoCubit.getTodoCubit(context)
                  .updateRecord(status: 'done', id: task['ID']);
            },
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
          ),

          horizontalSeparator(),

          IconButton(
            onPressed: () {
              TodoCubit.getTodoCubit(context)
                  .updateRecord(status: 'archived', id: task['ID']);
            },
            icon: const Icon(
              Icons.archive,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );

// build container when slide from right to left
Widget slideToLeftContainer() => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        color: Colors.grey,
      ),
      // text is here
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          "archive",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

// build container when slide from left to right
Widget slideToRightContainer() => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          20,
        ),
        color: Colors.red,
      ),
      // text is here
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          "delete",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

// build task screen component
Widget buildTaskScreen(List<Map> tasks) => ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => buildTask(tasks[index], context),
        separatorBuilder: (context, index) => verticalSeparator(value: 15),
        itemCount: tasks.length,
      ),
      fallback: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.edit_note_sharp,
            size: 100,
            color: Colors.grey,
          ),
          Text(
            "Oops, it seems there is no tasks yey, let's add one now!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
