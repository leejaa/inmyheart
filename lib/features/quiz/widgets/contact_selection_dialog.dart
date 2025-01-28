import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactSelectionDialog extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onContactSelected;

  const ContactSelectionDialog({
    super.key,
    required this.contacts,
    required this.onContactSelected,
  });

  @override
  State<ContactSelectionDialog> createState() => _ContactSelectionDialogState();
}

class _ContactSelectionDialogState extends State<ContactSelectionDialog> {
  List<Contact>? _contacts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await ContactsService.getContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading contacts: $e');
      if (mounted) {
        setState(() {
          _contacts = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Text(
              '연락처 선택',
              style: TextStyle(
                color: const Color(0xFF2B2F4A),
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF4D8D),
                      ),
                    ),
                  )
                : _contacts == null || _contacts!.isEmpty
                    ? Center(
                        child: Text(
                          '연락처가 없습니다.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contacts!.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts![index];
                          if (contact.phones == null ||
                              contact.phones!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFFF6F9),
                              child: Text(
                                (contact.displayName?.isNotEmpty == true)
                                    ? contact.displayName!.substring(0, 1)
                                    : '?',
                                style: TextStyle(
                                  color: const Color(0xFFFF4D8D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.displayName ?? '이름 없음',
                              style: TextStyle(
                                color: const Color(0xFF2B2F4A),
                                fontSize: 16.sp,
                              ),
                            ),
                            subtitle: Text(
                              contact.phones?.first.value
                                      ?.replaceAll(RegExp(r'[^\d+]'), '') ??
                                  '번호 없음',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                            onTap: () => widget.onContactSelected(contact),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
