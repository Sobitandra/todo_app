import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../models/task_model.dart';

enum TasksUpdate { complete, delete }

class TasksDetailsDialog extends StatefulWidget {
  const TasksDetailsDialog({super.key, required this.taskData, required this.onUpdate});
  final TaskData taskData;
  final Function(TasksUpdate tasksUpdate) onUpdate;

  @override
  State<TasksDetailsDialog> createState() => _TasksDetailsDialogState();
}

class _TasksDetailsDialogState extends State<TasksDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.taskData.title.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(
              height: 10,
            ),
            if (widget.taskData.timeOfDone != null) ...[
              const SizedBox(
                height: 10,
              ),
              Text(
                "Task Completion Time\n${DateFormat("dd-MM-yyyy hh:mm a").format(widget.taskData.timeOfDone!)}",
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onUpdate(TasksUpdate.delete);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.red),
                        child: const Text(
                          "Delete",
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                        ))),
                if (widget.taskData.status != true) ...[
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onUpdate(TasksUpdate.complete);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Theme.of(context).primaryColor),
                          child: const Text(
                            "Complete",
                            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                          ))),
                ],
              ],
            )
          ],
        ),
      ),
    ).animate().scale().fade();
  }
}
