const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Database setup
const dbPath = path.join(__dirname, 'database.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err);
  } else {
    console.log('Connected to SQLite database');
    initDatabase();
  }
});

// Initialize database tables
function initDatabase() {
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fullName TEXT NOT NULL,
      gender TEXT,
      email TEXT UNIQUE NOT NULL,
      studentId TEXT UNIQUE NOT NULL,
      academicLevel TEXT,
      password TEXT NOT NULL,
      profileImagePath TEXT,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      dueDate TEXT NOT NULL,
      priority TEXT NOT NULL,
      isCompleted INTEGER DEFAULT 0,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    )
  `);
}

// ============ USER ROUTES ============

// Register user
app.post('/api/users/register', (req, res) => {
  const { fullName, gender, email, studentId, academicLevel, password, profileImagePath } = req.body;

  if (!fullName || !email || !studentId || !password) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const query = `INSERT INTO users (fullName, gender, email, studentId, academicLevel, password, profileImagePath) 
                 VALUES (?, ?, ?, ?, ?, ?, ?)`;

  db.run(query, [fullName, gender, email, studentId, academicLevel, password, profileImagePath], function(err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        return res.status(400).json({ error: 'Email or Student ID already exists' });
      }
      return res.status(500).json({ error: 'Database error' });
    }

    res.status(201).json({
      id: this.lastID,
      fullName,
      gender,
      email,
      studentId,
      academicLevel,
      profileImagePath
    });
  });
});

// Login user
app.post('/api/users/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  const query = 'SELECT * FROM users WHERE email = ? AND password = ?';

  db.get(query, [email, password], (err, row) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    if (!row) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    res.json({
      id: row.id,
      fullName: row.fullName,
      gender: row.gender,
      email: row.email,
      studentId: row.studentId,
      academicLevel: row.academicLevel,
      profileImagePath: row.profileImagePath
    });
  });
});

// Update user
app.put('/api/users/:id', (req, res) => {
  const { id } = req.params;
  const { fullName, gender, email, studentId, academicLevel, password, profileImagePath } = req.body;

  const query = `UPDATE users 
                 SET fullName = ?, gender = ?, email = ?, studentId = ?, 
                     academicLevel = ?, password = ?, profileImagePath = ?
                 WHERE id = ?`;

  db.run(query, [fullName, gender, email, studentId, academicLevel, password, profileImagePath, id], function(err) {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    if (this.changes === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ message: 'User updated successfully' });
  });
});

// ============ TASK ROUTES ============

// Get all tasks for a user
app.get('/api/tasks/user/:userId', (req, res) => {
  const { userId } = req.params;

  const query = 'SELECT * FROM tasks WHERE userId = ? ORDER BY dueDate ASC';

  db.all(query, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    const tasks = rows.map(row => ({
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      dueDate: row.dueDate,
      priority: row.priority,
      isCompleted: row.isCompleted
    }));

    res.json(tasks);
  });
});

// Create task
app.post('/api/tasks', (req, res) => {
  const { userId, title, description, dueDate, priority, isCompleted } = req.body;

  if (!userId || !title || !dueDate || !priority) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const query = `INSERT INTO tasks (userId, title, description, dueDate, priority, isCompleted) 
                 VALUES (?, ?, ?, ?, ?, ?)`;

  db.run(query, [userId, title, description, dueDate, priority, isCompleted || 0], function(err) {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    res.status(201).json({
      id: this.lastID,
      userId,
      title,
      description,
      dueDate,
      priority,
      isCompleted: isCompleted || 0
    });
  });
});

// Update task
app.put('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const { title, description, dueDate, priority, isCompleted } = req.body;

  const query = `UPDATE tasks 
                 SET title = ?, description = ?, dueDate = ?, priority = ?, isCompleted = ?
                 WHERE id = ?`;

  db.run(query, [title, description, dueDate, priority, isCompleted ? 1 : 0, id], function(err) {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    if (this.changes === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json({ message: 'Task updated successfully' });
  });
});

// Delete task
app.delete('/api/tasks/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM tasks WHERE id = ?';

  db.run(query, [id], function(err) {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    if (this.changes === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.json({ message: 'Task deleted successfully' });
  });
});

// Sync tasks (merge local and server data)
app.post('/api/tasks/sync', (req, res) => {
  const { userId, tasks } = req.body;

  // Get all server tasks for this user
  const query = 'SELECT * FROM tasks WHERE userId = ?';

  db.all(query, [userId], (err, serverTasks) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    // Simple sync: return server tasks (in production, implement proper merge logic)
    const tasksToReturn = serverTasks.map(row => ({
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      dueDate: row.dueDate,
      priority: row.priority,
      isCompleted: row.isCompleted
    }));

    res.json(tasksToReturn);
  });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log(`API available at http://localhost:${PORT}/api`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error('Error closing database:', err);
    } else {
      console.log('Database connection closed');
    }
    process.exit(0);
  });
});
