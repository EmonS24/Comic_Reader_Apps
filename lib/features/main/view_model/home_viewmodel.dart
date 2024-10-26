// lib/features/main/viewmodel/home_viewmodel.dart
import 'package:manga/data/repository/book_repository.dart';
import 'package:manga/data/models/manga.dart'; // Import model Manga

class HomeViewModel {
  final BookRepository bookRepository = BookRepository();

  // Mengembalikan Manga terakhir yang dibaca
  Manga getLastReadManga() {
    // Ambil manga terakhir dibaca dari repository
    return bookRepository.fetchLastReadManga();
  }

  // Mengembalikan daftar Manga yang di-bookmark
  List<Manga> getBookmarkedManga() {
    return bookRepository.fetchBookmarkedManga();
  }

  // Mengembalikan daftar semua Manga
  List<Manga> getAllBooks() {
    return bookRepository.fetchBooks();
  }
}
