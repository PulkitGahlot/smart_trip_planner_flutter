import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:itinerary_ai/core/theme/app_theme.dart';
import 'package:itinerary_ai/presentation/providers/auth_provider.dart';
import 'package:itinerary_ai/presentation/widgets/shared/auth/auth_form.dart';
import 'package:itinerary_ai/presentation/widgets/shared/auth/google_auth_button.dart';
import 'package:itinerary_ai/presentation/widgets/shared/loading_dialog.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _handleSignUp() {
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all the fields.')),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return;
      }
      showLoadingDialog(context);
      ref.read(authProvider.notifier)
          .signUp(context, _emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/app_icon/itinerary_ai_icon.png",
                    fit: BoxFit.cover,
                    width: 42,
                    height: 42,
                  ),
                  Text(
                    'Itinera AI', 
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Create your Account', 
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center
              ),
              SizedBox(
                height: 14,
              ),
              Text(
                'Lets get started', 
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey[500]!.withOpacity(0.8),
                  fontWeight: FontWeight.bold
                ), 
                textAlign: TextAlign.center
              ),
              const SizedBox(height: 40),
              const GoogleAuthButton(text: 'Sign up with Google'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.5,)),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'or Sign up with Email', 
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.grey[500]!.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ), 
                    textAlign: TextAlign.center
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(child: Divider(color:Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              AuthForm(
                isLogin: false,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
                ),
                child: const Text('Sign UP'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?", style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}