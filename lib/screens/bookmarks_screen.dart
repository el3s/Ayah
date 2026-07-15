import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models/bookmark_model.dart';
import '../data/repositories/user_data_repository.dart';
import 'quran_reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  final bool embedded;
  const BookmarksScreen({super.key, this.embedded = false});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final UserDataRepository _repository = UserDataRepository();
  List<BookmarkModel> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookmarks = await _repository.getAllBookmarks();
    setState(() {
      _bookmarks = bookmarks;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العلامات المحفوظة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('ما عندكش علامات محفوظة بعد', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final b = _bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.bookmark_rounded, color: AppColors.gold),
                        title: Text('سورة ${b.suraNameAr} - آية ${b.ayaNo}'),
                        subtitle: Text(b.riwaya == 'warsh' ? 'رواية ورش' : 'رواية حفص'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () async {
                            await _repository.removeBookmark(b.id);
                            _load();
                          },
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuranReaderScreen(
                              suraNo: b.suraNo,
                              scrollToAya: b.ayaNo,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
