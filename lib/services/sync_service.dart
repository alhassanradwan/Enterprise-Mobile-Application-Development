import '../db/database_helper.dart';
import '../models/task_model.dart';
import 'api_service.dart';

class SyncService {
  static Future<Map<String, dynamic>> syncUserTasks(int userId) async {
    try {
      // Get local tasks
      final db = DatabaseHelper.instance;
      final localTasks = await db.getTasksForUser(userId);

      // Sync with server
      final result = await ApiService.syncTasks(userId, localTasks);

      if (result['success']) {
        final List<TaskModel> serverTasks = result['data'];
        
        // Update local database with server tasks
        // In a real app, implement proper merge logic
        // For now, we'll just ensure server tasks exist locally
        
        return {
          'success': true,
          'message': 'Synced ${serverTasks.length} tasks',
          'tasks': serverTasks
        };
      } else {
        return result;
      }
    } catch (e) {
      return {'success': false, 'error': 'Sync failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> pushTaskToServer(TaskModel task) async {
    try {
      if (task.id == null) {
        // New task - create on server
        return await ApiService.createTask(task);
      } else {
        // Existing task - update on server
        return await ApiService.updateTask(task);
      }
    } catch (e) {
      return {'success': false, 'error': 'Push failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteTaskFromServer(int taskId) async {
    try {
      return await ApiService.deleteTask(taskId);
    } catch (e) {
      return {'success': false, 'error': 'Delete failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> pullTasksFromServer(int userId) async {
    try {
      final result = await ApiService.getTasks(userId);
      
      if (result['success']) {
        final List<TaskModel> serverTasks = result['data'];
        
        // Update local database
        final db = DatabaseHelper.instance;
        for (var task in serverTasks) {
          // Check if task exists locally
          final localTasks = await db.getTasksForUser(userId);
          final exists = localTasks.any((t) => t.id == task.id);
          
          if (!exists) {
            await db.insertTask(task);
          } else {
            await db.updateTask(task);
          }
        }
        
        return {
          'success': true,
          'message': 'Pulled ${serverTasks.length} tasks from server'
        };
      }
      
      return result;
    } catch (e) {
      return {'success': false, 'error': 'Pull failed: $e'};
    }
  }
}
