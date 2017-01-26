import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

import 'package:gwt_mail_sample/contact/contact_list.dart';
import 'package:gwt_mail_sample/mail/folder/mail_folder.dart';
import 'package:gwt_mail_sample/task/task_list.dart';

// TODO: fill available space on the left
@Component(
  selector: 'side-panel',
  styleUrls: const ['side_panel.css'],
  templateUrl: 'side_panel.html',
  directives: const [ContactList, MailFolder, materialDirectives, TaskList],
  providers: const [materialProviders],
)
class SidePanel {
  String selectedPanel = 'mailboxes';

  void open(String panel) {
    selectedPanel = panel;
  }
}
