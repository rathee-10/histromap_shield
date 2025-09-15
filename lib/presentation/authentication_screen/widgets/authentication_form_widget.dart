import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AuthenticationFormWidget extends StatefulWidget {
  final Function(String email, String password) onEmailLogin;
  final Function(String phoneNumber) onPhoneLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;

  const AuthenticationFormWidget({
    Key? key,
    required this.onEmailLogin,
    required this.onPhoneLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  State<AuthenticationFormWidget> createState() =>
      _AuthenticationFormWidgetState();
}

class _AuthenticationFormWidgetState extends State<AuthenticationFormWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedCountryCode = '+1';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+86', 'country': 'CN'},
    {'code': '+49', 'country': 'DE'},
    {'code': '+33', 'country': 'FR'},
    {'code': '+81', 'country': 'JP'},
    {'code': '+61', 'country': 'AU'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  void _handleEmailLogin() {
    if (_emailFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();
      widget.onEmailLogin(_emailController.text, _passwordController.text);
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  void _handlePhoneLogin() {
    if (_phoneFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();
      widget.onPhoneLogin('$_selectedCountryCode${_phoneController.text}');
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  void _handleGoogleLogin() {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    widget.onGoogleLogin();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 12.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
          elevation: 2,
          side: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 5.h,
                width: 5.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.primaryColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImageWidget(
                    imageUrl:
                        'https://developers.google.com/identity/images/g-logo.png',
                    width: 6.w,
                    height: 6.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Continue with Google',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            SizedBox(height: 3.h),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _handleEmailLogin(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                  icon: CustomIconWidget(
                    iconName:
                        _isPasswordVisible ? 'visibility_off' : 'visibility',
                    size: 5.w,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              height: 12.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailLogin,
                child: _isLoading
                    ? SizedBox(
                        height: 5.h,
                        width: 5.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Sign In',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  width: 25.w,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountryCode,
                    decoration: InputDecoration(
                      labelText: 'Code',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
                    ),
                    items: _countryCodes.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['code'],
                        child: Text(
                          '${country['code']} ${country['country']}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedCountryCode = value!);
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: _validatePhone,
                    onFieldSubmitted: (_) => _handlePhoneLogin(),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'phone',
                          size: 5.w,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 12.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePhoneLogin,
                child: _isLoading
                    ? SizedBox(
                        height: 5.h,
                        width: 5.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Send OTP',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'We\'ll send you a verification code via SMS',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 2.h),
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          _buildGoogleSignInButton(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    'or',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'email',
                        size: 4.w,
                        color: _tabController.index == 0
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 2.w),
                      Text('Email', style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'phone',
                        size: 4.w,
                        color: _tabController.index == 1
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 2.w),
                      Text('Phone', style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'fingerprint',
                        size: 4.w,
                        color: _tabController.index == 2
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 2.w),
                      Text('Bio', style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50.h,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmailForm(),
                _buildPhoneForm(),
                _buildBiometricForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'fingerprint',
                size: 10.w,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Biometric Authentication',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Use your fingerprint or face to sign in securely',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            height: 12.h,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() => _isLoading = true);
                      HapticFeedback.lightImpact();
                      // Simulate biometric authentication
                      Future.delayed(Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Biometric authentication not set up'),
                              backgroundColor: AppTheme.warningLight,
                            ),
                          );
                        }
                      });
                    },
              child: _isLoading
                  ? SizedBox(
                      height: 5.h,
                      width: 5.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'fingerprint',
                          size: 5.w,
                          color: Colors.white,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Authenticate',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}