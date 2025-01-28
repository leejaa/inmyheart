import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cupid/core/models/country_code.dart';
import 'package:cupid/core/services/auth_service.dart';

class PhoneInputForm extends ConsumerStatefulWidget {
  const PhoneInputForm({
    super.key,
    required this.phoneController,
  });

  final TextEditingController phoneController;

  @override
  ConsumerState<PhoneInputForm> createState() => _PhoneInputFormState();
}

class _PhoneInputFormState extends ConsumerState<PhoneInputForm> {
  CountryCode _selectedCountry = CountryCode.countries[0];
  bool _isLoading = false;
  bool _isValidPhoneNumber = false;

  void _validatePhoneNumber(String value) {
    setState(() {
      _isValidPhoneNumber = value.length >= 10 && value.length <= 11;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.phoneController.addListener(() {
      _validatePhoneNumber(widget.phoneController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              PopupMenuButton<CountryCode>(
                initialValue: _selectedCountry,
                onSelected: (CountryCode country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return CountryCode.countries.map((CountryCode country) {
                    return PopupMenuItem<CountryCode>(
                      value: country,
                      child: Row(
                        children: [
                          Text(country.flag),
                          const SizedBox(width: 8),
                          Text(country.name),
                          const SizedBox(width: 8),
                          Text('+${country.code}'),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Text(_selectedCountry.flag),
                      const SizedBox(width: 4),
                      Text(
                        '+${_selectedCountry.code}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.grey[300],
              ),
              Expanded(
                child: TextField(
                  controller: widget.phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '휴대폰 번호',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: !_isValidPhoneNumber
              ? null
              : () async {
                  final phoneNumber = widget.phoneController.text;
                  final fullPhoneNumber =
                      '+${_selectedCountry.code}$phoneNumber';

                  setState(() {
                    _isLoading = true;
                  });
                  FocusScope.of(context).unfocus();

                  final authService = AuthService();
                  try {
                    final result =
                        await authService.sendVerificationCode(fullPhoneNumber);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] ?? '인증번호가 발송되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.push('/auth/verification', extra: {
                        'phoneNumber': fullPhoneNumber,
                      });
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[500],
          ),
          child: SizedBox(
            width: double.infinity,
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                      ),
                    ),
                  )
                : const Text(
                    '인증번호 발송',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(() {
      _validatePhoneNumber(widget.phoneController.text);
    });
    super.dispose();
  }
}
