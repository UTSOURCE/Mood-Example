import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import 'package:moodexample/themes/app_theme.dart';
import 'package:moodexample/common/utils_intl.dart';
import 'package:moodexample/l10n/gen/app_localizations.dart';
import 'package:moodexample/routes.dart';

import 'package:moodexample/widgets/action_button/action_button.dart';
import 'package:moodexample/widgets/animation/animation.dart';

import 'package:moodexample/models/mood/mood_category_model.dart';
import 'package:moodexample/models/mood/mood_model.dart';
import 'package:moodexample/providers/mood/mood_provider.dart';

late MoodCategorySelectType _moodCategorySelectType;

/// 当前选择的时间
late String _nowDateTime;

/// 状态
enum MoodCategorySelectType {
  add('add'),
  edit('edit');

  const MoodCategorySelectType(this.type);
  final String type;

  static MoodCategorySelectType fromString(String type) =>
      values.firstWhere((e) => e.type == type, orElse: () => add);
}

/// 新增心情页
class MoodCategorySelect extends StatefulWidget {
  const MoodCategorySelect({super.key, required this.type});

  /// 状态
  final String type;

  @override
  State<MoodCategorySelect> createState() => _MoodCategorySelectState();
}

class _MoodCategorySelectState extends State<MoodCategorySelect> {
  @override
  void initState() {
    super.initState();
    final moodProvider = context.read<MoodProvider>();

    /// 状态
    _moodCategorySelectType = MoodCategorySelectType.fromString(widget.type);

    /// 当前选择的时间
    _nowDateTime = moodProvider.nowDateTime.toString().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.displayLarge!.color,
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
        leading: ActionButton(
          semanticsLabel: '关闭',
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : AppTheme.staticBackgroundColor1,
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(18)),
          ),
          child: const Icon(Remix.arrow_left_line, size: 24),
          onTap: () => context.pop(),
        ),
      ),
      body: const SafeArea(
        child: MoodCategorySelectBody(key: Key('widget_mood_category_select_body')),
      ),
    );
  }
}

class MoodCategorySelectBody extends StatelessWidget {
  const MoodCategorySelectBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appL10n = AppL10n.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        /// 标题
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 48),
          child: Column(
            children: [
              Text(
                switch (_moodCategorySelectType) {
                  MoodCategorySelectType.add => appL10n.mood_category_select_title_1,
                  MoodCategorySelectType.edit => appL10n.mood_category_select_title_2,
                },
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  switch (_moodCategorySelectType) {
                    MoodCategorySelectType.add => LocaleDatetime.yMMMd(context, _nowDateTime),
                    MoodCategorySelectType.edit => '',
                  },
                  style: const TextStyle(
                    color: AppTheme.staticSubColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 心情选项
        const MoodChoice(),
      ],
    );
  }
}

/// 心情选择
class MoodChoice extends StatelessWidget {
  const MoodChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 48),
        child: Consumer<MoodProvider>(
          builder: (_, moodProvider, child) {
            final widgetList = <Widget>[];
            for (final list in moodProvider.moodCategoryList) {
              widgetList.add(MoodChoiceCard(icon: list.icon, title: list.title));
            }

            /// 显示
            return Wrap(spacing: 24, runSpacing: 24, children: widgetList);
          },
        ),
      ),
    );
  }
}

/// 心情选择卡片
class MoodChoiceCard extends StatelessWidget {
  const MoodChoiceCard({super.key, required this.icon, required this.title});

  /// 图标
  final String icon;

  /// 标题
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPress(
      child: GestureDetector(
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(icon, style: const TextStyle(fontSize: 32)),
              ),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        onTap: () {
          switch (_moodCategorySelectType) {
            case MoodCategorySelectType.add:
              // 关闭当前页并跳转输入内容页
              final moodData = MoodData(
                icon: icon,
                title: title,
                create_time: _nowDateTime,
                update_time: _nowDateTime,
              );

              // 跳转输入内容页
              context.pop();
              GoRouter.of(context).pushNamed(
                Routes.moodContent,
                pathParameters: {'moodData': jsonEncode(moodData.toJson())},
              );
            case MoodCategorySelectType.edit:
              // 关闭当前页并返回数据
              final moodCategoryData = MoodCategoryData(icon: icon, title: title);
              context.pop<Map<String, Object?>>(moodCategoryData.toJson());
          }
        },
      ),
    );
  }
}
