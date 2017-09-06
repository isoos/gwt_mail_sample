import 'dart:math' show min;

import 'package:angular/core.dart';
import 'package:angular_components/src/components/material_button/material_button.dart';

import 'package:gwt_mail_sample/mail/mail_service.dart';

@Component(
  selector: 'mail-nav-bar',
  styleUrls: const ['mail_nav_bar.css'],
  templateUrl: 'mail_nav_bar.html',
  directives: const [MaterialButtonComponent],
)
class MailNavBar {
  MailService mailService;

  int get _pageOffset => mailService.pageIndex * mailService.pageSize;
  int get total => mailService.mailCount;
  int get start => min(_pageOffset + 1, total);
  int get end => min(_pageOffset + mailService.pageSize, total);

  bool get hasNewer => mailService.pageIndex > 0;
  bool get hasOlder => end < total;

  MailNavBar(this.mailService);

  void newer() {
    mailService.prevPage();
  }

  void older() {
    mailService.nextPage();
  }
}
