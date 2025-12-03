import 'package:family_home/src/app_config/app_styles.dart';
import 'package:family_home/src/app_utils/read_write.dart';
import 'package:family_home/src/view/home_page.dart';
import 'package:family_home/src/widget/custom_button.dart';
import 'package:family_home/src/widget/custom_textformfield.dart';
import 'package:family_home/src/widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  RxBool isLoginLoading = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  //auth controller
  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    try {
      isLoginLoading(true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      write("token", _emailController.text.trim());

      // Login successful - navigate to home
      if (!mounted) return;
      Get.offAll(() => HomePage());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      }
      
     showErrorToast(errorMessage);
    } catch (e) {
      if (!mounted) return;
      showErrorToast('An error occurred: $e');
    } finally {
      isLoginLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome!',
                  style: interBold(
                    size: 28.sp,
                    color: txtBlack
                  )
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                loginCreds(),
                const SizedBox(height: 30),

                // Login Button
                loginButton(),
               
                const SizedBox(height: 20),

               ],
            ),
          ),
        ),
      ),
    );
  }

  //login credentials
  loginCreds(){
    return Form(
      key: _formKey,
      child: Column(
        children: [

          CustomTextFormField(
            controller: _emailController,
            headingText: "Email",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          CustomTextFormField(
            controller: _passwordController,
            headingText: "Password",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  loginButton(){
  return SizedBox(
    width: double.infinity,
    height: 50.h,
    child: isLoginLoading.isTrue
        ? const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: darkBlue,
              ),
            ),
          )
        : CustomButton(
            color: darkBlue, 
            text: "Login", 
            onTap: _login,
            height: 50.h, 
            width: 300.w,
          ),
    );
  }

}