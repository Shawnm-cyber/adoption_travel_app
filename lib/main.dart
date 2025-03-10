import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(AdoptionTravelApp());
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class AdoptionTravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Plans',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PlanManagerScreen(),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  final List<Plan> _plans = [];
  DateTime _selectedDate = DateTime.now();

  void _createPlan(String name, String description, DateTime date) {
    setState(() {
      _plans.add(Plan(name: name, description: description, date: date));
    });
  }

  void _editPlan(int index) {
    TextEditingController nameController = TextEditingController(text: _plans[index].name);
    TextEditingController descriptionController = TextEditingController(text: _plans[index].description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _plans[index].name = nameController.text;
                  _plans[index].description = descriptionController.text;
                });
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePlan(int index) {
    setState(() {
      _plans.removeAt(index);
    });
  }

  void _markCompleted(int index) {
    setState(() {
      _plans[index].isCompleted = !_plans[index].isCompleted;
    });
  }

  void _showCreatePlanModal(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createPlan(nameController.text, descriptionController.text, _selectedDate);
                Navigator.pop(context);
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Plan> _filteredPlans = _plans.where((plan) => isSameDay(plan.date, _selectedDate)).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Adoption & Travel Plans')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
          ),
          Expanded(
            child: DragTarget<Plan>(
              onAccept: (plan) {
                setState(() {
                  plan.date = _selectedDate;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  itemCount: _filteredPlans.length,
                  itemBuilder: (context, index) {
                    final plan = _filteredPlans[index];
                    return GestureDetector(
                      onLongPress: () => _editPlan(index),
                      onDoubleTap: () => _deletePlan(index),
                      child: Dismissible(
                        key: Key(plan.hashCode.toString()),
                        onDismissed: (_) => _markCompleted(index),
                        background: Container(color: Colors.green),
                        child: Draggable<Plan>(
                          data: plan,
                          feedback: Material(
                            child: Container(
                              color: Colors.blueAccent,
                              padding: EdgeInsets.all(8.0),
                              child: Text(plan.name, style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          child: ListTile(
                            title: Text(plan.name),
                            subtitle: Text(plan.description),
                            tileColor: plan.isCompleted ? Colors.green[100] : Colors.red[100],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlanModal(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
