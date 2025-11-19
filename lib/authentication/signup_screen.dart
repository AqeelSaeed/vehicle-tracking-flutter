import 'package:android_vehicle_tracking/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Enter a valid name';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    try {
      setState(() {
        _isLoading = true;
      });

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      // Update display name
      await user?.updateDisplayName(fullName);

      // Send email verification
      if (!(user?.emailVerified ?? false)) {
        await user?.sendEmailVerification();
      }

      // 💾 SAVE USER DATA TO FIRESTORE
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created. Verification email sent to $email.',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 6),
        ),
      );

      // Sign out so user must verify email
      await _auth.signOut();

      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication error';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'The email address is already in use.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = e.message ?? message;
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Remove the "Back" TextButton from the build method UI.
  // Wrap the Scaffold with a WillPopScope and connect its onWillPop to this helper
  // so pressing system back (or app bar back) navigates to the previous screen.
  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false; // we've handled the pop
    }
    return true; // allow system default (exit app) when no previous route
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: AppColors.bgColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.fgColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Sign Up',
            style: TextStyle(color: AppColors.fgColor),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Branding or illustration placeholder
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const Text(
                      'Vehicle Tracking',
                      style: TextStyle(
                        color: AppColors.fgColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  TextFormField(
                    controller: _fullNameCtrl,
                    style: const TextStyle(color: AppColors.fgColor),
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      labelStyle: TextStyle(color: AppColors.fgColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                    ),
                    validator: _validateFullName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.fgColor),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: AppColors.fgColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                    ),
                    validator: _validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.fgColor),
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(color: AppColors.fgColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                    ),
                    validator: _validatePhone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.fgColor),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: AppColors.fgColor),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.fgColor),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.fgColor,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: _validatePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fgColor,
                        foregroundColor: AppColors.bgColor,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryWhite,
                              ),
                            )
                          : const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Navigate to login - ensure route exists
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          },
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(color: AppColors.fgColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 24),
                  const Text(
                    'By signing up you agree to the Terms of Service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                  // Optional small footer
                  const Text(
                    '© Virtual University',
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
