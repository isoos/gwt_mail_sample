import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

@Component(
  selector: 'about-dialog',
  styleUrls: const ['about_dialog.css'],
  templateUrl: 'about_dialog.html',
  inputs: const['visible'],
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class AboutDialog {
  bool visible = false;

  void show() {
    visible = true;
  }
}
