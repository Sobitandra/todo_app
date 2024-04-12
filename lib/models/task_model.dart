class TaskData {
  String? title;
  String? taskId;
  bool? status;
  DateTime? timeOfDone;
  DateTime? timeOfCreate;
  TaskData({this.timeOfDone, this.status, this.title, this.timeOfCreate, this.taskId});

  static TaskData addTask(String v) {
    return TaskData(
      title: v,
      timeOfCreate: DateTime.now(),
      status: false,
      taskId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  TaskData.fromJson(Map<String, dynamic> map) {
    title = map["title"];
    taskId = map["taskId"];
    status = map["status"];
    timeOfDone = DateTime.tryParse(map["timeOfDone"].toString());
    timeOfCreate = DateTime.tryParse(map["timeOfCreate"].toString());
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map["title"] = title;
    map["status"] = status;
    map["taskId"] = taskId;
    map["timeOfDone"] = timeOfDone.toString();
    map["timeOfCreate"] = timeOfCreate.toString();
    return map;
  }
}
