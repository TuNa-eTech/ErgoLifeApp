import 'package:flutter/material.dart';
import 'package:ergo_life_app/core/config/theme_config.dart';

/// Bottom sheet for creating an arena/house
class ArenaBottomSheet extends StatefulWidget {
  final TextEditingController houseNameController;
  final FocusNode houseNameFocusNode;
  final bool isHouseNameValid;
  final VoidCallback onCreateArena;

  const ArenaBottomSheet({
    super.key,
    required this.houseNameController,
    required this.houseNameFocusNode,
    required this.isHouseNameValid,
    required this.onCreateArena,
  });

  @override
  State<ArenaBottomSheet> createState() => _ArenaBottomSheetState();
}

class _ArenaBottomSheetState extends State<ArenaBottomSheet> {
  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        final nameOnly = text
            .split(' ')
            .sublist(0, text.split(' ').length - 1)
            .join(' ');
        widget.houseNameController.text = nameOnly;
      },
      child: Chip(
        label: Text(text),
        backgroundColor: const Color(0xFFFFE5CC),
        labelStyle: const TextStyle(
          color: Color(0xFFFF6A00),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Trophy icon
            const Text('🏆', style: TextStyle(fontSize: 80)),

            const SizedBox(height: 24),

            // Title
            Text(
              'Create Your Arena',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Give your family competition a name!',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 32),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.houseNameFocusNode.hasFocus
                        ? const Color(0xFFFF6A00)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: widget.houseNameController,
                  focusNode: widget.houseNameFocusNode,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. "Nhà Warriors" 💪',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Suggestion chips
            Wrap(
              spacing: 8,
              children: [
                _buildSuggestionChip('Team Alpha 🚀'),
                _buildSuggestionChip('The Champions 🏆'),
                _buildSuggestionChip('Fitness Crew 💪'),
              ],
            ),

            const Spacer(),

            // Submit button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.isHouseNameValid
                      ? widget.onCreateArena
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Arena',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
