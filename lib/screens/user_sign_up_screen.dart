import 'package:auto_size_text/auto_size_text.dart';
import 'package:btp/configs/size.dart';
import 'package:btp/controllers/dataReader.dart';
import 'package:btp/screens/home_page.dart';
import 'package:btp/widgets/my_textfield.dart';
import 'package:btp/widgets/square_tile.dart';
import 'package:btp/widgets/word_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

class UserSignUpScreen extends StatefulWidget {
  final Function? onTap;
  const UserSignUpScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  State<UserSignUpScreen> createState() => _UserSignUpScreenState();
}

class _UserSignUpScreenState extends State<UserSignUpScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (passwordController.text != confirmPasswordController.text) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('The passwords do not match.'),
              content:
                  Text("Entered password and confirmed password do not match."),
            );
          },
        );
        return;
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
      widget.onTap!();
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
        errorMessage(message: 'The password provided is too weak.');
        return;
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
        errorMessage(message: 'The account already exists for that email.');
        return;
      }

      errorMessage();
    }
  }

  void errorMessage(
      {String message =
          'There is an error signing up. Please try again later.'}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error Signing Up'),
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.offAndToNamed("/home"),
            icon: const Icon(Icons.chevron_left_rounded)),
        backgroundColor: Color.fromARGB(255, 14, 18, 22),
        title: Text("Sign Up"),
      ),
      backgroundColor: Color.fromARGB(255, 6, 6, 8),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      MyTextField(
                        controller: emailController,
                        hintText: "Enter Email",
                        obscureText: false,
                        icon: const Icon(Icons.mail),
                      ),
                      const SizedBox(height: 50 - 20),
                      MyTextField(
                        controller: passwordController,
                        hintText: "Enter Password",
                        obscureText: true,
                        icon: const Icon(Icons.person),
                      ),
                      const SizedBox(height: 50 - 20),
                      MyTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: true,
                        icon: const Icon(Icons.person),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Center(
                  child: GestureDetector(
                    onTap: signUserUp,
                    child: Container(
                      width: getProportionWidth(100),
                      height: getProportionHeight(25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(getProportionHeight(10))),
                        color: Color.fromARGB(255, 40, 137, 186),
                      ),
                      child: Center(
                        child: AutoSizeText(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.publicSans(
                              fontSize: getProportionHeight(16),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: getProportionWidth(40),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: getProportionWidth(100),
                        height: 1,
                        child: Container(
                          color: Colors.grey,
                        )),
                    const Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                        width: getProportionWidth(100),
                        height: 1,
                        child: Container(
                          color: Colors.grey,
                        )),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: 'lib/images/google.png'),
                  ],
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap:
                          widget.onTap != null ? () => widget.onTap!() : null,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
