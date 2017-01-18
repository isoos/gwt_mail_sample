import 'package:angular2/core.dart';

import 'package:gwt_mail_sample/nav/top/top_panel.dart';
import 'package:gwt_mail_sample/nav/side/side_panel.dart';
import 'package:gwt_mail_sample/mail/list/mail_nav_bar.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [MailNavBar, TopPanel, SidePanel],
)
class AppComponent {}
