import 'package:e_commerce_app/feature/authen/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogUpScreen extends StatefulWidget {
  const LogUpScreen({super.key});

  @override
  State<LogUpScreen> createState() => _LogUpScreenState();
}

class _LogUpScreenState extends State<LogUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideRePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _formKey.currentState?.reset();
              _clearForm();
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 56,
                        color: Color(0xFF0F766E),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Tao tai khoan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dang ky de bat dau mua sam',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                      ),
                      const SizedBox(height: 28),
                      _TextInput(
                        controller: _nameController,
                        label: 'Ho ten',
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui long nhap ho ten';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _TextInput(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                          if (!regex.hasMatch(email)) {
                            return 'Email khong hop le';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _TextInput(
                        controller: _phoneController,
                        label: 'So dien thoai',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final phone = value?.trim() ?? '';
                          if (!RegExp(r'^[0-9]{9,12}$').hasMatch(phone)) {
                            return 'So dien thoai khong hop le';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _TextInput(
                        controller: _passwordController,
                        label: 'Mat khau',
                        icon: Icons.lock_outline,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.next,
                        suffixIcon: IconButton(
                          tooltip:
                              _hidePassword ? 'Hien mat khau' : 'An mat khau',
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 6) {
                            return 'Mat khau phai co it nhat 6 ky tu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _TextInput(
                        controller: _rePasswordController,
                        label: 'Nhap lai mat khau',
                        icon: Icons.lock_reset_outlined,
                        obscureText: _hideRePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          tooltip:
                              _hideRePassword ? 'Hien mat khau' : 'An mat khau',
                          onPressed: () {
                            setState(() {
                              _hideRePassword = !_hideRePassword;
                            });
                          },
                          icon: Icon(
                            _hideRePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Mat khau nhap lai khong khop';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Dang ky',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
          LogUpSubmitted(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            rePassword: _rePasswordController.text,
            phone: _phoneController.text,
          ),
        );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _rePasswordController.clear();
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _TextInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
      ),
    );
  }
}
