import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';

import 'package:moodexample/themes/app_theme.dart';
import 'package:moodexample/l10n/gen/app_localizations.dart';
import 'package:moodexample/common/utils_intl.dart';

import 'package:moodexample/widgets/show_modal_bottom_detail/show_modal_bottom_detail.dart';
import 'package:moodexample/widgets/empty/empty.dart';
import 'package:moodexample/widgets/action_button/action_button.dart';
import 'package:moodexample/widgets/animation/animation.dart';

import 'package:moodexample/views/mood/mood_content.dart';
import 'package:moodexample/views/mood/mood_category_select.dart'
    show MoodCategorySelect, MoodCategorySelectType;

import 'package:moodexample/models/mood/mood_model.dart';
import 'package:moodexample/providers/mood/mood_provider.dart';

/// 心情页（记录列表）
class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePrimaryColor = theme.primaryColor;
    final appL10n = AppL10n.of(context);

    return Scaffold(
      floatingActionButton: AnimatedPress(
        child: OpenContainer(
          useRootNavigator: true,
          clipBehavior: Clip.none,
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 450),
          closedBuilder: (_, openContainer) {
            return FloatingActionButton.extended(
              key: const Key('widget_add_mood_button'),
              heroTag: 'addmood',
              backgroundColor: themePrimaryColor,
              hoverElevation: 0,
              focusElevation: 0,
              elevation: 0,
              highlightElevation: 0,
              label: Row(
                children: [
                  const Icon(Remix.add_fill, color: Colors.white, size: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      appL10n.mood_add_button,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                openContainer();
              },
            );
          },
          openElevation: 0,
          openColor: theme.scaffoldBackgroundColor,
          middleColor: themePrimaryColor.withValues(alpha: 0.2),
          closedElevation: 0,
          closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          closedColor: theme.scaffoldBackgroundColor,
          openBuilder: (_, closeContainer) =>
              MoodCategorySelect(type: MoodCategorySelectType.add.type),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: const MoodBody(key: Key('widget_mood_body')),
    );
  }
}

/// 主体
class MoodBody extends StatelessWidget {
  const MoodBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appL10n = AppL10n.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        SliverAppBar(
          pinned: false,
          elevation: 0,
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: SafeArea(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appL10n.mood_title,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    semanticsLabel: appL10n.app_bottomNavigationBar_title_mood,
                  ),
                  Image.asset(
                    'assets/images/woolly/woolly-heart.png',
                    height: 60,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
            ),
          ),
          collapsedHeight: 100,
          expandedHeight: 100,
        ),

        /// 下拉加载
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            final moodProvider = context.read<MoodProvider>();
            moodProvider.load();
          },
        ),

        /// 日历
        const SliverToBoxAdapter(child: Calendar(key: Key('widget_mood_body_calendar'))),

        /// 心情数据列表
        Consumer<MoodProvider>(
          builder: (_, moodProvider, child) {
            /// 加载数据的占位
            if (moodProvider.moodDataLoading) {
              return SliverFixedExtentList(
                itemExtent: 280,
                delegate: SliverChildBuilderDelegate(
                  (builder, index) {
                    return const Align(child: CupertinoActivityIndicator(radius: 12));
                  },
                  childCount: 1,
                ),
              );
            }

            /// 没有数据的占位
            if (moodProvider.moodDataList.length <= 0) {
              return SliverFixedExtentList(
                itemExtent: 280,
                delegate: SliverChildBuilderDelegate(
                  (builder, index) {
                    return const Empty(padding: EdgeInsets.only(top: 64), height: 160, width: 90);
                  },
                  childCount: 1,
                ),
              );
            }

            /// 有内容显示
            return SlidableAutoCloseBehavior(
              child: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final moodData = moodProvider.moodDataList[index];
                    return MoodCard(key: Key(moodData.mood_id.toString()), moodData: moodData);
                  },
                  childCount: moodProvider.moodDataList.length,
                ),
              ),
            );
          },
        ),

        /// 占位高度
        const SliverToBoxAdapter(child: SizedBox(height: 64)),
      ],
    );
  }
}

/// 日历
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  /// 日历版式
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themePrimaryColor = theme.primaryColor;
    final isDark = AppTheme(context).isDarkMode;
    final appL10n = AppL10n.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          /// 当前选中得日期
          final nowDateTime = moodProvider.nowDateTime;

          return TableCalendar(
            locale: appL10n.localeName,
            firstDay: DateTime.utc(2021, 10, 01),
            lastDay: DateTime.now(),
            focusedDay: nowDateTime,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: calendarFormat,
            formatAnimationCurve: Curves.linearToEaseOut,
            pageAnimationCurve: Curves.linearToEaseOut,
            rowHeight: 52,
            daysOfWeekHeight: 24,
            // 头部样式
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 14),
              leftChevronIcon: Icon(
                Remix.arrow_left_s_line,
                size: 24,
                color: AppTheme.staticSubColor,
                semanticLabel: '日历向前翻页',
              ),
              rightChevronIcon: Icon(
                Remix.arrow_right_s_line,
                size: 24,
                color: AppTheme.staticSubColor,
                semanticLabel: '日历向后翻页',
              ),
              formatButtonTextStyle: TextStyle(fontSize: 10, color: AppTheme.staticSubColor),
              formatButtonDecoration: BoxDecoration(
                border: Border.fromBorderSide(BorderSide(color: AppTheme.staticBackgroundColor1)),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 14, color: AppTheme.staticSubColor),
              weekendStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.staticSubColor,
              ),
            ),
            // 自定义界面构建
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final moodRecordDate = moodProvider.moodRecordDate;
                return calenderBuilder(
                  day: day,
                  moodRecordDate: moodRecordDate,
                  textStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                );
              },
              selectedBuilder: (context, day, focusedDay) => calenderBuilder(
                day: day,
                bodyColors: [themePrimaryColor, themePrimaryColor],
                boxShadow: [
                  BoxShadow(color: themePrimaryColor.withValues(alpha: 0.2), blurRadius: 6),
                ],
                textStyle: const TextStyle(color: Colors.white),
              ),
              outsideBuilder: (context, day, focusedDay) => calenderBuilder(
                day: day,
                textStyle: TextStyle(
                  color: isDark
                      ? AppTheme.staticSubColor.withValues(alpha: 0.6)
                      : AppTheme.staticSubColor,
                ),
              ),
              todayBuilder: (context, day, focusedDay) {
                final moodRecordDate = moodProvider.moodRecordDate;
                return calenderBuilder(
                  day: day,
                  moodRecordDate: moodRecordDate,
                  bodyColors: [
                    themePrimaryColor.withValues(alpha: 0.2),
                    themePrimaryColor.withValues(alpha: 0.2),
                  ],
                  textStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
                );
              },
              disabledBuilder: (context, day, focusedDay) => calenderBuilder(
                day: day,
                textStyle: TextStyle(
                  color: isDark ? const Color(0x20BFBFBF) : const Color(0x50BFBFBF),
                ),
              ),
            ),
            onFormatChanged: (format) => setState(() => calendarFormat = format),
            availableCalendarFormats: const {
              CalendarFormat.month: '小',
              CalendarFormat.twoWeeks: '大',
              CalendarFormat.week: '中',
            },
            selectedDayPredicate: (day) => isSameDay(nowDateTime, day),
            onDaySelected: (selectedDay, focusedDay) {
              /// 之前选择的日期
              final oldSelectedDay = moodProvider.nowDateTime;

              /// 选择的日期相同则不操作
              if (oldSelectedDay == selectedDay) return;

              /// 赋值当前选择的日期
              moodProvider.nowDateTime = selectedDay;

              /// 开启加载
              moodProvider.moodDataLoading = true;

              /// 获取心情数据
              moodProvider.loadMoodDataList();
            },
            onCalendarCreated: (pageController) {
              /// 初始化触发一次
              Future.delayed(const Duration(milliseconds: 1), () {
                pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linearToEaseOut,
                );
              });
              Future.delayed(const Duration(milliseconds: 1000), () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linearToEaseOut,
                );
              });
            },
          );
        },
      ),
    );
  }

  /// 日历样式构建
  ///
  /// [day] 当前日期
  ///
  /// [moodRecordDate] 所有已记录心情的日期
  ///
  /// [bodyColors] 主背景渐变颜色 - 至少两个
  ///
  /// [textStyle] 字体样式
  Widget calenderBuilder({
    required DateTime day,
    List<MoodRecordData>? moodRecordDate,
    List<Color>? bodyColors,
    List<BoxShadow>? boxShadow,
    required TextStyle textStyle,
  }) {
    final nowDate = DateFormat('yyyy-MM-dd').format(day);

    /// 所有已记录心情的日期
    final list = moodRecordDate ?? [];

    return Container(
      width: 36,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bodyColors ?? [Colors.transparent, Colors.transparent]),
        boxShadow: boxShadow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Text(nowDate.substring(8, 10), style: textStyle),
            Builder(
              builder: (context) {
                var recordedIndex = -1;
                for (var i = 0; i < list.length; i++) {
                  if (list[i].record_date == DateFormat('yyyy-MM-dd').format(day)) {
                    recordedIndex = i;
                  }
                }
                if (recordedIndex > -1) {
                  return Container(
                    margin: const EdgeInsets.only(top: 28),
                    child: Text(list[recordedIndex].icon, style: const TextStyle(fontSize: 8)),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 心情卡片
class MoodCard extends StatelessWidget {
  const MoodCard({super.key, required this.moodData});

  final MoodData moodData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme(context).isDarkMode;
    final appL10n = AppL10n.of(context);

    return Slidable(
      key: key,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          Expanded(
            child: Align(
              child: OpenContainer(
                useRootNavigator: true,
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 450),
                closedBuilder: (_, openContainer) {
                  return ActionButton(
                    key: const Key('widget_mood_card_slidable_action_button_edit'),
                    semanticsLabel: '编辑',
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F2E2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    onTap: openContainer,
                    child: const Icon(Remix.edit_box_line, color: Color(0xFF587966)),
                  );
                },
                openElevation: 0,
                openColor: theme.scaffoldBackgroundColor,
                middleColor: theme.scaffoldBackgroundColor,
                closedElevation: 0,
                closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                closedColor: const Color(0xFFD6F2E2),
                openBuilder: (_, closeContainer) {
                  return MoodContent(moodData: moodData);
                },
              ),
            ),
          ),
          Expanded(
            child: Align(
              child: ActionButton(
                key: const Key('widget_mood_card_slidable_action_button_delete'),
                semanticsLabel: '删除',
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE5E4),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Remix.delete_bin_line, color: Color(0xFFC04A4A)),
                onTap: () => showCupertinoDialog<void>(
                  context: context,
                  builder: (BuildContext context) => Theme(
                    data: isDark ? ThemeData.dark() : ThemeData.light(),
                    child: CupertinoAlertDialog(
                      title: Text(appL10n.mood_data_delete_button_title),
                      content: Text(appL10n.mood_data_delete_button_content),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          child: Text(appL10n.mood_data_delete_button_cancel),
                          onPressed: () => context.pop(),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () async {
                            final moodProvider = context.read<MoodProvider>();
                            final result = await moodProvider.deleteMoodData(moodData);
                            if (result) {
                              /// 重新初始化
                              final moodProvider = context.read<MoodProvider>();
                              moodProvider.load();
                              context.pop();
                            }
                          },
                          child: Text(appL10n.mood_data_delete_button_confirm),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      /// 内容
      child: AnimatedPress(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: GestureDetector(
            child: Container(
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 头部
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 标题
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2B3034)
                                    : AppTheme.staticBackgroundColor3,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ExcludeSemantics(
                                child: Text(moodData.icon, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ExcludeSemantics(
                                      child: Text(
                                        moodData.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        moodData.create_time,
                                        style: const TextStyle(
                                          color: AppTheme.staticSubColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        semanticsLabel:
                                            '${LocaleDatetime.yMMMd(context, moodData.create_time)} 心情：${moodData.title}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2B3034) : AppTheme.staticBackgroundColor3,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          moodData.score.toString(),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          semanticsLabel: '${appL10n.mood_data_score_title}：${moodData.score}',
                        ),
                      ),
                    ],
                  ),

                  /// 内容
                  Padding(
                    padding: const EdgeInsets.only(left: 60, top: 20, bottom: 20),
                    child: Text(
                      moodData.content ?? appL10n.mood_data_content_empty,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        color: moodData.content != null
                            ? theme.textTheme.bodyMedium!.color
                            : AppTheme.staticSubColor,
                        fontSize: 14,
                      ),
                      semanticsLabel:
                          moodData.content != null ? '记录内容：${moodData.content}' : '没有记录内容',
                    ),
                  ),
                ],
              ),
            ),
            onTap: () =>
                showModalBottomDetail(context: context, child: MoodDetail(moodData: moodData)),
          ),
        ),
      ),
    );
  }
}

/// 心情详情详情展示
class MoodDetail extends StatelessWidget {
  const MoodDetail({super.key, required this.moodData});

  final MoodData moodData;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme(context).isDarkMode;
    final appL10n = AppL10n.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        Align(
          heightFactor: 2,
          child: Text(
            LocaleDatetime.yMMMd(context, moodData.create_time),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.staticSubColor,
            ),
            semanticsLabel:
                '${LocaleDatetime.yMMMd(context, moodData.create_time)} 心情：${moodData.title}',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// 心情卡片
              ExcludeSemantics(child: MoodChoiceCard(icon: moodData.icon, title: moodData.title)),

              /// 打分
              Expanded(
                child: Align(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          appL10n.mood_data_score_title,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Text(
                        moodData.score.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 内容
        Container(
          margin: const EdgeInsets.only(top: 24, bottom: 48, left: 24, right: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF202427) : Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            moodData.content ?? appL10n.mood_data_content_empty,
            style: TextStyle(
              color: moodData.content != null
                  ? isDark
                      ? Colors.white
                      : Colors.black87
                  : AppTheme.staticSubColor,
              fontSize: 14,
            ),
            semanticsLabel: moodData.content != null ? '记录内容：${moodData.content}' : '没有记录内容',
          ),
        ),
      ],
    );
  }
}
