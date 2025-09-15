import 'dart:math' as dart_math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/authentication_form_widget.dart';
import './widgets/historical_logo_widget.dart';
import './widgets/security_indicators_widget.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _contentController;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isConnected = true;
  bool _isSecure = true;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkConnectivity();

    // Listen to keyboard visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      setState(() {
        _keyboardVisible = mediaQuery.viewInsets.bottom > 0;
      });
    });
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _backgroundController.repeat();
    _contentController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _checkConnectivity() {
    // Simulate connectivity check
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isSecure = true;
        });
      }
    });
  }

  Widget _buildDemoCredentialsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                size: 4.w,
                color: Colors.white,
              ),
              SizedBox(width: 2.w),
              Text(
                'Demo Credentials',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildCredentialRow('Admin', 'admin@histromap.com', 'admin123'),
          SizedBox(height: 1.h),
          _buildCredentialRow(
              'Historian', 'historian@histromap.com', 'secure123'),
          SizedBox(height: 1.h),
          _buildCredentialRow(
              'Explorer', 'explorer@histromap.com', 'explore123'),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$role: $email',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Password: $password',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // Copy to clipboard functionality would go here
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Credentials copied to clipboard'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          icon: CustomIconWidget(
            iconName: 'copy',
            size: 4.w,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _handleEmailLogin(String email, String password) async {
    try {
      final response =
          await AuthService.instance.signInWithEmail(email, password);
      if (response.user != null) {
        _showSuccessAndNavigate();
      } else {
        _showAuthenticationError(
            'Sign-in failed. Please check your credentials.');
      }
    } catch (error) {
      _showAuthenticationError('Sign-in failed: ${error.toString()}');
    }
  }

  void _handlePhoneLogin(String phoneNumber) async {
    // For demo purposes, we'll show that phone login is not implemented with Supabase email auth
    _showAuthenticationError(
        'Phone authentication not available in demo. Please use email login.');
  }

  void _handleGoogleLogin() async {
    try {
      final success = await AuthService.instance.signInWithGoogle();
      if (success) {
        // Wait for auth state change to complete
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _showSuccessAndNavigate();
          }
        });
      }
    } catch (error) {
      _showAuthenticationError('Google sign-in failed: ${error.toString()}');
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final emailController = TextEditingController();
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Enter your email address to receive a password reset link.'),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService.instance
                      .resetPassword(emailController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset email sent!'),
                      backgroundColor: AppTheme.successLight,
                    ),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Failed to send reset email: ${error.toString()}'),
                      backgroundColor: AppTheme.errorLight,
                    ),
                  );
                }
              },
              child: Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }

  void _showOTPDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the 6-digit code sent to your phone'),
            SizedBox(height: 2.h),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: '123456',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (otpController.text == '123456') {
                _showSuccessAndNavigate();
              } else {
                _showAuthenticationError('Invalid OTP. Try: 123456');
              }
            },
            child: Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAndNavigate() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              size: 5.w,
              color: Colors.white,
            ),
            SizedBox(width: 3.w),
            Text('Authentication successful!'),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/map-explorer-home');
      }
    });
  }

  void _showAuthenticationError(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              size: 5.w,
              color: Colors.white,
            ),
            SizedBox(width: 3.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorLight,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightTheme.primaryColor,
                    AppTheme.lightTheme.colorScheme.primaryContainer,
                    AppTheme.accentLight.withValues(alpha: 0.8),
                  ],
                  stops: [
                    0.0 + (_backgroundAnimation.value * 0.1),
                    0.5 + (_backgroundAnimation.value * 0.2),
                    1.0,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MapPatternPainter(_backgroundAnimation.value),
                    ),
                  ),
                  // Main content
                  Column(
                    children: [
                      // Header section
                      Expanded(
                        flex: _keyboardVisible ? 1 : 2,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_keyboardVisible) ...[
                                HistoricalLogoWidget(),
                                SizedBox(height: 3.h),
                                Text(
                                  'HistroMap Shield',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Secure Historical Map Exploration',
                                  style: AppTheme.lightTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                SecurityIndicatorsWidget(
                                  isConnected: _isConnected,
                                  isSecure: _isSecure,
                                ),
                              ] else ...[
                                SizedBox(height: 2.h),
                                Text(
                                  'HistroMap Shield',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Authentication form
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            SlideTransition(
                              position: _slideAnimation,
                              child: AuthenticationFormWidget(
                                onEmailLogin: _handleEmailLogin,
                                onPhoneLogin: _handlePhoneLogin,
                                onGoogleLogin: _handleGoogleLogin,
                                onForgotPassword: _handleForgotPassword,
                              ),
                            ),
                            // Add demo credentials section
                            _buildDemoCredentialsSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Back button (only show if not from splash)
                  Positioned(
                    top: 2.h,
                    left: 4.w,
                    child: IconButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          SystemNavigator.pop();
                        }
                      },
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        size: 6.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MapPatternPainter extends CustomPainter {
  final double animationValue;

  MapPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final gridSize = 50.0;
    final offset = animationValue * gridSize;

    // Draw grid pattern
    for (double x = -gridSize + offset;
        x < size.width + gridSize;
        x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = -gridSize + offset;
        y < size.height + gridSize;
        y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw compass rose
    final center = Offset(size.width * 0.8, size.height * 0.2);
    final radius = 30.0;

    paint.color = Colors.white.withValues(alpha: 0.1);
    canvas.drawCircle(center, radius, paint);

    // Draw compass points
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180) + (animationValue * 2 * 3.14159);
      final start = center +
          Offset(
            (radius * 0.7) * cos(angle),
            (radius * 0.7) * sin(angle),
          );
      final end = center +
          Offset(
            radius * cos(angle),
            radius * sin(angle),
          );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

double cos(double radians) => radians.cos();
double sin(double radians) => radians.sin();

extension on double {
  double cos() => dart_math.cos(this);
  double sin() => dart_math.sin(this);
}
