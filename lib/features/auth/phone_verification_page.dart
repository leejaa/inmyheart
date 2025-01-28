import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupid/features/auth/widgets/verification_header.dart';
import 'package:cupid/features/auth/widgets/phone_input_form.dart';

class PhoneVerificationPage extends ConsumerStatefulWidget {
  const PhoneVerificationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneVerificationPage> createState() =>
      _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends ConsumerState<PhoneVerificationPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const VerificationHeader(),
                  PhoneInputForm(phoneController: _phoneController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
