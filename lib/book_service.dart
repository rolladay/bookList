import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'book.dart';
import 'main.dart';

//BookService 클래스는 일단 bookList라는 리스트를 가지고 있고 서치함수를 이용해 리스트에 정보를 저장한다
class BookService extends ChangeNotifier {

  BookService() {
    loadLikedBookList();
  }

  List<Book> bookList = []; // 책 목록
  List<Book> likedBookList = [];



  void toggleLikeBook({required Book book}) {
    String bookId = book.id;
    if (likedBookList.map((book) => book.id).contains(bookId)) {
      likedBookList.removeWhere((book) => book.id == bookId);
    } else {
      likedBookList.add(book);
    }
    notifyListeners();
    saveLikedBookList();
    print(likedBookList);
  }

  void search(String q) async {
    bookList.clear(); // 검색 버튼 누를때 이전 데이터들을 지워주기

    Dio dio = Dio();
    if (q.isNotEmpty) {
      Response res = await dio.get(
        "https://www.googleapis.com/books/v1/volumes?q=$q&startIndex=0&maxResults=40",
      );
      List items = res.data["items"];

      for (Map<String, dynamic> item in items) {
        Book book = Book(
          id: item['id'],
          title: item['volumeInfo']['title'] ?? "",
          subtitle: item['volumeInfo']['subtitle'] ?? "",
          thumbnail: item['volumeInfo']['imageLinks']?['thumbnail'] ??
              "https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132482953.jpg",
          previewLink: item['volumeInfo']['previewLink'] ?? "",
          authors: item['volumeInfo']['authors'] ?? [].join(", "),
          publishedDate: item['volumeInfo']['publishedDate'] ?? "",
        );
        bookList.add(book);
        //만든 book 객체를 계속 bookList에 추가하는 for문
      }
    }
    notifyListeners();
  }

  saveLikedBookList() {
    List likedBookJsonList =
    likedBookList.map((book) => book.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(likedBookJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('likedBookList', jsonString);
  }

  loadLikedBookList() {
    String? jsonString = prefs.getString('likedBookList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List likedBookJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    likedBookList =
        likedBookJsonList.map((json) => Book.fromJson(json)).toList();
  }

}
