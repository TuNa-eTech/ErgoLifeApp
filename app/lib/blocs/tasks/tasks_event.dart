import 'package:equatable/equatable.dart';

/// TasksBloc events
abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Load all tasks (activities history)
class LoadTasks extends TasksEvent {
  final bool silent;
  const LoadTasks({this.silent = false});

  @override
  List<Object> get props => [silent];
}

/// Refresh tasks (pull-to-refresh)
class RefreshTasks extends TasksEvent {
  const RefreshTasks();
}

/// Filter tasks by status
class FilterTasks extends TasksEvent {
  final String filter; // 'active', 'completed'

  const FilterTasks({required this.filter});

  @override
  List<Object?> get props => [filter];
}
