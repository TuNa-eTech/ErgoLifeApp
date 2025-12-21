# TasksScreen - Màn Hình Danh Sách Nhiệm Vụ

## 1. Thông Tin Chung

| Property | Value |
|----------|-------|
| **File** | `lib/ui/screens/tasks/tasks_screen.dart` |
| **Route** | `/tasks` |
| **Type** | `StatelessWidget` |
| **Tab Index** | 2 (Tasks) |

---

## 2. Mục Đích

- Hiển thị danh sách tất cả nhiệm vụ
- Filter theo trạng thái: Active, Completed, Saved Routines
- Highlight high-priority task
- Quick access vào active session

---

## 3. UI Components

### 3.1 Widget Hierarchy

```
Scaffold
└── Stack
    ├── SingleChildScrollView (padding bottom 100)
    │   └── Column
    │       ├── Header Section
    │       │   ├── Title "Daily Missions"
    │       │   ├── Filter + Avatar buttons
    │       │   └── Tab Chips (Active, Completed, Saved)
    │       ├── High Priority Task Card
    │       └── Task List
    │           ├── TaskItem 1
    │           ├── TaskItem 2
    │           └── ...
    └── Positioned (bottom right)
        └── FAB (Add Task)
```

---

## 4. Header Section

### 4.1 Title Row
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text("Daily Missions", style: bold 28px),
    Row(
      children: [
        FilterButton(icon: filter_list),
        SizedBox(width: 12),
        UserAvatar(bordered),
      ],
    ),
  ],
)
```

### 4.2 Tab Chips
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      TabChip("Active Tasks (4)", isActive: true),
      TabChip("Completed", isActive: false),
      TabChip("Saved Routines", isActive: false),
    ],
  ),
)
```

### 4.3 Tab Chip Component
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  decoration: BoxDecoration(
    color: isActive ? activeColor : surfaceColor,
    borderRadius: BorderRadius.circular(30),
    border: !isActive ? Border.all(...) : null,
    boxShadow: isActive ? [...] : null,
  ),
  child: Text(label, style: TextStyle(
    color: isActive ? contrastColor : subColor,
    fontWeight: FontWeight.bold,
  )),
)
```

---

## 5. High Priority Task Card

### 5.1 Structure
```dart
Container(
  padding: 20,
  decoration: BoxDecoration(
    color: AppColors.secondary, // Orange
    borderRadius: BorderRadius.circular(24),
    boxShadow: [...],
  ),
  child: Stack(
    children: [
      // Background decorations (circles)
      Positioned(right: -16, top: -16, child: BlurredCircle),
      Positioned(left: -16, bottom: -16, child: Circle),
      
      // Content
      Column(
        children: [
          Row(icon, "High Priority" badge),
          Title "Full Body Blitz",
          Subtitle "Deep Clean Living Room & Kitchen",
          Row(
            duration chip "45m",
            points "350 EP",
            PlayButton,
          ),
        ],
      ),
    ],
  ),
)
```

### 5.2 Hardcoded Data
```dart
{
  title: "Full Body Blitz",
  subtitle: "Deep Clean Living Room & Kitchen",
  duration: "45m",
  points: 350,
  priority: "high"
}
```

---

## 6. Task List

### 6.1 TaskItem Component

```dart
Opacity(
  opacity: isCompleted ? 0.6 : 1.0,
  child: Container(
    padding: 16,
    decoration: BoxDecoration(
      color: surfaceColor,
      borderRadius: 16,
      border: Border.all(...),
    ),
    child: InkWell(
      onTap: () => navigateToSession,
      child: Row(
        children: [
          IconBox(icon, iconColor),
          Expanded(
            child: Column(
              children: [
                Row(title, [tag], [done badge]),
                Subtitle,
                Row(duration, points),
              ],
            ),
          ),
          CheckCircle (filled if completed),
        ],
      ),
    ),
  ),
)
```

### 6.2 TaskItem Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `title` | `String` | ✅ | Exercise title (e.g., "Legs & Glutes") |
| `subtitle` | `String` | ✅ | Task description |
| `time` | `String` | ✅ | Duration (e.g., "20 min") |
| `score` | `String` | ✅ | Points (e.g., "150 EP") |
| `tag` | `String?` | ❌ | Optional tag (e.g., "ZONE 2") |
| `icon` | `IconData` | ✅ | Task icon |
| `iconColor` | `Color` | ✅ | Icon tint color |
| `iconBgColor` | `Color` | ✅ | Icon background |
| `isCompleted` | `bool` | ❌ | Completed state |

### 6.3 Hardcoded Tasks

| Title | Subtitle | Time | Score | Icon | Color |
|-------|----------|------|-------|------|-------|
| Legs & Glutes | Vacuuming Bedroom & Hallway | 20 min | 150 EP | cleaning_services | Purple |
| Upper Body Press | Laundry Loading & Hanging | 15 min | 80 EP | local_laundry_service | Blue |
| Cardio Dash | Grocery Run (Heavy Load) | 45 min | 200 EP | shopping_bag | Green |
| Core Stability | Dishwashing | 10 min | +50 EP | water_drop | Grey (done) |

---

## 7. User Interactions

| Element | Action | Navigation/Effect |
|---------|--------|-------------------|
| Filter button | Tap | TODO: Show filter options |
| User avatar | Tap | TODO: Navigate to profile? |
| Tab chip | Tap | TODO: Filter tasks by status |
| High Priority play | Tap | → `/active-session` |
| Task item | Tap | → `/active-session` (if not completed) |
| Task checkbox | Tap | TODO: Toggle completion? |
| FAB (+) | Tap | → `/create-task` |

---

## 8. API Integration

### 8.1 APIs Cần Gọi

| API | Method | Purpose |
|-----|--------|---------|
| `GET /activities` | GET | Fetch user's activity history |
| (Future) `GET /tasks` | GET | Fetch suggested/predefined tasks |

### 8.2 Filter Parameters

```http
GET /activities?status=active&page=1&limit=20
GET /activities?status=completed&page=1&limit=20
```

### 8.3 Expected Response Mapping

Hiện tại tasks là hardcoded. Khi tích hợp API:

```dart
// From activity history - completed tasks
activities.map((a) => TaskItem(
  title: a.taskName,
  time: "${a.durationSeconds ~/ 60} min",
  score: "${a.pointsEarned} EP",
  isCompleted: true,
))

// Predefined tasks - từ config hoặc AI suggestions
predefinedTasks.map((t) => TaskItem(...))
```

---

## 9. State Management

### 9.1 Cần Implement

```dart
// TasksBloc
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  on<LoadTasks>((event, emit) async {
    emit(TasksLoading());
    try {
      final activities = await activityRepo.getActivities();
      final suggestions = await taskRepo.getSuggestions();
      emit(TasksLoaded(activities, suggestions));
    } catch (e) {
      emit(TasksError(e.message));
    }
  });
}
```

### 9.2 Filter State

```dart
enum TaskFilter { active, completed, savedRoutines }

class TasksLoaded extends TasksState {
  final List<Activity> completedActivities;
  final List<Task> activeTasks;
  final List<Task> savedRoutines;
  final TaskFilter currentFilter;
}
```

---

## 10. Cải Tiến Đề Xuất

### 10.1 Issues Hiện Tại
- ⚠️ All data hardcoded
- ⚠️ Tab filtering not implemented
- ⚠️ Filter button does nothing
- ⚠️ Checkbox doesnt work
- ⚠️ No loading/error states
- ⚠️ No pagination

### 10.2 Tab Implementation

```dart
class TasksScreen extends StatefulWidget {
  // Change to StatefulWidget
}

class _TasksScreenState extends State<TasksScreen> {
  String _activeTab = 'active';
  
  List<TaskItem> get filteredTasks {
    switch (_activeTab) {
      case 'active':
        return tasks.where((t) => !t.isCompleted).toList();
      case 'completed':
        return tasks.where((t) => t.isCompleted).toList();
      case 'saved':
        return savedRoutines;
    }
  }
}
```

### 10.3 Swipe Actions

```dart
Dismissible(
  key: Key(task.id),
  background: Container(color: Colors.red, child: Icon(delete)),
  secondaryBackground: Container(color: Colors.green, child: Icon(done)),
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      // Delete
    } else {
      // Mark complete
    }
  },
  child: TaskItem(...),
)
```

### 10.4 Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () => context.read<TasksBloc>().add(LoadTasks()),
  child: SingleChildScrollView(...),
)
```

---

## 11. Data Model

### 11.1 Task Model (Proposed)

```dart
class Task {
  final String id;
  final String title;
  final String description;
  final int estimatedDuration; // seconds
  final int estimatedPoints;
  final double metsValue;
  final String? category;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isSavedRoutine;
}
```

### 11.2 Categories

| Category | Icon | Color |
|----------|------|-------|
| Cleaning | cleaning_services | Purple |
| Laundry | local_laundry_service | Blue |
| Shopping | shopping_bag | Green |
| Kitchen | water_drop / restaurant | Pink |
| Outdoor | nature | Teal |
| Custom | star | Orange |

---

## 12. Responsive Considerations

- Horizontal scroll cho tabs
- Task items full width với proper padding
- FAB positioned absolute với safe area
