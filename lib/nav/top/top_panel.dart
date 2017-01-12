import 'dart:html';

import 'package:angular2/core.dart';

@Component(
  selector: 'top-panel',
  styleUrls: const ['top_panel.css'],
  templateUrl: 'top_panel.html',
)
class TopPanel {
  void signOut(MouseEvent event) {
    event.preventDefault();
    window.alert('If this were implemented, you would be signed out now.');
  }

  void showAbout(MouseEvent event) {
    event.preventDefault();
    // TODO: show the about dialog, centered
  }
}
