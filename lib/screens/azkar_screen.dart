import 'package:flutter/material.dart';
import '../core/theme.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  // ملاحظة: هاد اللائحة مختصرة كمثال، يفضل تعويضها بملف JSON كامل
  // فيه كل الأذكار الصحيحة الموثقة (حصن المسلم) عوض كتابتها مباشرة فالكود
  static const List<Map<String, dynamic>> _azkarSabah = [
    {'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ', 'count': 1},
    {'text': 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ', 'count': 1},
    {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ', 'count': 100},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار اليومية'),
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            tabs: [
              Tab(text: 'أذكار الصباح'),
              Tab(text: 'أذكار المساء'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAzkarList(),
            _buildAzkarList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAzkarList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _azkarSabah.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final zikr = _azkarSabah[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zikr['text'], style: const TextStyle(fontSize: 17, height: 1.8)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text('${zikr['count']} مرة'),
                    backgroundColor: AppColors.gold.withOpacity(0.15),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
