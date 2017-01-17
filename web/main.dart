import 'package:angular2/di.dart';
import 'package:angular2/platform/browser.dart';

import 'package:gwt_mail_sample/app/app_component.dart';
import 'package:gwt_mail_sample/mail/mail_service.dart';
import 'package:gwt_mail_sample/mail/mock_mail_service.dart';

main() {
  bootstrap(AppComponent, [
    new Provider(MailService, useValue: new MockMailService()),
  ]);
}
