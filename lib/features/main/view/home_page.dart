import 'package:flutter/material.dart';
import 'package:manga/core/constant/colors.dart';
import 'package:manga/features/main/view_model/home_viewmodel.dart';
import 'package:manga/features/bookmarks/view/bookmarks_page.dart';
import 'package:manga/features/all_books/view/all_books_page.dart';
import 'package:manga/features/widgets/book_card.dart';
import 'package:manga/data/models/manga.dart';
import 'package:manga/features/manga_detail/view/manga_detail_page.dart';

class HomePage extends StatefulWidget {
  final HomeViewModel homeViewModel;
  final List<Manga> bookmarkedManga;
  final List<Manga> allManga;

  HomePage({
    Key? key,
    required this.homeViewModel,
    required this.bookmarkedManga,
    required this.allManga,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Manga> _filteredManga = [];
  bool _showDropdown = false;
  bool _isSearching = false; // Track if search bar is open

  @override
  void initState() {
    super.initState();
    _filteredManga = widget.allManga;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      String searchQuery = _searchController.text.toLowerCase();
      _filteredManga = widget.allManga
          .where((manga) => manga.title.toLowerCase().contains(searchQuery))
          .toList();
      _showDropdown = searchQuery.isNotEmpty && _filteredManga.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: _isSearching ? _buildSearchBar() : Text('NOW', style: TextStyle(color: AppColors.textColor)),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search, color: AppColors.secondaryColor),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: AppColors.secondaryColor),
            onPressed: () {
              // Implement cart functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainContent(context),
          if (_showDropdown) _buildSearchDropdown(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Manga...',
              hintStyle: TextStyle(color: AppColors.subTextColor),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: AppColors.textColor),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: AppColors.subTextColor),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _showDropdown = false;
              _searchController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchDropdown(BuildContext context) {
    return Positioned(
      top: kToolbarHeight - 50, // Position below the AppBar
      left: 16,
      right: 16,
      child: Material(
        color: AppColors.mainColor,
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _filteredManga.length,
          itemBuilder: (context, index) {
            final manga = _filteredManga[index];
            return ListTile(
              leading: Image.asset(
                manga.coverImage,
                width: 50,
                height: 75,
                fit: BoxFit.cover,
              ),
              title: Text(
                manga.title,
                style: TextStyle(color: AppColors.textColor),
              ),
              subtitle: Text(
                'Chapter: ${manga.chapter}',
                style: TextStyle(color: AppColors.subTextColor),
              ),
              onTap: () {
                setState(() {
                  _showDropdown = false;
                  _isSearching = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MangaDetailPage(
                      manga: manga,
                      initialChapterIndex: manga.chapter - 1,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }


  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContinueReadingSection(context),
            _buildForYouSection(context),
            _buildAllBooksSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingSection(BuildContext context) {
    final manga = widget.homeViewModel.lastReadManga;

    if (manga == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(manga.coverImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: TextStyle(color: AppColors.textColor, fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Chapter: ${manga.chapter}',
                    style: TextStyle(color: AppColors.subTextColor),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.mainColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailPage(
                            chapterTitle: 'Chapter ${manga.chapter}: ${manga.title}',
                          ),
                        ),
                      );
                    },
                    child: Text("Continue"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForYouSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('For You', style: TextStyle(color: AppColors.textColor, fontSize: 18)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookmarksPage(
                        bookmarkedManga: widget.bookmarkedManga,
                        homeViewModel: widget.homeViewModel,
                      ),
                    ),
                  );
                },
                child: Text('See All', style: TextStyle(color: AppColors.secondaryColor)),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.bookmarkedManga.length,
              itemBuilder: (context, index) {
                final manga = widget.bookmarkedManga[index];
                return Container(
                  width: 200,
                  child: BookCard(
                    title: manga.title,
                    chapter: 'Chapter: ${manga.chapter}',
                    coverImage: manga.coverImage,
                    isBookmarked: manga.isBookmarked,
                    onBookmarkToggle: () {
                      widget.homeViewModel.toggleBookmark(manga);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaDetailPage(
                            manga: manga,
                            initialChapterIndex: manga.chapter - 1,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBooksSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('All Books', style: TextStyle(color: AppColors.textColor, fontSize: 18)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllBooksPage(allManga: widget.allManga),
                    ),
                  );
                },
                child: Text('See All', style: TextStyle(color: AppColors.secondaryColor)),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.allManga.length,
              itemBuilder: (context, index) {
                final manga = widget.allManga[index];
                return Container(
                  width: 200,
                  child: BookCard(
                    title: manga.title,
                    chapter: 'Chapter: ${manga.chapter}',
                    coverImage: manga.coverImage,
                    isBookmarked: manga.isBookmarked,
                    onBookmarkToggle: () {
                      widget.homeViewModel.toggleBookmark(manga);
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaDetailPage(
                            manga: manga,
                            initialChapterIndex: manga.chapter - 1,
                          ),
                        ),
                      );
                    },
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
