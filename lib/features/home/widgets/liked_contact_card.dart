import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cupid/core/providers/liked_contact_provider.dart';
import 'package:cupid/features/home/widgets/contact_card.dart';

class LikedContactCard extends ConsumerWidget {
  const LikedContactCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedContactAsync = ref.watch(likedContactProvider);

    return likedContactAsync.when(
      data: (likedContact) {
        if (likedContact == null) return const SizedBox.shrink();
        return Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: ContactCard(contact: likedContact),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
