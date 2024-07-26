import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_app/features/todo_list/task_model.dart';
import 'package:todo_list_app/utils/constants.dart';

///future provider for loading task list from cache
final allTasksListProvider = FutureProvider<List<Task>>((ref) async {
  return await _loadTaskList();
});

///method for loading all the tasks from cache
Future<List<Task>> _loadTaskList() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  List<String>? taskTitlesList =
      sharedPreferences.getStringList(taskTitlesListKey);
  List<String>? taskIsCompletedList =
      sharedPreferences.getStringList(taskIsCompletedListKey);
  if (taskTitlesList == null ||
      taskIsCompletedList == null ||
      taskTitlesList.isEmpty ||
      taskIsCompletedList.isEmpty) {
    return [];
  }
  return List.generate(
      taskTitlesList.length,
      (index) => Task(
          title: taskTitlesList[index],
          isCompleted: bool.parse(taskIsCompletedList[index].toLowerCase())));
}
