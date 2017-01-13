import 'package:angular2/core.dart';
import 'package:angular2_components/angular2_components.dart';

@Component(
  selector: 'task-list',
  templateUrl: 'task_list.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class TaskList {
  List<TaskItem> items = [
    new TaskItem('Get groceries'),
    new TaskItem('Walk the dog'),
    new TaskItem('Start Web 2.0 company'),
    new TaskItem('Write an app in GWT'),
    new TaskItem('Migrate GWT to Angular2 Dart', isDone: true),
    new TaskItem('Get funding'),
    new TaskItem('Take a vacation'),
  ];
}

class TaskItem {
  String label;
  bool isDone;
  TaskItem(this.label, {this.isDone: false});
}
