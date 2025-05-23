import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../themes/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../widgets/animation/animation.dart';
import '../../../shared/config/multiple_theme_mode.dart';
import '../../../shared/view_models/application_view_model.dart';

/// 主题设置
class SettingTheme extends StatelessWidget {
  const SettingTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final appL10n = AppL10n.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        /// 主题外观设置
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 6, bottom: 14),
          child: Text(
            appL10n.app_setting_theme_appearance,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),

        const DarkThemeBody(),
        const SizedBox(height: 36),

        /// 多主题设置-可浅色、深色模式独立配色方案
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 6, bottom: 14),
          child: Text(
            appL10n.app_setting_theme_themes,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),

        const MultipleThemeBody(),
        const SizedBox(height: 48),
      ],
    );
  }
}

/// 主题外观设置
class DarkThemeBody extends StatelessWidget {
  const DarkThemeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme(context).isDarkMode;
    final appL10n = AppL10n.of(context);

    return Selector<ApplicationViewModel, ({ThemeMode themeMode})>(
      selector: (_, applicationViewModel) {
        return (themeMode: applicationViewModel.themeMode);
      },
      builder: (context, data, child) {
        final applicationViewModel = context.read<ApplicationViewModel>();
        final themeMode = data.themeMode;
        return Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          runSpacing: 16,
          spacing: 16,
          children: [
            ThemeCard(
              title: appL10n.app_setting_theme_appearance_system,
              selected: themeMode == ThemeMode.system,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      color: isDark ? const Color(0xFFF6F8FA) : const Color(0xFF111315),
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: isDark ? Colors.black87 : const Color(0xFFEFEFEF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      color: isDark ? const Color(0xFF111315) : const Color(0xFFF6F8FA),
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFEFEFEF) : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => applicationViewModel.themeMode = ThemeMode.system,
            ),
            ThemeCard(
              title: appL10n.app_setting_theme_appearance_light,
              selected: themeMode == ThemeMode.light,
              child: Container(
                alignment: Alignment.center,
                color: const Color(0xFFF6F8FA),
                child: const Text(
                  'Aa',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () => applicationViewModel.themeMode = ThemeMode.light,
            ),
            ThemeCard(
              title: appL10n.app_setting_theme_appearance_dark,
              selected: themeMode == ThemeMode.dark,
              child: Container(
                alignment: Alignment.center,
                color: const Color(0xFF111315),
                child: const Text(
                  'Aa',
                  style: TextStyle(
                    color: Color(0xFFEFEFEF),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              onTap: () => applicationViewModel.themeMode = ThemeMode.dark,
            ),
          ],
        );
      },
    );
  }
}

/// 多主题设置
class MultipleThemeBody extends StatefulWidget {
  const MultipleThemeBody({super.key});

  @override
  State<MultipleThemeBody> createState() => _MultipleThemeBodyState();
}

class _MultipleThemeBodyState extends State<MultipleThemeBody> {
  @override
  Widget build(BuildContext context) {
    /// 获取多主题
    final multipleThemeModeList = MultipleThemeMode.values;

    return Selector<ApplicationViewModel, ({MultipleThemeMode multipleThemeMode})>(
      selector: (_, applicationViewModel) {
        return (multipleThemeMode: applicationViewModel.multipleThemeMode);
      },
      builder: (context, data, child) {
        final multipleThemeMode = data.multipleThemeMode;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            runSpacing: 16,
            spacing: 16,
            children: List.generate(multipleThemeModeList.length, (index) {
              final appMultipleThemeMode = multipleThemeModeList[index];
              final primaryColor = appMultipleThemeMode.data.lightTheme().primaryColor;
              return MultipleThemeCard(
                key: Key('widget_multiple_theme_card_${appMultipleThemeMode.name}'),
                selected: multipleThemeMode == appMultipleThemeMode,
                child: Container(alignment: Alignment.center, color: primaryColor),
                onTap: () {
                  print('当前选择主题：${appMultipleThemeMode.name}');
                  final applicationViewModel = context.read<ApplicationViewModel>();
                  applicationViewModel.multipleThemeMode = appMultipleThemeMode;
                },
              );
            }),
          ),
        );
      },
    );
  }
}

/// 多主题卡片
class MultipleThemeCard extends StatelessWidget {
  const MultipleThemeCard({
    super.key,
    this.child,
    this.selected,
    this.onTap, // dart format
  });

  /// 卡片内容
  final Widget? child;

  /// 是否选中
  final bool? selected;

  /// 点击触发
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme(context).isDarkMode;
    final isSelected = selected ?? false;
    final borderSelected = Border.all(width: 3, color: isDark ? Colors.white : Colors.black);
    final borderUnselected = Border.all(width: 3, color: isDark ? Colors.white12 : Colors.black12);
    final borderStyle = isSelected ? borderSelected : borderUnselected;

    return AnimatedPress(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: borderStyle,
                  ),
                  child: ClipRRect(borderRadius: BorderRadius.circular(50), child: child),
                ),
                Builder(
                  builder: (_) {
                    if (!isSelected) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: Icon(
                        Remix.checkbox_circle_fill,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 主题模式卡片
class ThemeCard extends StatelessWidget {
  const ThemeCard({
    super.key,
    this.child,
    this.title,
    this.selected,
    this.onTap, // dart format
  });

  /// 卡片内容
  final Widget? child;

  /// 卡片标题
  final String? title;

  /// 是否选中
  final bool? selected;

  /// 点击触发
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme(context).isDarkMode;
    final isSelected = selected ?? false;
    final borderSelected = Border.all(width: 3, color: isDark ? Colors.white : Colors.black);
    final borderUnselected = Border.all(width: 3, color: isDark ? Colors.white12 : Colors.black12);
    final borderStyle = isSelected ? borderSelected : borderUnselected;

    return AnimatedPress(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  width: 100,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: borderStyle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ExcludeSemantics(child: child),
                  ),
                ),
                Builder(
                  builder: (_) {
                    if (!isSelected) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: Icon(
                        Remix.checkbox_circle_fill,
                        size: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
