import 'dart:html';

import 'package:angular/core.dart';

import 'package:gwt_mail_sample/nav/about/about_dialog.dart';

@Component(
  selector: 'top-panel',
  styleUrls: const ['top_panel.css'],
  templateUrl: 'top_panel.html',
  directives: const [AboutDialog],
)
class TopPanel {
  @ViewChild(AboutDialog)
  AboutDialog aboutDialog;

  void signOut(MouseEvent event) {
    event.preventDefault();
    window.alert('If this were implemented, you would be signed out now.');
  }

  void showAbout(MouseEvent event) {
    event.preventDefault();
    aboutDialog.show();
  }
}
