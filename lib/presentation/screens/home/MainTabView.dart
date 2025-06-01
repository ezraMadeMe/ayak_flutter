import 'package:flutter/material.dart';
import 'package:yakunstructuretest/core/constants/app_colors.dart';
import 'package:yakunstructuretest/presentation/screens/history/MedicationHistory.dart';
import 'package:yakunstructuretest/presentation/screens/home/HomeScreen.dart';
import 'package:yakunstructuretest/presentation/screens/home/HomeScreen2.dart';
import 'package:yakunstructuretest/presentation/screens/mypage/mypage.dart';
import 'package:yakunstructuretest/presentation/screens/search/SearchScreen.dart';
import 'package:yakunstructuretest/presentation/screens/statistics/StatisticsScreen.dart';

// 메인 탭뷰 컨트롤러
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  // 탭 설정
  final List<TabItem> _tabs = [
    TabItem(
      id: 'home',
      title: '홈',
      icon: Icons.home,
      activeIcon: Icons.home_filled,
    ),
    TabItem(
      id: 'search',
      title: '검색',
      icon: Icons.search,
      activeIcon: Icons.saved_search,
    ),
    TabItem(
      id: 'statistics',
      title: '통계',
      icon: Icons.auto_graph_outlined,
      activeIcon: Icons.auto_graph,
    ),
    TabItem(
      id: 'history',
      title: '복약기록',
      icon: Icons.history_edu_outlined,
      activeIcon: Icons.history_edu,
    ),
    TabItem(
      id: 'settings',
      title: '설정',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _currentIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
        children: [
          _buildTabContent('home'),
          _buildTabContent('search'),
          _buildTabContent('statistics'),
          _buildTabContent('history'),
          _buildTabContent('settings'),
        ],
      ),
      bottomNavigationBar: _buildBottomTabBar(),
    );
  }

  // 탭 컨텐츠 빌더
  Widget _buildTabContent(String tabId) {
    switch (tabId) {
      case 'home':
        return const HomeScreen();
      case 'search':
        return const SearchScreen();
      case 'history':
        return const HistoryTabContent();
      case 'settings':
        return const MypageScreen();
      case 'statistics':
        return const StatisticsScreen();
      default:
        return _buildPlaceholderContent(tabId);
    }
  }

  // 하단 탭바
  Widget _buildBottomTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = _currentIndex == index;

              return _buildTabItem(tab, isActive, index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 개별 탭 아이템
  Widget _buildTabItem(TabItem tab, bool isActive, int index) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 20,
                color: isActive ? AppColors.primary : Colors.grey[600],
              ),
            ),
            Text(
              tab.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 탭 전환 핸들러
  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _tabController.animateTo(index);

      // 탭 전환 시 추가 로직 (필요한 경우)
      _handleTabChange(_tabs[index].id);
    }
  }

  // 탭 변경 시 추가 처리
  void _handleTabChange(String tabId) {
    switch (tabId) {
      case 'home':
      // 홈 탭 활성화 시 데이터 새로고침 등
        break;
      case 'search':
      // 검색 탭 활성화 시 검색 포커스 등
        break;
      case 'history':
      // 히스토리 탭 활성화 시 최신 기록 로드 등
        break;
      case 'settings':
      // 설정 탭 활성화 시 처리
        break;
    }
  }

  // 플레이스홀더 컨텐츠
  Widget _buildPlaceholderContent(String tabId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${tabId.toUpperCase()} 탭',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '개발 중입니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// 탭 아이템 모델
class TabItem {
  final String id;
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const TabItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.activeIcon,
  });
}

// 검색 카테고리 모델
class SearchCategory {
  final String id;
  final String title;
  final IconData icon;

  SearchCategory(this.id, this.title, this.icon);
}

