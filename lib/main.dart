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

  Plan({required this.name, required this.description, required this.date, this.isCompleted = false});
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

  void _createPlan(String name, String description) {
    setState(() {
      _plans.add(Plan(name: name, description: description, date: _selectedDate));
    });
  }

  void _markCompleted(int index) {
    setState(() {
      _plans[index].isCompleted = !_plans[index].isCompleted;
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
                _editPlanInList(index, nameController.text, descriptionController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPlanInList(int index, String newName, String newDescription) {
    setState(() {
      _plans[index].name = newName;
      _plans[index].description = newDescription;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      _plans.removeAt(index);
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
            SizedBox(height: 10),
            Text("Selected Date: ${_selectedDate.toLocal()}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createPlan(nameController.text, descriptionController.text);
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
          // Calendar Widget
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
            child: ListView.builder(
              itemCount: _filteredPlans.length,
              itemBuilder: (context, index) {
                final plan = _filteredPlans[index];
                return Dismissible(
                  key: Key(plan.hashCode.toString()), // Ensure unique key
                  onDismissed: (_) => _deletePlan(index),
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(plan.name),
                    subtitle: Text(plan.description),
                    tileColor: plan.isCompleted ? Colors.green[100] : Colors.red[100],
                    onLongPress: () => _editPlan(index),
                    onTap: () => _markCompleted(index),
                  ),
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
