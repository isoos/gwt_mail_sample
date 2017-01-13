import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

const String baseUrl = 'packages/gwt_mail_sample/mail/folder';
const String defaultIconUrl = '${baseUrl}/noimage.png';

@Component(
  selector: 'mail-folder',
  styleUrls: const ['mail_folder.css'],
  templateUrl: 'mail_folder.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class MailFolder {
  List<FolderItem> items = [];
  FolderItem _selected;

  MailFolder() {
    FolderItem root = new FolderItem('foo@example.com',
        iconUrl: '$baseUrl/home.png',
        children: [
          new FolderItem('Inbox', iconUrl: '$baseUrl/inbox.png'),
          new FolderItem('Drafts', iconUrl: '$baseUrl/drafts.png'),
          new FolderItem('Templates', iconUrl: '$baseUrl/templates.png'),
          new FolderItem('Sent', iconUrl: '$baseUrl/sent.png'),
          new FolderItem('Trash', iconUrl: '$baseUrl/trash.png'),
          new FolderItem('custom-1', children: [
            new FolderItem('custom-1-1'),
            new FolderItem('custom-1-2'),
            new FolderItem('custom-1-3'),
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
    _selected?.isSelected = false;
    item.isSelected = true;
    _selected = item;
  }
}

class FolderItem {
  String iconUrl;
  String label;
  bool isSelected = false;
  bool isExpanded;
  FolderItem parent;
  List<FolderItem> children;

  bool get isRoot => parent == null;
  bool get isVisible => isRoot || (parent.isVisible && parent.isExpanded);

  bool get hasChildren => children?.isNotEmpty ?? false;
  bool get expandVisible => hasChildren && !isExpanded;
  bool get collapseVisible => hasChildren && isExpanded;

  int get depth => parent == null ? 0 : parent.depth + 1;
  int get indentPx => depth * 16;

  FolderItem(this.label,
      {this.iconUrl: defaultIconUrl,
      this.isExpanded: true,
      List<FolderItem> this.children}) {
    children?.forEach((child) {
      child.parent = this;
    });
  }

  void toggle() {
    isExpanded = !isExpanded;
  }
}
