import 'package:flutter/material.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:circular_gradient_spinner/circular_gradient_spinner.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularGradientSpinner(
            color: AppTheme.primaryColor,
            size: 60.0,
            strokeWidth: 8,
            spinnerDirection: SpinnerDirection.clockwise,
            duration: Duration(seconds: 2),
            gradientSteps: 20,
          )
        ),
      );
    },
  );
}