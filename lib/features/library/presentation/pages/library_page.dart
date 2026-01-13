import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/note.dart';
import '../../../../models/sort_option.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_component_styles.dart';
import '../widgets/library_widgets.dart';
import '../../controller/library_controller.dart';
import '../../state/library_filter_state.dart';
import '../../state/library_state.dart';
import '../../../../shared/presentation/modals/details_modal.dart';
import '../../../../providers/note_providers.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  double _acidity = 5;
  double _body = 5;
  double _bitterness = 5;
  Timer? _filterDebounce;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _filterDebounce?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _syncFilterToLocal(LibraryFilterState filter) {
    if (!mounted) return;
    setState(() {
      _acidity = (filter.acidity ?? 5).toDouble();
      _body = (filter.body ?? 5).toDouble();
      _bitterness = (filter.bitterness ?? 5).toDouble();
    });
  }

  void _scheduleFilterUpdate() {
    _filterDebounce?.cancel();
    _filterDebounce = Timer(const Duration(milliseconds: 200), () {
      final controller = ref.read(libraryControllerProvider.notifier);
      controller.updateFilterValues(
        acidity: _acidity.toInt(),
        body: _body.toInt(),
        bitterness: _bitterness.toInt(),
      );
    });
  }

  void _cancelFilterDebounce() {
    _filterDebounce?.cancel();
    _filterDebounce = null;
  }

  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(libraryControllerProvider.notifier).updateSearch(text);
    });
  }

  double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / AppSpacing.designWidth;
    return scaleFactor.clamp(0.3, 1.2);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(libraryControllerProvider, (previous, next) {
      final prevFilter = previous?.valueOrNull?.query.filterState;
      final nextFilter = next.valueOrNull?.query.filterState;
      if (nextFilter != null && nextFilter != prevFilter) {
        _syncFilterToLocal(nextFilter);
      }
    });

    final scale = _getScaleFactor(context);
    final controller = ref.read(libraryControllerProvider.notifier);
    final isInitialLoading = ref.watch(
      libraryControllerProvider.select(
        (value) => value.isLoading && value.valueOrNull == null,
      ),
    );
    final isRefreshing = ref.watch(
      libraryControllerProvider.select(
        (value) => value.valueOrNull?.isRefreshing ?? false,
      ),
    );
    final error = ref.watch(
      libraryControllerProvider.select(
        (value) => value.valueOrNull?.error,
      ),
    );
    final searchQuery = ref.watch(
      libraryControllerProvider.select(
        (value) => value.valueOrNull?.query.searchQuery ?? '',
      ),
    );
    final sortOption = ref.watch(
      libraryControllerProvider.select(
        (value) =>
            value.valueOrNull?.query.sortOption ??
            const DateSortOption(ascending: false),
      ),
    );
    final filter = ref.watch(
      libraryControllerProvider.select(
        (value) =>
            value.valueOrNull?.query.filterState ??
            const LibraryFilterState(),
      ),
    );
    final notes = ref.watch(
      libraryControllerProvider.select(
        (value) => value.valueOrNull?.notes ?? const <Note>[],
      ),
    );

    if (isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 에러 배너
        if (error != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12 * scale),
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding * scale,
              vertical: 8 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[300]!),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20 * scale),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Text(
                    '에러 발생: $error',
                    style: TextStyle(color: Colors.red[900], fontSize: 14 * scale),
                  ),
                ),
              ],
            ),
          ),
        // 검색창
        Padding(
          padding:
            EdgeInsets.only(
              left: AppSpacing.horizontalPadding * scale,
              right: AppSpacing.horizontalPadding * scale,
              top: 20 * scale,
              bottom: 10 * scale,
            ),
          child: TextField(
            style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
            decoration: AppComponentStyles.textInputDecoration(
              hintText: "검색어를 입력하세요.",
            ).copyWith(
              hintStyle: AppTextStyles.bodyText.copyWith(
                fontSize: 25 * scale,
                color: AppColors.primaryText.withOpacity(0.5),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // 상세 필터 컨테이너
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
          ),
          child: Column(
            children: [
              // 상세 필터 토글 버튼 영역
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _cancelFilterDebounce();
                        controller.toggleFilterVisibility();
                      },
                      icon: Icon(
                        filter.showDetailFilter ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.primaryDark,
                        size: 30 * scale,
                      ),
                      label: Text(
                        "상세필터",
                        style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
                      ),
                    ),
                    if (filter.showDetailFilter)
                      TextButton(
                        onPressed: () => controller.clearFilters(),
                        child: Text(
                          "초기화",
                          style: AppTextStyles.bodyText.copyWith(fontSize: 30 * scale),
                        ),
                      ),
                  ],
                ),
              ),
              // 상세 필터 슬라이더
              if (filter.showDetailFilter) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 20 * scale),
                  child: Container(
                    decoration: AppComponentStyles.filterAreaDecoration.copyWith(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.borderRadiusSmall * scale),
                      border: Border.all(color: Colors.transparent, width: 0),
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.all(20 * scale),
                    child: Column(
                      children: [
                        buildFilterSlider(
                          '산미',
                          _acidity,
                          (value) => setState(() => _acidity = value),
                          scale,
                          onChangeEnd: (_) => _scheduleFilterUpdate(),
                        ),
                        buildFilterSlider(
                          '바디',
                          _body,
                          (value) => setState(() => _body = value),
                          scale,
                          onChangeEnd: (_) => _scheduleFilterUpdate(),
                        ),
                        buildFilterSlider(
                          '쓴맛',
                          _bitterness,
                          (value) => setState(() => _bitterness = value),
                          scale,
                          onChangeEnd: (_) => _scheduleFilterUpdate(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 정렬 버튼
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding * scale,
            vertical: 10 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              sortButton(
                context,
                "최신순",
                const DateSortOption(ascending: false),
                sortOption,
                scale,
                () => controller.updateSort(const DateSortOption(ascending: false)),
              ),
              SizedBox(width: 20 * scale),
              sortButton(
                context,
                "별점순",
                const ScoreSortOption(ascending: false),
                sortOption,
                scale,
                () => controller.updateSort(const ScoreSortOption(ascending: false)),
              ),
              if (isRefreshing) ...[
                SizedBox(width: 16 * scale),
                SizedBox(
                  width: 22 * scale,
                  height: 22 * scale,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),

        // 리스트 영역
        Expanded(
          child: notes.isEmpty
              ? ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding * scale,
                  ),
                  children: [
                    buildEmptyGuideCard(scale),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding * scale,
                    vertical: 20 * scale,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 30 * scale),
                      child: buildNoteCard(
                        context,
                        notes[index],
                        scale,
                        () => controller.refresh(),
                        NoteDetailsModal(
                          note: notes[index],
                          detailService: ref.read(detailServiceProvider),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
