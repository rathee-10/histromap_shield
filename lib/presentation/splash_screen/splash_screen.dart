import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _loadingAnimation;

  bool _isInitializing = true;
  String _loadingText = "Initializing secure services...";
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Loading indicator animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize encryption services
      await _updateLoadingProgress(0.2, "Initializing encryption services...");
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Load map index
      await _updateLoadingProgress(0.4, "Loading map collections...");
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 3: Check authentication status
      await _updateLoadingProgress(0.6, "Verifying authentication...");
      await Future.delayed(const Duration(milliseconds: 400));

      // Step 4: Prepare offline data
      await _updateLoadingProgress(0.8, "Preparing offline maps...");
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Complete initialization
      await _updateLoadingProgress(1.0, "Ready to explore history...");
      await Future.delayed(const Duration(milliseconds: 300));

      // Determine navigation route based on user status
      await _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      await _handleInitializationError();
    }
  }

  Future<void> _updateLoadingProgress(double progress, String text) async {
    if (mounted) {
      setState(() {
        _loadingProgress = progress;
        _loadingText = text;
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate authentication check
    final bool isAuthenticated = await _checkAuthenticationStatus();
    final bool isFirstTime = await _checkFirstTimeUser();

    if (mounted) {
      // Add a small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (isFirstTime) {
        // New users see onboarding (redirect to authentication for now)
        Navigator.pushReplacementNamed(context, '/authentication-screen');
      } else if (isAuthenticated) {
        // Authenticated users go to map explorer
        Navigator.pushReplacementNamed(context, '/map-explorer-home');
      } else {
        // Returning non-authenticated users see login
        Navigator.pushReplacementNamed(context, '/authentication-screen');
      }
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    // Simulate checking stored authentication tokens
    await Future.delayed(const Duration(milliseconds: 200));
    // For demo purposes, return false to show authentication flow
    return false;
  }

  Future<bool> _checkFirstTimeUser() async {
    // Simulate checking if user has used the app before
    await Future.delayed(const Duration(milliseconds: 100));
    // For demo purposes, return true to show onboarding flow
    return true;
  }

  Future<void> _handleInitializationError() async {
    if (mounted) {
      setState(() {
        _loadingText = "Offline mode available";
        _loadingProgress = 1.0;
      });

      await Future.delayed(const Duration(seconds: 2));

      // Navigate to offline mode or show error recovery options
      Navigator.pushReplacementNamed(context, '/map-explorer-home');
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.primaryContainer,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section with animation
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: _buildAppLogo(),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading section
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading progress indicator
                      _buildLoadingIndicator(),

                      SizedBox(height: 3.h),

                      // Loading text
                      _buildLoadingText(),
                    ],
                  ),
                ),
              ),

              // Bottom spacing
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 35.w,
      height: 35.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Compass icon representing historical navigation
          CustomIconWidget(
            iconName: 'explore',
            color: AppTheme.lightTheme.colorScheme.surface,
            size: 12.w,
          ),

          SizedBox(height: 1.h),

          // App name
          Text(
            'HistroMap',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),

          Text(
            'Shield',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.8),
              fontSize: 12.sp,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        // Custom loading progress bar
        Container(
          width: 60.w,
          height: 0.5.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              // Progress fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60.w * _loadingProgress,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentLight.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

              // Animated shimmer effect
              if (_isInitializing)
                AnimatedBuilder(
                  animation: _loadingAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: (60.w * _loadingAnimation.value) - 20,
                      child: Container(
                        width: 20,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.lightTheme.colorScheme.surface
                                  .withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        SizedBox(height: 1.h),

        // Progress percentage
        Text(
          '${(_loadingProgress * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.7),
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
          fontSize: 12.sp,
          height: 1.4,
        ),
      ),
    );
  }
}
