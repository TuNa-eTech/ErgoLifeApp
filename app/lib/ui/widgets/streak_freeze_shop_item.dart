import 'package:flutter/material.dart';

/// Shop card for purchasing Streak Freeze
///
/// Visibility: Shows when currentStreak >= 3 AND streakFreezeCount < 2
class StreakFreezeShopItem extends StatefulWidget {
  final int currentStreak;
  final int streakFreezeCount;
  final int walletBalance;
  final VoidCallback onPurchase;

  const StreakFreezeShopItem({
    super.key,
    required this.currentStreak,
    required this.streakFreezeCount,
    required this.walletBalance,
    required this.onPurchase,
  });

  @override
  State<StreakFreezeShopItem> createState() => _StreakFreezeShopItemState();
}

class _StreakFreezeShopItemState extends State<StreakFreezeShopItem> {
  static const int _freezeCost = 500;
  static const int _maxFreezes = 2;
  bool _isPurchasing = false;

  bool get _canBuy =>
      !_isPurchasing &&
      widget.streakFreezeCount < _maxFreezes &&
      widget.walletBalance >= _freezeCost;

  bool get _shouldShow =>
      widget.currentStreak >= 3 && widget.streakFreezeCount < _maxFreezes;

  Future<void> _handlePurchase() async {
    if (!_canBuy) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Streak Freeze?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Protect your streak for 1 missed day'),
            const SizedBox(height: 12),
            Text(
              'Cost: $_freezeCost EP',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Your balance: ${widget.walletBalance} EP',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
            ),
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isPurchasing = true);
      try {
        widget.onPurchase();
      } finally {
        if (mounted) {
          setState(() => _isPurchasing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Streak Freeze',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Protect your streak for 1 day',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You have: ${widget.streakFreezeCount}/$_maxFreezes Freezes',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canBuy ? _handlePurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canBuy
                    ? const Color(0xFFFF6B00)
                    : Colors.grey[300],
                foregroundColor: _canBuy ? Colors.white : Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: _canBuy ? 2 : 0,
              ),
              child: _isPurchasing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _getButtonText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (widget.streakFreezeCount >= _maxFreezes) {
      return 'Max Reached';
    }
    if (widget.walletBalance < _freezeCost) {
      return 'Not Enough Points ($_freezeCost EP)';
    }
    return 'Buy for $_freezeCost EP';
  }
}
