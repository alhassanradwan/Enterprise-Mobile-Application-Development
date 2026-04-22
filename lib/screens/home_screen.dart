import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/sync_service.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  late UserModel _currentUser;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _db.getTasksForUser(_currentUser.id!);
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _openAddTask() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(userId: _currentUser.id!),
      ),
    );

    if (changed == true) {
      await _loadTasks();
    }
  }

  Future<void> _openEditTask(TaskModel task) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(userId: _currentUser.id!, task: task),
      ),
    );

    if (changed == true) {
      await _loadTasks();
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteTask(task.id!);
      await _loadTasks();
    }
  }

  Future<void> _toggleTaskCompletion(TaskModel task, bool? value) async {
    final updated = task.copyWith(isCompleted: value ?? false);
    await _db.updateTask(updated);
    await _loadTasks();
  }

  Future<void> _openProfile() async {
    final updatedUser = await Navigator.of(context).push<UserModel>(
      MaterialPageRoute(builder: (_) => ProfileScreen(user: _currentUser)),
    );

    if (updatedUser != null) {
      setState(() => _currentUser = updatedUser);
    }
  }

  Future<void> _syncWithServer() async {
    setState(() => _isLoading = true);
    
    final result = await SyncService.syncUserTasks(_currentUser.id!);
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Sync successful')),
      );
      await _loadTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Sync failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _tasks.where((task) => task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: _syncWithServer,
            icon: const Icon(Icons.cloud_sync),
            tooltip: 'Sync with Server',
          ),
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${_currentUser.fullName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('Completed: $completedCount / ${_tasks.length}'),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const Center(
                          child: Text('No tasks yet. Tap Add Task to get started.'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTasks,
                          child: ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return TaskTile(
                                task: task,
                                onCompletedChanged: (value) =>
                                    _toggleTaskCompletion(task, value),
                                onEdit: () => _openEditTask(task),
                                onDelete: () => _deleteTask(task),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
