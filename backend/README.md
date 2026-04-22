# Student Task Manager - Backend API

This is the Node.js/Express backend API for the Student Task Manager mobile application.

## Setup Instructions

### Prerequisites
- Node.js (v14 or higher)
- npm (comes with Node.js)

### Installation

1. Navigate to the backend folder:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The server will start on `http://localhost:3000`

## API Endpoints

### Users
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - Login user
- `PUT /api/users/:id` - Update user profile

### Tasks
- `GET /api/tasks/user/:userId` - Get all tasks for a user
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `POST /api/tasks/sync` - Sync tasks between local and server

### Health Check
- `GET /api/health` - Check if server is running

## Database

The API uses SQLite database stored in `database.db` file.

## Testing the API

You can test the API using:
- Postman
- curl commands
- The Flutter mobile app

Example curl command:
```bash
curl http://localhost:3000/api/health
```

## Notes

- The database file (`database.db`) will be created automatically on first run
- CORS is enabled for all origins (suitable for development)
- For production, configure proper CORS settings and use environment variables
