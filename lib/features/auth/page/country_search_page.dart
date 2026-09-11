import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petlux/common/models/country_dto.dart';
import 'package:petlux/core/services/region_service.dart';
import 'package:petlux/locator.dart';
import 'package:petlux/common/l10n/app_localizations.dart';

class CountrySearchPage extends StatefulWidget {
  const CountrySearchPage({super.key});

  @override
  State<CountrySearchPage> createState() => _CountrySearchPageState();
}

class _CountrySearchPageState extends State<CountrySearchPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RegionService _regionService = locator<RegionService>();

  List<CountryDto> _allCountries = [];
  List<CountryDto> _filteredCountries = [];

  // 单行固定高度，用于像素级瞬时定位
  static const double _itemHeight = 56.0;

  static const Color _brandYellow = Color(0xFFF2C94C);
  static const Color _inputBg = Color(0xFFEFEFF2);
  static const Color _textColor = Color(0xFF222222);

  @override
  void initState() {
    super.initState();
    _allCountries = _regionService.countries;
    _filteredCountries = _allCountries;

    _searchCtrl.addListener(_onSearchChanged);

    if (_allCountries.isEmpty) {
      _regionService.loadCountryList().then((list) {
        if (mounted) {
          setState(() {
            _allCountries = list;
            _filteredCountries = list;
          });
          _scrollToCurrentSelected(isAnimate: false);
        }
      });
    } else {
      // 页面构建完成第一帧后直接跳到选中位置
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentSelected(isAnimate: false);
      });
    }
  }

  /// 计算索引并滚动到当前选中的国家位置
  void _scrollToCurrentSelected({bool isAnimate = false}) {
    final currentCountry = _regionService.currentCountry;
    if (currentCountry == null) return;

    final index = _filteredCountries.indexWhere(
      (c) => c.countryCode.toUpperCase() == currentCountry.countryCode.toUpperCase(),
    );

    if (index == -1 || !_scrollController.hasClients) return;

    // 计算滚动的目标偏移高度
    final double targetOffset = index * _itemHeight;

    if (isAnimate) {
      _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // 进入页面无感直达，不产生多余滚动动画
      _scrollController.jumpTo(targetOffset);
    }
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((c) {
          final nameMatch = c.name.toLowerCase().contains(query);
          final codeMatch = c.countryCode.toLowerCase().contains(query);
          final phoneMatch = c.phoneCountryCode.contains(query);
          return nameMatch || codeMatch || phoneMatch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final selectedCountry = _regionService.currentCountry;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          s.selectCountryRegion,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 顶部搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontSize: 14, color: _textColor),
                      decoration: InputDecoration(
                        hintText: s.searchCountryHint,
                        hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => _searchCtrl.clear(),
                      child: const Icon(Icons.close, color: Color(0xFF9E9E9E), size: 18),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // 2. 国家列表（采用 itemExtent 保证定高定位精度）
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(s.noMatchingRegion, style: TextStyle(color: Colors.grey, fontSize: 14)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemExtent: _itemHeight,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final item = _filteredCountries[index];
                      final isSelected = selectedCountry?.countryCode.toUpperCase() == item.countryCode.toUpperCase();

                      return InkWell(
                        onTap: () => context.pop(item),
                        child: Container(
                          height: _itemHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? _brandYellow : _textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                item.phoneCountryCode,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 10),
                                const Icon(Icons.check, color: _brandYellow, size: 20),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
