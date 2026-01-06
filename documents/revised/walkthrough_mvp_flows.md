# MVP Flow Adjustments Walkthrough

I have successfully updated the documentation and codebase to align with the simpler "Happy Path" for the MVP.

## 1. Changes Implemented

### 📄 Documentation

- **Household**: Replaced complex QR/Deep Link invite with simple **6-digit House Code**.
- **Core Loop**: Simplified Calorie calculation to use a default **65kg** weight (removing the need for weight input).
- **Rewards**: Simplified Redemption flow to **Instant Redeem** (Points deducted -> Status USED immediately), removing the "Pending" state.
- **Tasks**: Integrated API-based task loading with automatic seeding for new users.

### 💻 Codebase

#### Backend (`backend/src/modules/tasks/tasks.controller.ts`)

- **Modification**: Removed manual `{success: true, data: ...}` wrapping from all endpoints.
- **Reason**: `TransformInterceptor` already wraps responses automatically, causing double-wrapping.
- **Result**: API responses are now correctly structured.

#### Backend (`backend/src/modules/tasks/tasks.service.ts`)

- **Feature**: Added `needsSeeding()` and `seedDefaultTasks()` methods.
- **Result**: New users get 20 default tasks on first login.

#### Mobile App (`app/lib/blocs/home/home_bloc.dart`)

- **Modification**: Added `_ensureTasksSeeded()` to check and seed tasks for new users.
- **Result**: Tasks are loaded from API instead of hardcoded.

#### Mobile App (`app/lib/blocs/tasks/tasks_bloc.dart`)

- **Modification**: Removed `PredefinedTasks` usage, now fetches from `TaskRepository`.
- **Result**: Tasks screen shows user's actual tasks from backend.

#### Mobile App (`app/lib/data/models/task_model.dart`)

- **Modification**: Removed deprecated `PredefinedTasks` class.
- **Result**: All tasks now come from API.

## 2. Task Seeding Flow

```text
New User Login
      │
      ▼
HomeBloc.LoadHomeData
      │
      ├── GET /tasks/needs-seeding
      │       └── returns {needsSeeding: true}
      │
      ├── GET /task-templates?locale=vi
      │       └── returns 20 templates
      │
      ├── POST /tasks/seed
      │       └── creates CustomTasks for user
      │       └── sets hasSeededTasks = true
      │
      └── GET /tasks
              └── returns user's tasks
```

## 3. API Response Structure

All API responses are wrapped by `TransformInterceptor`:

```json
{
  "success": true,
  "data": { /* actual response */ }
}
```

**Important**: Controllers should NOT manually wrap responses.

## 4. Verification Results

### Automated Testing (Mobile MCP)

- **App Launch**: ✅ Successful (`com.anhtu.ergolife`).
- **Home Screen**: ✅ Loaded successfully with tasks from API.
- **Task Seeding**: ✅ New users get 20 default tasks.
- **Dart Analysis**: ✅ No critical errors.

### ⚠️ Known Issues (Resolved)

| Issue | Status | Fix |
|-------|--------|-----|
| Tasks hardcoded | ✅ Fixed | Moved to API + TaskRepository |
| Double-wrapped API response | ✅ Fixed | Removed manual wrapping in controllers |
| New users have no tasks | ✅ Fixed | Added task seeding on first login |

## 5. Related Documentation

- **Technical**: `documents/technical/TASK_SYSTEM.md`
- **Use Cases**: `documents/revised/use_cases/03_core_loop.md`
- **API Specs**: `documents/revised/api/`

