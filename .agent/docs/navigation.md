# GoRouter Navigation Setup

## Routes đã setup

### Shell Routes (có bottom navigation)
- ✅ `/` - Home (Arena) Screen
- ✅ `/rank` - Rank Screen  
- ✅ `/tasks` - Tasks Screen
- ✅ `/profile` - Profile Screen

### Top-level Routes (fullscreen dialogs)
- ✅ `/create-task` - Create Task Screen
- ✅ `/active-session` - Active Session Screen

## Cách sử dụng

### 1. Navigate đến Create Task Screen

```dart
// From any screen with BuildContext
context.push(AppRouter.createTask);

// Or using named route
context.pushNamed('createTask');
```

### 2. Navigate đến Active Session Screen

```dart
context.push(AppRouter.activeSession);
```

### 3. Go back

```dart
context.pop();
// hoặc
Navigator.pop(context);
```

## Cấu trúc Routes

```dart
class AppRouter {
  // Route constants
  static const String home = '/';
  static const String rank = '/rank';
  static const String tasks = '/tasks';
  static const String profile = '/profile';
  static const String createTask = '/create-task';
  static const String activeSession = '/active-session';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Shell routes with bottom navigation
      StatefulShellRoute.indexedStack(...),
      
      // Top-level fullscreen dialogs
      GoRoute(path: createTask, ...),
      GoRoute(path: activeSession, ...),
    ],
  );
}
```

## Ưu điểm của GoRouter

1. ✅ **Deep linking support** - URLs có thể share và bookmark
2. ✅ **Type-safe navigation** - Route constants thay vì magic strings
3. ✅ **Declarative routing** - Dễ maintain và test
4. ✅ **State preservation** - StatefulShellRoute giữ state của tabs
5. ✅ **Error handling** - Custom error page
6. ✅ **Debug logging** - `debugLogDiagnostics: true`

## Migration Notes

### Trước (Navigator)
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
);
```

### Sau (GoRouter)
```dart
context.push(AppRouter.createTask);
```

## Future Tasks

- [ ] Add route parameters (task ID, session ID, etc.)
- [ ] Add route guards (authentication, permissions)
- [ ] Add route redirects
- [ ] Add transitions/animations
- [ ] Add nested routes for task details

## Examples

### Navigate with parameters (future)
```dart
// Will implement
context.push('${AppRouter.createTask}?taskId=$taskId');
```

### Navigate and replace
```dart
context.pushReplacement(AppRouter.createTask);
```

### Navigate to root
```dart
context.go(AppRouter.home);
```

### Check current route
```dart
final currentRoute = GoRouter.of(context).location;
```
