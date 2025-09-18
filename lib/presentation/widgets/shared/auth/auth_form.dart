import 'package:flutter/material.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.emailController,
    required this.passwordController,
    this.confirmPasswordController,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email address', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'john@example.com',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 20),
        Text('Password', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        if (!widget.isLogin) ...[
          const SizedBox(height: 20),
          Text('Confirm Password', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.confirmPasswordController!,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
          ),
        ],
         if (widget.isLogin)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: false, 
                      onChanged: (val) {},
                      activeColor: AppTheme.primaryColor
                    ),
                    Text('Remember me', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not implemented yet.')),
                    );
                  },
                  child: Text(
                    'Forgot your password?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor),
                  ),
                )
              ],
            ),
          )
      ],
    );
  }
}