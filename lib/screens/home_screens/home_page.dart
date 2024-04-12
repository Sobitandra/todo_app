import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import 'widgets/tasks_details_dailog.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final TextEditingController taskController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool? ascendingFilter;

  showDetailsDialog(TaskData taskData) {
    showDialog(
        context: context,
        builder: (c) {
          return TasksDetailsDialog(
            taskData: taskData,
            onUpdate: (TasksUpdate tasksUpdate) async {
              if (tasksUpdate == TasksUpdate.complete) {
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                taskData.status = true;
                taskData.timeOfDone = DateTime.now();
                sharedPreferences.setString(taskData.taskId.toString(), jsonEncode(taskData.toJson()));
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    "Task Updated",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ));
                setState(() {});
              } else {
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.remove(taskData.taskId.toString());
                if (!mounted) return;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "Task Deleted",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: Colors.red,
                ));
                setState(() {});
              }
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tasks"),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: taskController,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Please enter some tasks";
                        }
                        return null;
                      },
                      onFieldSubmitted: (v) async {
                        if (!formKey.currentState!.validate()) return;
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        final item = TaskData.addTask(taskController.text.trim());
                        sharedPreferences.setString(item.taskId!, jsonEncode(item.toJson()));
                        taskController.clear();
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          hintText: "Enter Task Name",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          enabled: true),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                        final item = TaskData.addTask(taskController.text.trim());
                        sharedPreferences.setString(item.taskId!, jsonEncode(item.toJson()));
                        taskController.clear();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                      ),
                      child: const Text(
                        "Add New",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
                      )),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                      child: Text(
                    "Tasks List",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: ascendingFilter == true ? math.pi : 0),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.bounceOut,
                    builder: (BuildContext context, double value, Widget? child) {
                      return Transform.rotate(
                        angle: value,
                        child: IconButton(onPressed: () {
                          if(ascendingFilter == null){
                            ascendingFilter = true;
                          } else {
                            ascendingFilter = !ascendingFilter!;
                          }
                          setState(() {});
                        }, icon: const Icon(Icons.filter_list)),
                      );
                    },
                  )
                ],
              ),
              Expanded(
                  child: FutureBuilder(
                future: SharedPreferences.getInstance(),
                builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    List<TaskData> tasksList = snapshot.data!
                        .getKeys()
                        .map((e) => TaskData.fromJson(jsonDecode(snapshot.data!.getString(e).toString())))
                        .toList();
                    if(ascendingFilter != null){
                      tasksList.sort((a,b)=> b.status == ascendingFilter ? 1 : -1);
                    }
                    if (tasksList.isEmpty) {
                      return const Center(
                        child: Text("No Tasks Added Yet"),
                      );
                    }
                    return ListView.builder(
                      itemCount: tasksList.length,
                      padding: const EdgeInsets.only(top: 12),
                      shrinkWrap: true,
                      itemBuilder: (c, i) {
                        final item = tasksList[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onTap: () {
                              showDetailsDialog(item);
                            },
                            title: Text(
                              item.title.toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: item.status == true
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.teal,
                                  )
                                : TextButton(
                                    onPressed: () {
                                      showDetailsDialog(item);
                                    },
                                    child: const Text("Pending")),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
