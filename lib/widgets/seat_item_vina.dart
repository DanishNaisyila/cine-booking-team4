import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SeatItemVina extends StatelessWidget {
  final String seatId;
  final bool isSold;
  final bool isSelected;
  final VoidCallback? onTap;

  const SeatItemVina({
    super.key,
    required this.seatId,
    required this.isSold,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (isSold) return AppColors.seatSold;      // Red for booked
      if (isSelected) return AppColors.seatSelected; // Blue for selected
      return AppColors.seatAvailable;              // Grey for available
    }

    Color getTextColor() {
      if (isSold) return Colors.white;
      if (isSelected) return Colors.white;
      return Colors.white; // White text on grey background
    }

    return GestureDetector(
      onTap: isSold ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: getColor(),
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Center(
          child: Text(
            seatId,
            style: TextStyle(
              color: getTextColor(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}