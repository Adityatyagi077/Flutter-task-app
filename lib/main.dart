import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// ================= MODEL =================
class Task {
  String title;
  String dateTime;
  bool isDone;

  Task(this.title, this.dateTime, {this.isDone = false});
}

// ================= HOME =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  List<Task> tasks = [];

  // ========== ADD TASK ==========
  Future<void> addTask() async {
    TextEditingController controller = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Add Task",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: "Task name"),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            selectedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );
                            setModalState(() {});
                          },
                          child: Text(selectedDate == null
                              ? "Pick Date"
                              : selectedDate.toString().split(" ")[0]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            setModalState(() {});
                          },
                          child: Text(selectedTime == null
                              ? "Pick Time"
                              : selectedTime!.format(context)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isEmpty) return;

                      String date = selectedDate == null
                          ? "Today"
                          : selectedDate.toString().split(" ")[0];

                      String time = selectedTime == null
                          ? ""
                          : selectedTime!.format(context);

                      setState(() {
                        tasks.add(Task(controller.text, "$date $time"));
                      });

                      Navigator.pop(context);
                    },
                    child: const Text("Add"),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ================= TASK VIEW =================
  Widget buildTasks() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Tasks",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final task = tasks[i];

              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      task.isDone = !task.isDone;
                    });
                  },
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        task.isDone ? Colors.green : Colors.grey.shade300,
                    child: task.isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),

                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                subtitle: Text(task.dateTime),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      tasks.removeAt(i);
                    });
                  },
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: addTask,
            child: const Text("+ Add Task"),
          ),
        )
      ],
    );
  }

  // ================= SCHEDULE =================
  Widget buildSchedule() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Today"),
              Tab(text: "Upcoming"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  children: const [
                    ListTile(title: Text("Meeting"), subtitle: Text("10:00 AM")),
                    ListTile(title: Text("Lunch"), subtitle: Text("1:00 PM")),
                  ],
                ),
                ListView(
                  children: const [
                    ListTile(title: Text("Report"), subtitle: Text("Tomorrow")),
                    ListTile(title: Text("Gym"), subtitle: Text("Saturday")),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= NOTES =================
  Widget buildNotes() {
    List<String> notes = [
      "Project ideas",
      "Meeting notes",
      "Shopping list",
      "Books"
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(notes[i]),
        );
      },
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    List<Widget> views = [
      buildTasks(),
      buildSchedule(),
      buildNotes()
    ];

    return Scaffold(
      body: SafeArea(child: views[currentIndex]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: "Notes"),
        ],
      ),
    );
  }
}