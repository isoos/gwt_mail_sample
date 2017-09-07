import 'package:angular/angular.dart';
import 'package:angular_components/src/components/material_icon/material_icon.dart';
import 'package:angular_components/src/components/material_list/material_list.dart';
import 'package:angular_components/src/components/material_list/material_list_item.dart';

import 'package:gwt_mail_sample/mail/mail_service.dart';

const String defaultIconGlyph = 'mail_outline';

@Component(
  selector: 'mail-folder',
  styleUrls: const ['mail_folder.css'],
  templateUrl: 'mail_folder.html',
  directives: const [
    MaterialIconComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    COMMON_DIRECTIVES
  ],
)
class MailFolder {
  final MailService mailService;
  List<FolderItem> items = [];
  FolderItem _selected;

  MailFolder(this.mailService) {
    FolderItem root =
        new FolderItem('foo@example.com', glyph: 'home', children: [
      new FolderItem('Inbox', glyph: 'inbox'),
      new FolderItem('Drafts', glyph: 'drafts'),
      new FolderItem('Templates', glyph: 'content_paste'),
      new FolderItem('Sent', glyph: 'send'),
      new FolderItem('Trash', glyph: 'delete'),
      new FolderItem('custom-parent', children: [
        new FolderItem('child-1'),
        new FolderItem('child-2'),
        new FolderItem('child-3'),
      ]),
    ]);
    _traverseItems(root);
    selectFolder(root);
  }

  void _traverseItems(FolderItem item) {
    items.add(item);
    item?.children?.forEach(_traverseItems);
  }

  void selectFolder(FolderItem item) {
    if (_selected == item) {
      item.toggle();
    } else {
      _selected = item;
      mailService.selectFolder(item.label);
    }
  }
}

class FolderItem {
  String glyph;
  String label;
  bool isExpanded;
  FolderItem parent;
  List<FolderItem> children;

  bool get isRoot => parent == null;
  bool get isVisible => isRoot || (parent.isVisible && parent.isExpanded);

  bool get hasChildren => children?.isNotEmpty ?? false;
  bool get toggleVisible => hasChildren;
  String get toggleGlyph => isExpanded ? 'expand_more' : 'chevron_right';

  int get depth => parent == null ? 0 : parent.depth + 1;
  int get indentPx => (depth * 16) + (toggleVisible ? 0 : 40);

  FolderItem(this.label,
      {this.glyph: defaultIconGlyph, this.isExpanded: true, this.children}) {
    children?.forEach((child) {
      child.parent = this;
    });
  }

  void toggle() {
    isExpanded = !isExpanded;
  }
}
