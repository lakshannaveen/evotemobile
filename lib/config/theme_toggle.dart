// lib/config/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;
  final bool showText;
  final EdgeInsetsGeometry? padding;

  const ThemeToggle({
    super.key,
    this.iconColor,
    this.iconSize,
    this.showText = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => themeProvider.toggleTheme(!isDark),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: iconColor ?? theme.colorScheme.onSurface,
                size: iconSize ?? 24,
              ),
              if (showText) ...[
                const SizedBox(width: 4),
                Text(
                  isDark ? 'Light Mode' : 'Dark Mode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: iconColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}