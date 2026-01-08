# Task System Architecture

## Overview

The ErgoLife app uses a dynamic task system that allows users to manage household activities. Tasks are stored in the backend and synced to the Flutter app via API.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TASK SYSTEM ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Database (PostgreSQL)                                                      │
│  ─────────────────────                                                      │
│  ┌─────────────────────┐    ┌─────────────────────┐                        │
│  │   TaskTemplate      │    │    CustomTask       │                        │
│  │   (CMS Templates)   │    │    (User Tasks)     │                        │
│  ├─────────────────────┤    ├─────────────────────┤                        │
│  │ - id                │    │ - id                │                        │
│  │ - metsValue         │    │ - userId            │                        │
│  │ - defaultDuration   │    │ - templateId?       │                        │
│  │ - icon              │    │ - exerciseName      │                        │
│  │ - animation         │    │ - taskDescription   │                        │
│  │ - color             │    │ - durationMinutes   │                        │
│  │ - category          │    │ - metsValue         │                        │
│  │ - sortOrder         │    │ - icon, color, etc. │                        │
│  │ - isActive          │    │ - sortOrder         │                        │
│  └─────────────────────┘    │ - isHidden          │                        │
│           │                 │ - isFavorite        │                        │
│           │                 └─────────────────────┘                        │
│           ▼                            ▲                                   │
│  ┌─────────────────────┐               │                                   │
│  │ TaskTemplateTranslation│            │                                   │
│  ├─────────────────────┤               │                                   │
│  │ - locale (en, vi)   │               │                                   │
│  │ - name              │               │                                   │
│  │ - description       │               │                                   │
│  └─────────────────────┘               │                                   │
│                                        │                                   │
│  User                                  │                                   │
│  ─────────────────                     │                                   │
│  ┌─────────────────────┐               │                                   │
│  │ - hasSeededTasks    │───────────────┘                                   │
│  │   (boolean)         │                                                   │
│  └─────────────────────┘                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Task Seeding Flow

When a new user logs in for the first time, the system automatically seeds default tasks:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           FIRST LOGIN SEEDING FLOW                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Flutter App                         Backend                                │
│  ───────────                         ───────                                │
│                                                                             │
│  1. HomeBloc.LoadHomeData                                                   │
│     └── _ensureTasksSeeded()                                                │
│         │                                                                   │
│         ▼                                                                   │
│  2. GET /tasks/needs-seeding ─────────────────────►                         │
│                                      needsSeeding(userId)                   │
│                                      → Check User.hasSeededTasks            │
│                           ◄─────────────────────────                        │
│     ◄─── {needsSeeding: true/false}                                         │
│                                                                             │
│  3. IF needsSeeding == true:                                                │
│     GET /task-templates?locale=vi ─────────────────►                        │
│                                      → Return 20 templates                  │
│                           ◄─────────────────────────                        │
│     ◄─── [{id, name, metsValue...}, ...]                                    │
│                                                                             │
│  4. POST /tasks/seed ─────────────────────────────►                         │
│     body: {tasks: [...]}             seedDefaultTasks(userId, tasks)        │
│                                      → Create CustomTask for each           │
│                                      → Set hasSeededTasks = true            │
│                           ◄─────────────────────────                        │
│     ◄─── {seeded: true, tasksCreated: 20}                                   │
│                                                                             │
│  5. GET /tasks ───────────────────────────────────►                         │
│                                      → Return user's CustomTasks            │
│                           ◄─────────────────────────                        │
│     ◄─── [{id, exerciseName...}, ...]                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## API Endpoints

### Task Templates (Admin/CMS)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/task-templates` | Get all active templates (with locale param) |
| POST | `/task-templates` | Create a new template |
| GET | `/task-templates/:id` | Get template by ID |
| PATCH | `/task-templates/:id` | Update template |
| DELETE | `/task-templates/:id` | Soft delete (set isActive=false) |

### User Tasks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | Get all user tasks (query param: `includeHidden`) |
| POST | `/tasks` | Create a new task |
| PATCH | `/tasks/:id` | Update task |
| DELETE | `/tasks/:id` | Delete task |
| PATCH | `/tasks/:id/favorite` | Toggle favorite status |
| PATCH | `/tasks/:id/visibility` | Toggle hidden status |
| POST | `/tasks/reorder` | Reorder tasks (batch update sortOrder) |

### Seeding

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks/needs-seeding` | Check if user needs task seeding |
| POST | `/tasks/seed` | Seed default tasks from templates |

## Flutter Implementation

### Repository Layer

```dart
// lib/data/repositories/task_repository.dart

class TaskRepository {
  // Get task templates for seeding
  Future<Either<Failure, List<Map<String, dynamic>>>> getTaskTemplates({
    String locale = 'en',
  });

  // Check if user needs seeding
  Future<Either<Failure, bool>> needsTaskSeeding();

  // Seed tasks from templates
  Future<Either<Failure, Map<String, dynamic>>> seedTasks(
    List<Map<String, dynamic>> tasks,
  );

  // Get all user tasks
  Future<Either<Failure, List<Map<String, dynamic>>>> getTasks({
    bool includeHidden = false,
  });

  // CRUD operations
  Future<Either<Failure, Map<String, dynamic>>> createTask(Map<String, dynamic> taskData);
  Future<Either<Failure, Map<String, dynamic>>> updateTask(String taskId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteTask(String taskId);
  
  // Toggle operations
  Future<Either<Failure, Map<String, dynamic>>> toggleTaskVisibility(String taskId);
  Future<Either<Failure, Map<String, dynamic>>> toggleTaskFavorite(String taskId);
  
  // Reorder
  Future<Either<Failure, void>> reorderTasks(List<Map<String, dynamic>> taskOrders);
}
```

### BLoC Layer

```dart
// lib/blocs/home/home_bloc.dart

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // Ensure tasks are seeded for new users
  Future<void> _ensureTasksSeeded() async {
    // 1. Check if user needs seeding
    final needsSeedingResult = await _taskRepository.needsTaskSeeding();
    
    if (!needsSeeding) return;
    
    // 2. Get templates
    final templatesResult = await _taskRepository.getTaskTemplates();
    
    // 3. Convert and seed
    final tasksToSeed = templates.map((t) => {
      'exerciseName': t['name'],
      'taskDescription': t['description'],
      'durationMinutes': t['defaultDuration'],
      // ...
    }).toList();
    
    await _taskRepository.seedTasks(tasksToSeed);
  }
}
```

## Database Seeding

### Seed Task Templates

Run this command to seed default task templates:

```bash
cd backend
npx ts-node prisma/seeds/seed-templates.ts
```

This creates 20 household task templates with English and Vietnamese translations.

### Reset Database

To reset the database and re-apply all seeds:

```bash
cd backend
npx prisma migrate reset --force
npx ts-node prisma/seeds/seed-templates.ts
```

## Task Templates

The system includes 20 predefined household task templates:

| Category | Tasks |
|----------|-------|
| Cleaning | Vacuuming, Mopping, Sweeping, Dusting, Window Cleaning |
| Kitchen | Dishwashing, Cooking, Kitchen Cleanup, Taking Out Trash |
| Laundry | Hanging Laundry, Ironing, Folding Clothes |
| Bathroom | Toilet Cleaning, Bathroom Scrubbing |
| Bedroom | Making Bed |
| Organizing | Organizing Closet |
| Outdoor | Watering Plants, Yard Sweeping |
| Care | Pet Care |
| Shopping | Grocery Shopping |

Each template includes:
- **MET Value**: Metabolic Equivalent for calorie calculation
- **Default Duration**: Suggested time in minutes
- **Icon**: Material icon name
- **Animation**: Lottie animation file (optional)
- **Color**: Hex color for UI display
- **Translations**: Localized name and description

## Response Format

All API responses are wrapped by `TransformInterceptor`:

```json
{
  "success": true,
  "data": {
    // actual response data
  }
}
```

**Important**: Controllers should return data directly without wrapping, as the interceptor handles this automatically.

```typescript
// ✅ Correct
async getTasks(@CurrentUser() user: JwtPayload) {
  return this.tasksService.getCustomTasks(user.sub);
}

// ❌ Wrong - causes double wrapping
async getTasks(@CurrentUser() user: JwtPayload) {
  return {
    success: true,
    data: await this.tasksService.getCustomTasks(user.sub),
  };
}
```

## Troubleshooting

### Tasks not loading for new users

1. Check if `task_templates` table has data:
   ```bash
   docker exec -it ergolife-postgres psql -U ergolife -d ergolife_db -c "SELECT COUNT(*) FROM task_templates;"
   ```

2. Check user's seeding status:
   ```bash
   docker exec -it ergolife-postgres psql -U ergolife -d ergolife_db -c "SELECT id, has_seeded_tasks FROM users;"
   ```

3. Verify API response is not double-wrapped in Flutter logs

### Reseed tasks for existing user

```sql
UPDATE users SET has_seeded_tasks = false WHERE id = 'user-id';
```

Then re-login in the app.
