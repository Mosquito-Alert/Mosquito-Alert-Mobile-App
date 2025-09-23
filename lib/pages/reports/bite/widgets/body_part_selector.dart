import 'package:flutter/material.dart';

/// Widget for selecting bite counts on different body parts
class BodyPartSelector extends StatelessWidget {
  final int headCount;
  final int leftArmCount;
  final int rightArmCount;
  final int chestCount;
  final int leftLegCount;
  final int rightLegCount;
  final Function({
    int? head,
    int? leftArm,
    int? rightArm,
    int? chest,
    int? leftLeg,
    int? rightLeg,
  }) onCountChanged;

  const BodyPartSelector({
    Key? key,
    required this.headCount,
    required this.leftArmCount,
    required this.rightArmCount,
    required this.chestCount,
    required this.leftLegCount,
    required this.rightLegCount,
    required this.onCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Head
        _buildBodyPartCounter(
          context,
          '(HC) Head',
          headCount,
          (value) => onCountChanged(head: value),
          Icons.face,
        ),

        SizedBox(height: 16),

        // Arms row
        Row(
          children: [
            Expanded(
              child: _buildBodyPartCounter(
                context,
                '(HC) Left Arm',
                leftArmCount,
                (value) => onCountChanged(leftArm: value),
                Icons.pan_tool,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildBodyPartCounter(
                context,
                '(HC) Right Arm',
                rightArmCount,
                (value) => onCountChanged(rightArm: value),
                Icons.pan_tool,
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Chest
        _buildBodyPartCounter(
          context,
          '(HC) Chest/Torso',
          chestCount,
          (value) => onCountChanged(chest: value),
          Icons.accessibility_new,
        ),

        SizedBox(height: 16),

        // Legs row
        Row(
          children: [
            Expanded(
              child: _buildBodyPartCounter(
                context,
                '(HC) Left Leg',
                leftLegCount,
                (value) => onCountChanged(leftLeg: value),
                Icons.directions_walk,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildBodyPartCounter(
                context,
                '(HC) Right Leg',
                rightLegCount,
                (value) => onCountChanged(rightLeg: value),
                Icons.directions_walk,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyPartCounter(
    BuildContext context,
    String label,
    int count,
    Function(int) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Icon and label
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Counter controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrease button
              IconButton(
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
                icon: Icon(Icons.remove_circle_outline),
                iconSize: 32,
                color: count > 0 ? Theme.of(context).primaryColor : Colors.grey,
              ),

              // Count display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: count > 0
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: count > 0
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                ),
              ),

              // Increase button
              IconButton(
                onPressed: count < 50
                    ? () => onChanged(count + 1)
                    : null, // Max 50 bites per body part
                icon: Icon(Icons.add_circle_outline),
                iconSize: 32,
                color:
                    count < 50 ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
