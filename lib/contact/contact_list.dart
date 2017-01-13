import 'dart:html';

import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

const String defaultPhotoUrl =
    'packages/gwt_mail_sample/contact/default_photo.jpg';

@Component(
  selector: 'contact-list',
  styleUrls: const ['contact_list.css'],
  templateUrl: 'contact_list.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class ContactList {
  List<ContactItem> items = [
    new ContactItem('Benoit Mandelbrot', 'benoit@example.com'),
    new ContactItem('Albert Einstein', 'albert@example.com'),
    new ContactItem('Rene Descartes', 'rene@example.com'),
    new ContactItem('Bob Saget', 'bob@example.com'),
    new ContactItem('Ludwig von Beethoven', 'ludwig@example.com'),
    new ContactItem('Richard Feynman', 'richard@example.com'),
    new ContactItem('Alan Turing', 'alan@example.com'),
    new ContactItem('John von Neumann', 'john@example.com'),
  ];

  ContactItem selected;
  PopupSource popupSource;
  bool popupVisible = false;

  void showPopup(MouseEvent event, ContactItem item) {
    selected = item;
    event.preventDefault();
    popupVisible = true;
    Element element = event.currentTarget;
    Point p = new Point(element.offsetLeft + 14, element.offsetTop + 14);
    popupSource = new PopupSource.fromRectangle(new Rectangle.fromPoints(p, p));
  }
}

class ContactItem {
  String name;
  String email;
  String photoUrl;
  ContactItem(this.name, this.email, {this.photoUrl: defaultPhotoUrl});
}
