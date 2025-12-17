import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _rewardController = TextEditingController();

  IconData _selectedIcon = Icons.fitness_center;

  final List<IconData> _availableIcons = [
    Icons.fitness_center,
    Icons.local_laundry_service,
    Icons.shopping_cart,
    Icons.cleaning_services, // Matches 'mop' roughly
    Icons.add,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.water_drop,
    Icons.kitchen,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 120,
            ), // Padding for fixed button
            child: Column(
              children: [
                _buildHeader(context, isDark),
                _buildFormContent(context, isDark),
              ],
            ),
          ),

          // Fixed Bottom Button with Gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24).copyWith(bottom: 32),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.2],
                  colors: [
                    (isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight)
                        .withValues(alpha: 0.0),
                    (isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight),
                  ],
                ),
              ),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement task creation logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle_outline, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Create Exercise',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
                size: 20,
              ),
            ),
          ),
          // Title
          Text(
            'New Custom Task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          // Placeholder for spacing
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Title
          Text(
            'Create your\nexercise. 🏋️',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Turn your daily chores into a workout challenge.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
          const SizedBox(height: 32),

          // Exercise Name Input
          _buildInputLabel(isDark, 'EXERCISE NAME'),
          _buildInputField(
            context,
            isDark: isDark,
            controller: _nameController,
            placeholder: 'e.g. Vacuum Lunges',
            icon: Icons.fitness_center,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 24),

          // Real Life Task Input
          _buildInputLabel(isDark, 'REAL LIFE TASK'),
          _buildInputField(
            context,
            isDark: isDark,
            controller: _descController,
            placeholder: 'e.g. Vacuuming living room',
            icon: Icons.cleaning_services,
            iconColor: AppColors.purple,
          ),
          const SizedBox(height: 24),

          // Duration & Reward Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(isDark, 'DURATION'),
                    _buildNumberInput(
                      context,
                      isDark: isDark,
                      controller: _durationController,
                      placeholder: '20',
                      suffix: 'min',
                      textColor: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(isDark, 'REWARD'),
                    _buildNumberInput(
                      context,
                      isDark: isDark,
                      controller: _rewardController,
                      placeholder: '150',
                      suffix: 'EP',
                      textColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Icon Selection
          _buildInputLabel(isDark, 'CHOOSE ICON'),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _availableIcons.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.textSubDark
                                : AppColors.textSubLight),
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(bool isDark, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required bool isDark,
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
              decoration: InputDecoration.collapsed(
                hintText: placeholder,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(
    BuildContext context, {
    required bool isDark,
    required TextEditingController controller,
    required String placeholder,
    required String suffix,
    required Color textColor,
  }) {
    return Container(
      height: 100, // Match visual height roughly
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.0,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Text(
                suffix,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
