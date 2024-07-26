import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_app/features/todo_list/task_model.dart';
import 'package:todo_list_app/utils/constants.dart';
import 'package:todo_list_app/widgets/custom_snack_bar.dart';

import 'fetch_tasks_provider.dart';

class TodoListScreen extends ConsumerWidget {
  TodoListScreen({super.key});

  final FocusNode _addTaskTextFieldFocusNode = FocusNode();
  final TextEditingController _addTaskFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Size? _screenSize;

  ///maintains the tasks list
  final _taskListStateProvider = StateProvider<List<Task>>(
    (context) => <Task>[],
  );

  ///method for scrolling the ListView to the bottom
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  ///method for adding task to the todolist
  Future<void> _addNewTask(WidgetRef ref, Task newTask) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    ref.read(_taskListStateProvider.notifier).state.add(newTask);

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
  Widget _openAddTaskDialog(
      Size screenSize, BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TextFormField(
          controller: _addTaskFieldController,
          focusNode: _addTaskTextFieldFocusNode,
          onFieldSubmitted: (val) async {
            if (_addTaskFieldController.text.isNotEmpty) {
              await _addNewTask(
                  ref,
                  Task(
                      title: _addTaskFieldController.text.trim(),
                      isCompleted: false));
              if (context.mounted) Navigator.pop(context);
              showSuccessSnackBar('New task has been added!');
              _scrollToBottom();
              _addTaskFieldController.text = '';
            } else {
              showErrorSnackBar('Please input a valid task name');
            }
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.done,
                color: Color(0xFF3A96FF),
              ),
              onPressed: () async {
                if (_addTaskFieldController.text.isNotEmpty) {
                  await _addNewTask(
                      ref,
                      Task(
                          title: _addTaskFieldController.text.trim(),
                          isCompleted: false));
                  if (context.mounted) Navigator.pop(context);
                  showSuccessSnackBar('New task has been added!');
                  _scrollToBottom();
                  _addTaskFieldController.text = '';
                } else {
                  showErrorSnackBar('Please input a valid task name');
                }
              },
            ),
            focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(color: Colors.blue)),
            filled: true,
            hintText: 'Input new task here',
          ),
        ),
      ),
    );
  }

  ///method for handling the checkbox states of tasks
  Future<void> _checkboxStateHandler(
      WidgetRef ref, int index, bool? value) async {
    List<Task> updatedTaskList =
        List.from(ref.read(_taskListStateProvider.notifier).state);
    updatedTaskList[index].isCompleted = value!;

    ref.read(_taskListStateProvider.notifier).state = updatedTaskList;
    showSuccessSnackBar(value
        ? 'Task successfully marked as complete!'
        : 'Task successfully marked as incomplete!');

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? taskIsCompletedList =
        sharedPreferences.getStringList(taskIsCompletedListKey);

    if (taskIsCompletedList != null) {
      taskIsCompletedList[index] = value.toString();
    } else {
      taskIsCompletedList = [];
    }

    await sharedPreferences.setStringList(
        taskIsCompletedListKey, taskIsCompletedList);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _screenSize = MediaQuery.of(context).size;
    List<Task> taskListState = ref.watch(_taskListStateProvider);
    AsyncValue<List<Task>> allTasksListState = ref.watch(allTasksListProvider);

    return allTasksListState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('Error: $err'),
        data: (tasks) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            ref.read(_taskListStateProvider.notifier).state = tasks;
          });
          return PopScope(
            canPop: false,
            child: SafeArea(
              child: Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return _openAddTaskDialog(_screenSize!, context, ref);
                      }),
                ),
                appBar: AppBar(
                  title: Text(
                    'Todo List',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  automaticallyImplyLeading: false,
                ),
                body: (tasks.isNotEmpty)
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        child: AnimationLimiter(
                          child: Scrollbar(
                            thickness: 0.7,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: taskListState.length,
                              itemBuilder: (BuildContext context, int index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: const Color(0xFFFFFFFF)
                                                  .withOpacity(0.3),
                                            ),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: taskListState[index]
                                                      .isCompleted,
                                                  onChanged:
                                                      (bool? value) async {
                                                    _checkboxStateHandler(
                                                        ref, index, value);
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: 30,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    taskListState[index].title,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : const Opacity(
                        opacity: 0.5,
                        child: Center(
                          child: Text("Press '+' to add new task"),
                        ),
                      ),
              ),
            ),
          );
        });
  }
}
