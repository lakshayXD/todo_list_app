import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_app/utils/constants.dart';

class TodoListScreen extends ConsumerWidget {
  TodoListScreen({super.key});

  final FocusNode _addTaskTextField = FocusNode();
  final TextEditingController _addTaskFieldController = TextEditingController();
  Size? _screenSize;

  ///maintains the tasks list
  final taskListStateProvider = StateProvider<List<Task>>(
    (context) => <Task>[],
  );

  ///method for adding task to the todolist
  Future<void> _addNewTask(WidgetRef ref, Task newTask) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ref.read(taskListStateProvider.notifier).state.add(newTask);

    List<String>? taskTitlesList =
        sharedPreferences.getStringList(taskTitlesListKey);
    List<String>? taskIsCompletedList =
        sharedPreferences.getStringList(taskIsCompletedListKey);
    if (taskTitlesList != null) {
      taskTitlesList.add(newTask.title);
    } else {
      taskTitlesList = [];
    }
    if (taskIsCompletedList != null) {
      taskIsCompletedList.add(newTask.isCompleted.toString());
    } else {
      taskIsCompletedList = [];
    }
    await sharedPreferences.setStringList(taskTitlesListKey, taskTitlesList);
    await sharedPreferences.setStringList(
        taskIsCompletedListKey, taskIsCompletedList);
  }

  ///method to open addTaskTextField ModalSheet
  Widget _addTaskModalSheet(
      Size screenSize, BuildContext context, WidgetRef ref) {
    return Container(
      height: screenSize.height / 3,
      padding: const EdgeInsets.all(30),
      color: Colors.blue,
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: TextFormField(
            controller: _addTaskFieldController,
            onFieldSubmitted: (val) async {
              await _addNewTask(
                  ref,
                  Task(
                      title: _addTaskFieldController.text.trim(),
                      isCompleted: false));
              if (context.mounted) Navigator.pop(context);
              //TODO: add func. to add the task in list with animation
            },
            decoration: InputDecoration(
              suffixIcon: InkWell(
                child: IconButton(
                  icon: const Icon(
                    Icons.done,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await _addNewTask(
                        ref,
                        Task(
                            title: _addTaskFieldController.text.trim(),
                            isCompleted: false));
                    if (context.mounted) Navigator.pop(context);
                    //TODO: add func. to add the task in list with animation
                  },
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.blue)),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Input new task here',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _screenSize = MediaQuery.of(context).size;
    List<Task> taskListState = ref.watch(taskListStateProvider);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) {
                return _addTaskModalSheet(_screenSize!, context, ref);
              }),
        ),
        appBar: AppBar(
          title: Text(
            'Todo List',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: AnimationLimiter(
            child: ListView.builder(
              itemCount: taskListState.length,
              itemBuilder: (BuildContext context, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        child: Text(
                          taskListState[index].title,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, required this.isCompleted});
}
