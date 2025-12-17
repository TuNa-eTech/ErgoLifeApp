import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';
import 'package:go_router/go_router.dart';

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
    Icons.cleaning_services,
    Icons.add_circle,
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
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.textMainLight;

    return Scaffold(
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

                        _buildLabel('REAL LIFE TASK'),
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
                                  _buildLabel('REWARD'),
                                  TextField(
                                    controller: _rewardController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '150',
                                      suffixText: 'EP',
                                      suffixStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

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
                                      color: isSelected ? AppColors.primary : Colors.transparent, // Border mainly for layout stability
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
                child: SizedBox(
                   height: 56,
                   child: ElevatedButton(
                     onPressed: () {
                       // Create logic
                       context.pop();
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.secondary,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(30),
                       ),
                       elevation: 8,
                       shadowColor: AppColors.secondary.withOpacity(0.4),
                     ),
                     child: const Row(
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
                ),
              ),
            ),
          ],
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
