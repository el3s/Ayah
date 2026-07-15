import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/quran_provider.dart';
import '../providers/prayer_provider.dart';
import 'surah_list_screen.dart';
import 'prayer_times_screen.dart';
import 'bookmarks_screen.dart';
import 'more_screen.dart';
import 'search_screen.dart';
import 'quran_reader_screen.dart';
import 'tasbih_screen.dart';
import 'qibla_screen.dart';
import 'azkar_screen.dart';
import 'memorize_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    _HomeTab(),
    SurahListScreen(embedded: true),
    PrayerTimesScreen(embedded: true),
    BookmarksScreen(embedded: true),
    MoreScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'المصحف'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time_rounded), label: 'الصلاة'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'المحفوظات'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'المزيد'),
        ],
      ),
    );
  }
}

/// تبويب الرئيسية: آخر قراءة + وقت الصلاة القادمة + وصول سريع
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLastReadCard(context),
          const SizedBox(height: 16),
          _buildNextPrayerCard(context),
          const SizedBox(height: 20),
          Text('وصول سريع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildQuickAccessGrid(context),
        ],
      ),
    );
  }

  Widget _buildLastReadCard(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();
    return FutureBuilder(
      future: quranProvider.getLastRead(),
      builder: (context, snapshot) {
        final lastRead = snapshot.data;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (lastRead != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuranReaderScreen(
                      suraNo: lastRead.suraNo,
                      scrollToAya: lastRead.ayaNo,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories_rounded,
                      color: AppColors.gold, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('متابعة القراءة',
                            style: TextStyle(color: AppColors.goldLight, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          lastRead != null
                              ? 'سورة ${lastRead.suraNameAr} - آية ${lastRead.ayaNo}'
                              : 'ابدأ القراءة من الفاتحة',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextPrayerCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.mosque_rounded, color: AppColors.primary, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('اضبط الأذان التلقائي حسب موقعك',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
              ),
              child: const Text('الصلاة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final items = <(String, IconData, Widget Function())>[
      ('التسبيح', Icons.fingerprint_rounded, () => const TasbihScreen()),
      ('القبلة', Icons.explore_rounded, () => const QiblaScreen()),
      ('الأذكار', Icons.wb_sunny_rounded, () => const AzkarScreen()),
      ('حفظ القرآن', Icons.psychology_rounded, () => const MemorizeScreen(suraNo: 1)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: items.map((item) {
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => item.$3()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(item.$2, color: AppColors.gold),
                  const SizedBox(width: 10),
                  Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
