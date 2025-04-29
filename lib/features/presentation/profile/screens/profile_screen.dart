import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants/app_strings.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../controller/profile_provider.dart';
import '../widgets/profile_counters_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_menu_items_widget.dart';
import '../widgets/shimmer/profile_counters_shimmer.dart';
import '../widgets/shimmer/profile_header_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.getUserProfile();
      profileProvider.getProfileCounters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final counters = profileProvider.profileCounters;
    final isLoggedIn = AppStrings.token != null;
    final isLoadingProfile =
        profileProvider.profileState == LoadingState.loading;
    final isLoadingCounters =
        profileProvider.countersState == LoadingState.loading;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            isLoadingProfile
                ? const ProfileHeaderShimmer()
                : const ProfileHeaderWidget(),
            if (isLoggedIn)
              const SizedBox(height: 16),
            // Counters Section
            if (isLoggedIn)
              isLoadingCounters || counters == null
                  ? const ProfileCountersShimmer()
                  : ProfileCountersWidget(counters: counters),
            if (isLoggedIn)
              const SizedBox(height: 24),
            const ProfileMenuItemsWidget(),
          ],
        ),
      ),
    );
  }
}
