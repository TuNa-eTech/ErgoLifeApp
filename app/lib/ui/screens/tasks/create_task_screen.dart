import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:ergo_life_app/data/models/custom_task_model.dart';
import 'package:ergo_life_app/blocs/task/task_bloc.dart';
import 'package:ergo_life_app/blocs/task/task_event.dart';
import 'package:ergo_life_app/blocs/task/task_state.dart';
import 'package:go_router/go_router.dart';

class CreateTaskScreen extends StatelessWidget {
  final TaskBloc taskBloc;

  const CreateTaskScreen({
    super.key,
    required this.taskBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: taskBloc,
      child: const _CreateTaskScreenContent(),
    );
  }
}

class _CreateTaskScreenContent extends StatefulWidget {
  const _CreateTaskScreenContent();

  @override
  State<_CreateTaskScreenContent> createState() => _CreateTaskScreenContentState();
}

class _CreateTaskScreenContentState extends State<_CreateTaskScreenContent> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();

  IconData _selectedIcon = Icons.fitness_center;
  double _selectedMets = 3.5;

  final List<IconData> _availableIcons = [
    Icons.fitness_center,
    Icons.local_laundry_service,
    Icons.shopping_cart,
    Icons.cleaning_services,
    Icons.add_circle,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.water_drop,
    Icons.kitchen,
  ];

  // Icon name mapping for API
  final Map<IconData, String> _iconNameMap = {
    Icons.fitness_center: 'fitness_center',
    Icons.local_laundry_service: 'laundry',
    Icons.shopping_cart: 'shopping',
    Icons.cleaning_services: 'cleaning',
    Icons.add_circle: 'add',
    Icons.directions_run: 'running',
    Icons.self_improvement: 'yoga',
    Icons.water_drop: 'water',
    Icons.kitchen: 'kitchen',
  };

  // METs options for intensity
  final List<({double value, String label})> _metsOptions = [
    (value: 2.0, label: 'Light'),
    (value: 3.5, label: 'Moderate'),
    (value: 5.0, label: 'Vigorous'),
    (value: 7.0, label: 'Intense'),
  ];

  int get _estimatedPoints {
    final duration = int.tryParse(_durationController.text) ?? 0;
    return (duration * _selectedMets * 10).floor();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter exercise name');
      return false;
    }

    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration < 1 || duration > 120) {
      _showError('Duration must be 1-120 minutes');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createTask() {
    if (!_validateForm()) return;

    final request = CreateCustomTaskRequest(
      exerciseName: _nameController.text.trim(),
      taskDescription: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      durationMinutes: int.parse(_durationController.text),
      metsValue: _selectedMets,
      icon: _iconNameMap[_selectedIcon] ?? 'fitness_center',
    );

    context.read<TaskBloc>().add(CreateCustomTask(request));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.textMainLight;

    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskCreated) {
          _showSuccess('Task created successfully!');
          context.pop();
        } else if (state is TaskError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  _buildHeader(context, isDark, textColor),
                  
                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Create your\nexercise. 🏋️',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -1,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Turn your daily chores into a workout challenge.',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Form Inputs
                          _buildLabel('EXERCISE NAME'),
                           TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Vacuum Lunges',
                              prefixIcon: Icon(Icons.fitness_center, color: AppColors.primary.withOpacity(0.7)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('REAL LIFE TASK (Optional)'),
                          TextField(
                            controller: _descController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Vacuuming living room',
                              prefixIcon: Icon(Icons.cleaning_services, color: AppColors.purple.withOpacity(0.7)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('DURATION'),
                                    TextField(
                                      controller: _durationController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setState(() {}),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '20',
                                        suffixText: 'min',
                                        suffixStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('EST. REWARD'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$_estimatedPoints',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'EP',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Intensity Selector
                          _buildLabel('INTENSITY'),
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _metsOptions.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final option = _metsOptions[index];
                                final isSelected = option.value == _selectedMets;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedMets = option.value),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                        ? AppColors.primary 
                                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Text(
                                      option.label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildLabel('CHOOSE ICON'),
                          SizedBox(
                            height: 64,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableIcons.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final icon = _availableIcons[index];
                                final isSelected = icon == _selectedIcon;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedIcon = icon),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                        ? AppColors.primary 
                                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ] : [],
                                    ),
                                    child: Icon(
                                      icon,
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey[500] : Colors.grey[400]),
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky Bottom Button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        bgColor,
                        bgColor.withOpacity(0.95),
                        bgColor.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                  child: BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final isLoading = state is TaskCreating;
                      return SizedBox(
                         height: 56,
                         child: ElevatedButton(
                           onPressed: isLoading ? null : _createTask,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppColors.secondary,
                             disabledBackgroundColor: AppColors.secondary.withOpacity(0.5),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(30),
                             ),
                             elevation: 8,
                             shadowColor: AppColors.secondary.withOpacity(0.4),
                           ),
                           child: isLoading
                               ? const SizedBox(
                                   width: 24,
                                   height: 24,
                                   child: CircularProgressIndicator(
                                     strokeWidth: 2,
                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                   ),
                                 )
                               : const Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Icon(Icons.add_circle, size: 24, color: Colors.white),
                                     SizedBox(width: 8),
                                     Text(
                                       'Create Exercise',
                                       style: TextStyle(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                       ),
                                     ),
                                   ],
                                 ),
                         ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button standardized
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: textColor,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          
          Text(
            'New Custom Task',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(width: 40), // Balance spacer
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF98A2B3), // Neutral gray
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
