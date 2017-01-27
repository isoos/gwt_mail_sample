import 'dart:async';
import 'dart:html';
import 'dart:math' show max;

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

// TODO: use a non-private implementation
import 'package:angular2_components/src/utils/browser/dom_service/dom_service.dart';

import 'package:gwt_mail_sample/contact/contact_list.dart';
import 'package:gwt_mail_sample/mail/folder/mail_folder.dart';
import 'package:gwt_mail_sample/task/task_list.dart';

@Component(
  selector: 'side-panel',
  styleUrls: const ['side_panel.css'],
  templateUrl: 'side_panel.html',
  directives: const [ContactList, MailFolder, materialDirectives, TaskList],
  providers: const [materialProviders],
)
class SidePanel implements AfterContentInit, OnDestroy {
  DomService domService;
  StreamSubscription _layoutSubscription;

  String selectedPanel = 'mailboxes';

  @ViewChild('bottom')
  ElementRef bottomRef;

  int heightPx = 200;

  SidePanel(this.domService);

  void open(String panel) {
    selectedPanel = panel;
  }

  @override
  ngAfterContentInit() {
    _layoutSubscription =
        domService.trackLayoutChange(_calculateGap, (int gap) {
      heightPx = max(10, heightPx + gap);
    }, runInAngularZone: true);
  }

  @override
  ngOnDestroy() {
    _layoutSubscription?.cancel();
    _layoutSubscription = null;
  }

  int _calculateGap() {
    Element element = bottomRef.nativeElement;
    int bottom = element.offsetTop + element.offsetHeight;
    return window.innerHeight - bottom;
  }
}
