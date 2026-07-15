import 'package:flutter/material.dart';
import '../core/theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  final List<String> _azkar = ['سبحان الله', 'الحمد لله', 'الله أكبر', 'لا إله إلا الله'];
  int _selectedZikr = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _count = 0),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: List.generate(_azkar.length, (i) {
                return ChoiceChip(
                  label: Text(_azkar[i]),
                  selected: _selectedZikr == i,
                  onSelected: (_) => setState(() {
                    _selectedZikr = i;
                    _count = 0;
                  }),
                );
              }),
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _count++),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_count',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_azkar[_selectedZikr],
                          style: const TextStyle(color: AppColors.goldLight, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('اضغط على الدائرة للعد', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
