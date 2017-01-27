import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'package:gwt_mail_sample/mail/mail_service.dart';
import 'package:gwt_mail_sample/mail/list/mail_nav_bar.dart';

@Component(
  selector: 'mail-list',
  styleUrls: const ['mail_list.css'],
  templateUrl: 'mail_list.html',
  directives: const [materialDirectives, MailNavBar],
  providers: const [materialProviders],
)
class MailList {
  MailService mailService;

  @Input()
  int height = 200;

  List<MailItem> get items => mailService.pageItems;

  MailList(this.mailService);

  void selectRow(MailItem item) {
    mailService.selectedItem = item;
  }

  bool isSelectedRow(MailItem item) => mailService.selectedItem == item;
}
