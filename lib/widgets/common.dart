import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/app_models.dart';

class ElimuBackground extends StatelessWidget {
  const ElimuBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.mint, Color(0xFFE8FADB), AppColors.lime],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: 32,
          right: -48,
          child: Opacity(
            opacity: 0.055,
            child: Transform.rotate(
              angle: -0.22,
              child: const BrandMark(
                size: 260,
                variant: BrandLogoVariant.black,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.leafLight.withValues(alpha: 0.24),
                  AppColors.leafLight.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ElimuPage extends StatelessWidget {
  const ElimuPage({
    required this.child,
    this.bottomNavigation,
    this.padding = const EdgeInsets.fromLTRB(24, 16, 24, 24),
    this.scrollable = true,
    super.key,
  });

  final Widget child;
  final Widget? bottomNavigation;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ElimuBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Expanded(
                      child: scrollable
                          ? SingleChildScrollView(
                              padding: padding,
                              physics: const BouncingScrollPhysics(),
                              child: child,
                            )
                          : Padding(padding: padding, child: child),
                    ),
                    if (bottomNavigation != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: bottomNavigation,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({
    this.size = 38,
    this.variant = BrandLogoVariant.gradient,
    super.key,
  });

  final double size;
  final BrandLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.792,
      child: Image.asset(
        variant.assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'ElimuPath logo',
      ),
    );
  }
}

enum BrandLogoVariant {
  black('assets/images/brand-black.png'),
  lime('assets/images/brand-lime.png'),
  teal('assets/images/brand-teal.png'),
  gradient('assets/images/brand-gradient.png'),
  white('assets/images/brand-white.png');

  const BrandLogoVariant(this.assetPath);

  final String assetPath;
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: compact ? 28 : 38),
        SizedBox(width: compact ? 8 : 12),
        Text(
          'ELIMUPATH',
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.trailing = HeaderTrailing.menu,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final HeaderTrailing trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandLockup(),
            const Spacer(),
            if (trailing == HeaderTrailing.back)
              CircleIconButton(
                icon: Icons.arrow_forward_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
            if (trailing == HeaderTrailing.menu ||
                trailing == HeaderTrailing.account)
              CircleIconButton(
                icon: Icons.person_outline_rounded,
                onTap: () => Navigator.pushNamed(context, AppRoutes.account),
              ),
          ],
        ),
        const SizedBox(height: 34),
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: const TextStyle(
              color: Color(0xFF51B78C),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 39,
                  height: 1,
                  letterSpacing: -1.8,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            if (trailing == HeaderTrailing.menu) ...[
              const SizedBox(width: 12),
              const AppMenuButton(),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ],
    );
  }
}

enum HeaderTrailing { menu, account, back, none }

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.size = 46,
    this.iconSize = 23,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.ink : Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(color: AppColors.ink, width: 0.9),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: filled ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = AppServices.backend.cachedProfile;
    return PopupMenuButton<String>(
      tooltip: 'Open navigation menu',
      color: const Color(0xFFF5FFE9),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (route) async {
        if (route == AppRoutes.signIn) {
          await AppServices.backend.signOut();
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signIn,
            (_) => false,
          );
          return;
        }
        if (context.mounted) Navigator.pushReplacementNamed(context, route);
      },
      itemBuilder: (context) => [
        if (profile?.role == UserRole.student)
          const PopupMenuItem(
            value: AppRoutes.forYou,
            child: Text('Student home'),
          ),
        if (profile?.role == UserRole.schoolAdmin) ...[
          const PopupMenuItem(
            value: AppRoutes.adminDashboard,
            child: Text('School dashboard'),
          ),
          const PopupMenuItem(
            value: AppRoutes.requests,
            child: Text('All requests'),
          ),
        ],
        if (profile != null)
          const PopupMenuItem(
            value: AppRoutes.account,
            child: Text('My account'),
          ),
        if (profile != null) const PopupMenuDivider(),
        PopupMenuItem(
          value: AppRoutes.signIn,
          child: Text(profile == null ? 'Sign in' : 'Sign out'),
        ),
      ],
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 0.9),
        ),
        child: const Icon(Icons.more_horiz_rounded),
      ),
    );
  }
}

class ElimuTextField extends StatelessWidget {
  const ElimuTextField({
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

class ElimuDropdownField extends StatelessWidget {
  const ElimuDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          validator: (selected) =>
              selected == null || selected.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Epilogue',
            fontSize: 15,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
          ),
        ),
        child: icon == null
            ? Text(label)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ),
      ),
    );
  }
}

class OutlineCard extends StatelessWidget {
  const OutlineCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.card,
    this.borderRadius = 24,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.ink, width: 0.9),
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: card),
    );
  }
}

class ElimuBottomNavigation extends StatelessWidget {
  const ElimuBottomNavigation({
    required this.currentIndex,
    this.admin = false,
    super.key,
  });

  final int currentIndex;
  final bool admin;

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (!AppServices.backend.isAuthenticated) {
      showElimuMessage(context, 'Sign in to access this page.');
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      return;
    }

    if ((admin && index == 1) || index == 3) {
      final label = index == 1 ? 'Messages' : 'Notifications';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label will appear here.')));
      return;
    }

    final route = switch (index) {
      0 => admin ? AppRoutes.adminDashboard : AppRoutes.forYou,
      1 => AppRoutes.likedSchools,
      2 => admin ? AppRoutes.requests : AppRoutes.applications,
      4 => AppRoutes.account,
      _ => admin ? AppRoutes.adminDashboard : AppRoutes.forYou,
    };
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_outlined,
      admin ? Icons.chat_bubble_outline_rounded : Icons.favorite_border_rounded,
      Icons.inventory_2_outlined,
      Icons.notifications_none_rounded,
      Icons.person_outline_rounded,
    ];

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.nav.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(38),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (index) {
          final selected = currentIndex == index;
          return Semantics(
            selected: selected,
            label: switch (index) {
              0 => 'Home',
              1 => admin ? 'Messages' : 'Liked schools',
              2 => admin ? 'Requests' : 'Applications',
              3 => 'Notifications',
              _ => 'Account',
            },
            button: true,
            child: IconButton(
              onPressed: () => _onTap(context, index),
              style: IconButton.styleFrom(
                fixedSize: const Size(50, 50),
                backgroundColor: selected ? Colors.black : Colors.transparent,
                foregroundColor: selected ? Colors.white : AppColors.ink,
              ),
              icon: Icon(icons[index], size: 27),
            ),
          );
        }),
      ),
    );
  }
}

String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}

String? emailField(String? value) {
  final required = requiredField(value);
  if (required != null) return required;
  final email = value!.trim();
  if (!email.contains('@') ||
      !email.substring(email.indexOf('@')).contains('.')) {
    return 'Enter a valid email';
  }
  return null;
}

String? passwordField(String? value) {
  final required = requiredField(value);
  if (required != null) return required;
  if (value!.length < 6) return 'Use at least 6 characters';
  return null;
}

void showElimuMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
