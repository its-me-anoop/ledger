import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

// Deterministic OKLCH-derived avatar bg from name hash.
// Six tinted surfaces: amber, green, rose, slate, teal, sand.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.displayName,
    this.size = 40,
    this.photoUrl,
  });

  final String displayName;
  final double size;
  final String? photoUrl;

  static const _backgrounds = [
    Color(0xFFF5EDD8), // amber-dim
    Color(0xFFE4F5EC), // green-dim
    Color(0xFFF5E4EC), // rose-dim
    Color(0xFFE4ECF5), // slate-dim
    Color(0xFFE4F5F2), // teal-dim
    Color(0xFFF5F0E4), // sand-dim
  ];

  static const _foregrounds = [
    Color(0xFF7A4E0A), // amber dark
    Color(0xFF1A5C36), // green dark
    Color(0xFF7A1A3C), // rose dark
    Color(0xFF1A3C7A), // slate dark
    Color(0xFF0A5C54), // teal dark
    Color(0xFF5C4A1A), // sand dark
  ];

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    final index = displayName.isEmpty
        ? 0
        : displayName.codeUnits.fold(0, (a, b) => a + b) % _backgrounds.length;

    final initials = _extractInitials(displayName);
    final fontSize = size * 0.38;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgrounds[index],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.fraunces(
          size: fontSize,
          color: _foregrounds[index],
          opsz: 36,
        ),
      ),
    );
  }

  String _extractInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// Row of stacked member avatars (for group list rows).
class MemberAvatarRow extends StatelessWidget {
  const MemberAvatarRow({
    super.key,
    required this.names,
    this.size = 28,
    this.maxVisible = 4,
  });

  final List<String> names;
  final double size;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final visible = names.take(maxVisible).toList();
    final overflow = names.length - maxVisible;

    return SizedBox(
      height: size,
      width: visible.length * (size * 0.7) + (overflow > 0 ? size * 0.7 : 0),
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size * 0.7),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: MemberAvatar(displayName: visible[i], size: size),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: visible.length * (size * 0.7),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9DF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: AppTypography.xs(color: const Color(0xFF7A6E5E)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

