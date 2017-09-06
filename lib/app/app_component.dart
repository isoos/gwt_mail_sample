import 'dart:async';
import 'dart:html';
import 'dart:math' show min, max;

import 'package:angular/core.dart';
import 'package:angular_components/src/laminate/popup/module.dart';

import 'package:gwt_mail_sample/nav/top/top_panel.dart';
import 'package:gwt_mail_sample/nav/side/side_panel.dart';
import 'package:gwt_mail_sample/mail/detail/mail_detail.dart';
import 'package:gwt_mail_sample/mail/list/mail_list.dart';

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [MailDetail, MailList, TopPanel, SidePanel],
  providers: const [popupBindings],
)
class AppComponent {
  int sideWidthPx = 250;
  int mailHeightPx = 250;

  void resizeSide(MouseEvent down) {
    int originX = down.client.x;
    int originWidth = sideWidthPx;
    StreamSubscription subscription =
        document.onMouseMove.listen((MouseEvent move) {
      move.preventDefault();
      move.stopPropagation();
      int newWidth = originWidth + move.client.x - originX;
      sideWidthPx = max(200, min(newWidth, 500));
    });
    document.onMouseUp.first.then((MouseEvent up) {
      subscription.cancel();
    });
  }

  void resizeMail(MouseEvent down) {
    int originY = down.client.y;
    int originHeight = mailHeightPx;
    StreamSubscription subscription =
        document.onMouseMove.listen((MouseEvent move) {
      move.preventDefault();
      move.stopPropagation();
      int newWidth = originHeight + move.client.y - originY;
      mailHeightPx = max(150, min(newWidth, 500));
    });
    document.onMouseUp.first.then((MouseEvent up) {
      subscription.cancel();
    });
  }
}
