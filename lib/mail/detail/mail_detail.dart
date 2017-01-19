import 'package:angular2/core.dart';

import 'package:gwt_mail_sample/mail/mail_service.dart';

@Component(
  selector: 'mail-detail',
  styleUrls: const ['mail_detail.css'],
  templateUrl: 'mail_detail.html',
)
class MailDetail {
  MailService mailService;

  String get subject => mailService.selectedItem?.subject;
  String get sender => mailService.selectedItem?.sender;
  String get recipient => 'foo@example.com';
  String get body => mailService.selectedItem?.body;

  MailDetail(this.mailService);
}
