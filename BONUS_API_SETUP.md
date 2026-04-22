# Bonus Feature: API Integration Setup Guide

This guide explains how to set up and run the backend API for the Student Task Manager app.

## ✅ What's Implemented

The bonus API integration includes:
- ✅ Backend server with Node.js/Express
- ✅ SQLite database on the server
- ✅ User registration and login via API
- ✅ Task CRUD operations via API
- ✅ Sync functionality between local and server
- ✅ Cloud sync button in the app

## 🚀 Quick Setup (3 Steps)

### Step 1: Install Node.js
1. Download Node.js from: https://nodejs.org/
2. Install it (choose LTS version)
3. Verify installation:
   ```bash
   node --version
   npm --version
   ```

### Step 2: Start the Backend Server
1. Open a new terminal/PowerShell
2. Navigate to the backend folder:
   ```bash
   cd backend
   ```
3. Install dependencies (first time only):
   ```bash
   npm install
   ```
4. Start the server:
   ```bash
   npm start
   ```
5. You should see: "Server running on http://localhost:3000"

### Step 3: Run the Flutter App
1. Keep the backend server running
2. In a new terminal, run your Flutter app:
   ```bash
   flutter run
   ```
3. The app will now connect to the backend API!

## 📱 How to Use the API Features

### In the App:
1. **Sync Button**: Tap the cloud sync icon (☁️) in the top bar to sync tasks with the server
2. **Automatic Sync**: Tasks are automatically synced when you:
   - Add a new task
   - Edit a task
   - Delete a task
   - Mark a task as complete

### Testing the Sync:
1. Create some tasks in the app
2. Tap the sync button
3. You should see "Synced X tasks" message
4. Tasks are now stored on the server!

## 🔧 Configuration

### For Emulator (Default):
- The app is configured to use `http://10.0.2.2:3000/api`
- This is the special IP that Android emulator uses to access localhost

### For Physical Device:
1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` (look for inet)
2. Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:3000/api';
   // Example: 'http://192.168.1.100:3000/api'
   ```
3. Make sure your phone and computer are on the same WiFi network

## 📊 API Endpoints

The backend provides these endpoints:

### Users:
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - Login user
- `PUT /api/users/:id` - Update user profile

### Tasks:
- `GET /api/tasks/user/:userId` - Get all tasks
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `POST /api/tasks/sync` - Sync tasks

### Health Check:
- `GET /api/health` - Check server status

## 🧪 Testing the API

### Test if server is running:
```bash
curl http://localhost:3000/api/health
```

Should return: `{"status":"OK","message":"Server is running"}`

### Test with Postman:
1. Download Postman: https://www.postman.com/downloads/
2. Import the API endpoints
3. Test each endpoint

## 📁 Project Structure

```
backend/
├── server.js          # Main server file
├── package.json       # Dependencies
├── database.db        # SQLite database (created automatically)
└── README.md          # Backend documentation

lib/services/
├── api_service.dart   # API calls
└── sync_service.dart  # Sync logic
```

## ⚠️ Troubleshooting

### "Network error" in app:
- Make sure backend server is running
- Check the IP address in `api_service.dart`
- Verify internet permission in AndroidManifest.xml

### "Cannot connect to server":
- For emulator: Use `http://10.0.2.2:3000/api`
- For physical device: Use your computer's IP address
- Make sure firewall isn't blocking port 3000

### Backend won't start:
- Make sure Node.js is installed
- Run `npm install` in the backend folder
- Check if port 3000 is already in use

## 🎯 Bonus Features Checklist

✅ API integration with backend service  
✅ Synchronize tasks with remote server  
✅ Store user data in backend database  
✅ Retrieve tasks from API  
✅ Node.js backend implementation  
✅ SQLite database on server  
✅ RESTful API design  
✅ CORS enabled for mobile app  

## 📝 Notes

- The backend uses SQLite (same as the app) for simplicity
- In production, you'd use PostgreSQL, MySQL, or MongoDB
- The sync is basic - in production, implement conflict resolution
- API has no authentication tokens - add JWT for production
- CORS is open for development - restrict in production

## 🎓 For Submission

Make sure to:
1. Include the `backend/` folder in your submission
2. Include this setup guide
3. Test the sync functionality before submitting
4. Document any changes you made

## 💡 Demo Script

To demonstrate the bonus feature:
1. Start the backend server
2. Run the app
3. Create a task
4. Tap the sync button
5. Show the success message
6. (Optional) Show the database.db file or API response in Postman

---

**Congratulations!** You've successfully implemented the bonus API integration feature! 🎉
