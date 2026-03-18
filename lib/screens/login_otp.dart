import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase

import '../core/app_router.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  final _apiService = ApiService();
  final _sessionService = SessionService();

  bool _isLoading = false;
  bool _otpSent = false;
  String _verificationId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }


  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số điện thoại hợp lệ')));
      return;
    }

    setState(() => _isLoading = true);


    String internationalPhone = phone;
    if (phone.startsWith('0')) {
      internationalPhone = '+84${phone.substring(1)}';
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: internationalPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInAndSendToServer(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Lỗi gửi SMS')));
      },
      codeSent: (String verificationId, int? resendToken) {
        // Thành công: Chuyển sang màn hình nhập OTP
        setState(() {
          _isLoading = false;
          _otpSent = true;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await _signInAndSendToServer(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã OTP không chính xác')));
    }
  }

  Future<void> _signInAndSendToServer(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) throw Exception("Không lấy được Token từ Google");

      final authResponse = await _apiService.loginWithFirebase(idToken: idToken);
      await _sessionService.saveAuthSession(authResponse);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 92, height: 92,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
                child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 44),
              ),
              const SizedBox(height: 16),
              const Text(
                AppConstants.schoolName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 40),

              // ================= UI NHẬP SỐ ĐIỆN THOẠI =================
              if (!_otpSent) ...[
                const Text('Số điện thoại đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'VD: 0912345678', prefixIcon: Icon(Icons.phone_android)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Gửi mã OTP'),
                ),
              ]
              // ================= UI NHẬP MÃ OTP =================
              else ...[
                Text('Nhập mã 6 số gửi đến ${_phoneController.text}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: '------', counterText: ''),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Xác nhận & Đăng nhập'),
                ),
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text('Đổi số điện thoại khác', style: TextStyle(color: AppColors.textLight)),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}