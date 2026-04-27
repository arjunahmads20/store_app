import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/src/core/theme/app_theme.dart';
import 'package:store_app/src/features/membership/presentation/membership_controller.dart';
import 'package:store_app/src/features/membership/domain/membership.dart';

class MembershipInformationDetailScreen extends ConsumerStatefulWidget {
  final int? initialMembershipId;

  const MembershipInformationDetailScreen({
    super.key,
    this.initialMembershipId,
  });

  @override
  ConsumerState<MembershipInformationDetailScreen> createState() =>
      _MembershipInformationDetailScreenState();
}

class _MembershipInformationDetailScreenState
    extends ConsumerState<MembershipInformationDetailScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membershipControllerProvider);
    final memberships = state.memberships;

    // Handle initial load or empty state
    if (state.isLoading) {
      return const Scaffold(
        body: SafeArea(
          bottom: true,
          top: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (memberships.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Membership Details")),
        body: SafeArea(
          bottom: true,
          top: false,
          child: const Center(
            child: Text("No membership information available."),
          ),
        ),
      );
    }

    // Set initial index only once
    if (_pageController.hasClients == false) {
      int initialIndex = 0;
      if (widget.initialMembershipId != null) {
        initialIndex = memberships.indexWhere(
          (m) => m.id == widget.initialMembershipId,
        );
        if (initialIndex == -1) initialIndex = 0;
      } else if (state.userMembership != null) {
        initialIndex = memberships.indexWhere(
          (m) => m.id == state.userMembership!.membership,
        );
        if (initialIndex == -1) initialIndex = 0;
      }
      _currentIndex = initialIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(initialIndex);
        }
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Membership Information",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 100), // Spacing for AppBar
              // Carousel
              SizedBox(
                height: 450,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: memberships.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final membership = memberships[index];
                    final isCurrent =
                        index == _currentIndex; // For animations if needed

                    // Simple scale effect
                    return AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: isCurrent ? 1.0 : 0.9,
                      child: _buildMembershipCard(membership),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Navigation Arrows (Optional, as PageView handles swipe, but requested)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: _currentIndex > 0
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: _currentIndex < memberships.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : null,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: _currentIndex < memberships.length - 1
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipCard(Membership membership) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Image (Icon for now)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 32),

          // Name
          Text(
            membership.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Points Required
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Min. ${membership.minPointEarned} Points",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Description
          Text(
            membership.description ?? "No description available.",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
