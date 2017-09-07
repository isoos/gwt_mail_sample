import 'dart:async';

class MailItem {
  final String sender;
  final String email;
  final String subject;
  final String body;

  MailItem(this.sender, this.email, this.subject, this.body);
}

abstract class MailService {
  /// the label of the currently selected folder
  String get selectedFolder;

  /// the total number of mail items in the current folder
  int get mailCount;

  /// the index of the current page
  int get pageIndex;

  /// the number of pages
  int get pageCount;

  /// the maximum number of mail items on a given page
  int get pageSize;

  /// the loaded mail items on the current page
  List<MailItem> get pageItems;

  /// the selected mail that needs to be displayed
  MailItem selectedItem;

  /// selects a folder by its label
  Future selectFolder(String label);

  /// selects the next page
  Future nextPage();

  /// selects the previous page
  Future prevPage();
}
