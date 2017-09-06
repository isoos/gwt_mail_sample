import 'package:angular/angular.dart';
import 'package:angular_components/src/components/material_button/material_button.dart';
import 'package:angular_components/src/components/material_dialog/material_dialog.dart';
import 'package:angular_components/src/laminate/components/modal/modal.dart';

@Component(
  selector: 'about-dialog',
  styleUrls: const ['about_dialog.css'],
  templateUrl: 'about_dialog.html',
  inputs: const ['visible'],
  directives: const [
    MaterialButtonComponent,
    MaterialDialogComponent,
    ModalComponent,
    COMMON_DIRECTIVES
  ],
)
class AboutDialog {
  bool visible = false;

  void show() {
    visible = true;
  }
}
