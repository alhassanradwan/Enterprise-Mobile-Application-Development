import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../models/user_model.dart';

class ApiService {
  // Change this to your backend URL when deployed
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For physical device, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.1.X:3000/api';

  // User endpoints
  static Future<Map<String, dynamic>> registerUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': user.fullName,
          'gender': user.gender,
          'email': user.email,
          'studentId': user.studentId,
          'academicLevel': user.academicLevel,
          'password': user.password,
          'profileImagePath': user.profileImagePath,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUser(UserModel user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': user.fullName,
          'gender': user.gender,
          'email': user.email,
          'studentId': user.studentId,
          'academicLevel': user.academicLevel,
          'password': user.password,
          'profileImagePath': user.profileImagePath,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': jsonDecode(response.body)['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Task endpoints
  static Future<Map<String, dynamic>> getTasks(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = jsonDecode(response.body);
        final tasks = tasksJson.map((json) => TaskModel.fromMap(json)).toList();
        return {'success': true, 'data': tasks};
      } else {
        return {'success': false, 'error': 'Failed to load tasks'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createTask(TaskModel task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toMap()),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to create task'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateTask(TaskModel task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(task.toMap()),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to update task'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': 'Failed to delete task'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Sync local database with server
  static Future<Map<String, dynamic>> syncTasks(int userId, List<TaskModel> localTasks) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'tasks': localTasks.map((t) => t.toMap()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = jsonDecode(response.body);
        final tasks = tasksJson.map((json) => TaskModel.fromMap(json)).toList();
        return {'success': true, 'data': tasks};
      } else {
        return {'success': false, 'error': 'Sync failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
