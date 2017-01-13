# Log of migrating a GWT Mail sample app to Angular2 Dart

## Prepare the project

### Create the Angular Dart project

- create an Anuglar2 Dart project with your usual tooling
- add `angular2_components: ^0.2.2` as a dependency in `pubspec.yaml`

### Add GWT sources

Let's keep two copies of the GWT sources in the project.

The first copy in `gwt/original` will be unchanged.

The second copy in `gwt/backlog` will help us to keep track of the
current backlog of the migration: files and logic that needs to be
processed in one way or another.


## Migrate the GWT app

### Remove files that are relevant only for GWT

There are many files in our backlog that can be deleted easily:

```
- build.xml
- war/WEB-INF/*
- war/gradient_bg_th.png (duplicate)
- war/Mail.html
- c.g.g.s.m/Mail.gwt.xml
```

Before deleting, check the content in case it uses features that
need to be addressed in the Dart code.

While checking `war/Mail.html` there are a few small touches that
should be adapted (`<meta>`, `<title>`, `<noscript>`).

### Move favicon.ico to web/

- move `war/favicon.ico` -> `web/favicon.ico`

### Set global CSS styles

We create a `<link>` reference in `web/index.html` that points
to `global.css` with the few CSS styles that are outside of our
main component's scope.

- `global.gss` contains some references to `body`
- `Mail.java` sets `margin: 0px` and disables scrollbars on the outer window.

### Migrate TopPanel

- create the `TopPanel` component in `lib/nav/top/top_panel.dart` with its usual
  `html` and `css` files
- add it to the `app_component.html`: `<top-panel></top-panel>`
- reference it in the `AppComponent`'s annotation: `directives: const [TopPanel],`
- start processing `TopPanel.ui.xml`:
  - move `logo.png` to the `lib/nav/top/` directory
  - move the styles from `<ui:style>` to `top_panel.css`
  - copy the structure inside `<g:UIBinder>` to `top_panel.html`

Migrating the logo:
- the `ui:image` element becomes `<img src="..."/>`
- to reference the logo, use `src="packages/gwt_mail_sample/nav/top/logo.png"`
- add the CSS class `logo` to the element
- remove the `gwt-sprite: "logo";` from the CSS, there is no use for it

Migrating the `g:HTMLPanel`:
- the logo `div` is not used anymore as we have the `img` element above
- `class="{style.statusDiv}"` becomes `class="statusDiv"`
- the `g:Anchor` reference becomes much simpler:
  
  in the template:
  ```
    <a href="" (click)="signOut($event)">Sign Out</a>
    <a href="" (click)="showAbout($event)">About</a>
  ```
  
  in the controller (after importing `dart:html`):
  ```
  void signOut(MouseEvent event) {
  }
  void showAbout(MouseEvent event) {
  }
  ```

Implementing the actions:
- the `signOut` is simple: it calls `window.alert()`
- the `showAbout` requires the about dialog, let's leave a TODO for now

There are a few tweaks to be made:
- move the anchor-related (`a`) styles to global.css
- in both method, add `event.preventDefault();`, because we don't want to
  have a place change when the user clicks on them

### Migrate AboutDialog

- create the `AboutDialog` component in `lib/nav/about/about_dialog.dart`
  with its usual `html` and `css` files
- move `gwt-logo.png` to the same directory
- move the `.logo` style from `AboutDialog.ui.xml` into
  `about_dialog.css` (without the `gwt-sprite` attribute)
- the rest of the styling and Java code is better served with
  a clean re-implementation with the material modal dialog component

To reference the about dialog:
- put `<about-dialog></about-dialog>` in `top_panel.html` and add the
  directive and a `@ViewChild` reference to the controller class:
  
  ```
  @Component(
    directives: const [AboutDialog],
  ```
  
  ```
  @ViewChild(AboutDialog)
  AboutDialog aboutDialog;
  ```
  
  This will inject a reference of the about dialog's controller
  into the top panel, making it straightforward to display it
  when needed.

To get started with the material model dialog, take a look into
the [Angular component examples](https://github.com/dart-lang/angular2_components_example/).
Using the headered dialog example provided 95% of the functionality,
with the following tweaks:
- the dialog's maximum width is set to 60% via CSS
- `*ngIf="visible"` is used to lazily initialize the dialog
- the `gwt-logo.png` is referenced by the `packages/...` resource path
  with the `logo` CSS class
  
  There is no conflict, the same CSS class name can be used in
  separate components (e.g. `logo` both here and in `TopPanel`),
  because Angular generates scoping rules for each of them.

### Migrate Shortcuts

The left-side menu (Shortcuts) resembles the expansion panel
component, however it requires several customization. 

- create the `SidePanel` component in `lib/nav/side/side_panel.dart`
  with its usual `html` and `css` files
- move `contactsgroup.png`, `mailboxesgroup.png`, `tasksgroup.png` and
  `gradient_bg_dark.png` to the same directory
- add the component to `AppComponent`:
  - `<side-panel>` to the template
  - `SidePanel` to the `directives` annotation
  - position it to the right (e.g. floating with `max-width: 250px`)
- migrate the CSS styles from `Shortcuts.ui.xml`:
  - `.shortcuts` becomes `:host`
  - `.stackHeader` becomes `:host-context header`
  - add a bit margin for the `.content`

- For each of the panels, a template like this covers the functionality,
  repeat it for tasks and contacts:
  
  ```
  <material-expansionpanel
      flat
      [showSaveCancel]="false"
      [expanded]="selectedPanel == 'mailboxes'"
      (open)="open('mailboxes')"
      (close)="close($event, 'mailboxes')">
    <div name>
      <img src="packages/gwt_mail_sample/nav/side/mailboxesgroup.png" />
      Mailboxes
    </div>
    <div class="content">TODO: add tree of mailboxes.</div>
  </material-expansionpanel>
  ```

- In the component:
  
  ```
    String selectedPanel = 'mailboxes';
    void open(String panel) {
      selectedPanel = panel;
    }
    void close(AsyncAction action, String panel) {
      if (panel == selectedPanel) action.cancel();
    }
  ```
<<<<<<< HEAD
  
  - `String selectedPanel = 'mailboxes';` to keep track of the
    currently selected and active panel
  - the close event ensures that only the panel's self-close gets cancelled. 
=======

### Migrate Tasks

The task list is a static component without any real binding. In the
following code we will re-implement it in a way that the list becomes
dynamic, and the checked state of the tasks are bound to a real field.

- create the `TaskList` component in `lib/task/task_list.dart`
  with its usual `html`, but without any `css` files (no extra styling
  required)
- reference it in `SidePanel`'s directives list and template
- the backing task object can be as simple as:
  
  ```
  class TaskItem {
    String label;
    bool isDone;
    TaskItem(this.label, {this.isDone: false});
  }
  ```
- put a list of these in our component:
  
  ```
  class TaskList {
    List<TaskItem> items = [
      new TaskItem('Get groceries'),
      new TaskItem('Walk the dog'),
    // ...
  }
  ```
- bind it with `*ngFor` in the template (using material checkbox):
  
  ```
  <div *ngFor="let item of items">
    <material-checkbox
      [(checked)]="item.isDone"
      [label]="item.label"></material-checkbox>
  </div>
  ```
>>>>>>> 25433f9... Migrate Tasks

### Migrate Contacts

- create the `ContactList` component in `lib/contact/contact_list.dart`
  with its usual `html` and `css` files
- move `default_photo.jpg` to the same directory
- move the `.contacts` CSS styles from `Contacts.ui.xml` to `contact_list.css`
- move the `.popup`, `.photo`, `.right`, and `.email` CSS styles from
  `ContactPopup.ui.xml` to `contact_list.css` (remove `gwt-sprite: "photo";`) 
- create a const to point to it:
  
  ```
  const String defaultPhotoUrl =
      'packages/gwt_mail_sample/contact/default_photo.jpg';
  ```
- reference it in `SidePanel`'s directives list and template

Similarly to the `TaskList` component, we'll create a backing component,
we'll create a backing object to drive the template:

- the backing contact object:
  
  ```
  class ContactItem {
    String name;
    String email;
    String photoUrl;
    ContactItem(this.name, this.email, {this.photoUrl: defaultPhotoUrl});
  }
  ```
- the list of these items in the main component:
  
  ```
  class ContactList {
    List<ContactItem> items = [
      new ContactItem('Benoit Mandelbrot', 'benoit@example.com'),
      new ContactItem('Albert Einstein', 'albert@example.com'),
      // ...
    ];
  ```
- bind it with `*ngFor` in the template
  
  ```
  <div class="contacts">
    <div *ngFor="let item of items">
      <a href="" (click)="showPopup($event, item)">{{item.name}}</a>
    </div>
  </div>
  ```
- implement the skeleton of the `showPopup` method:
  
  ```
    ContactItem selected;
    
    void showPopup(MouseEvent event, ContactItem item) {
      selected = item;
      event.preventDefault();
    }
  ```

The material popup component requires a bit of preparation:
- both the `source` and `visible` needs to be bound:
  
  ```
  <material-popup
      *ngIf="popupVisible"
      [source]="popupSource"
      [(visible)]="popupVisible">
  ```
  
  Note: using the same `popupVisible` flag to create it has
  the added benefit of automatic cleanup after closing/hiding it.
- the controller needs to initialize these fields:
  ```
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
  ```
  
  The positioning with `(+14, +14)` offset is coming from `Contacts.java`.
- migrate the template from `ContactPopup.ui.xml` and put it inside
  the `<material-popup>` element:
  
  ```
    <div class="popup">
      <img [src]="selected.photoUrl" class="photo"/>
      <div class="right">
        <div>{{selected.name}}</div>
        <div class="email">{{selected.email}}</div>
      </div>
    </div>
  ```

### Migrate Mailboxes

- create the `MailFolder` component in `lib/mail/folder/mail_folder.dart`
  with its usual `html` and `css` files
- move the `drafts.png`, `home.png`, `inbox.png`, `noimage.png`,
  `sent.png`, `templates.png`, and `trash.png` to the same directory
- reference it in `SidePanel`'s directives list and template

While the GWT implementation uses a heavyweight tree component, the
mailbox tree can be modeled and built on top of `*ngFor` with some
additional logic:
- a `FolderItem` needs to keep track of some fields:
  
  ```
  class FolderItem {
    String iconUrl;
    String label;
    bool isSelected = false;
  }
  ```
- to make it into a tree, one needs to keep track of the `parent and `children`
  
  ```
    bool isExpanded;
    FolderItem parent;
    List<FolderItem> children;
  ```
- an item is visible if and only if all of its ancestors are visible and expanded:
  
  ```
    bool get isRoot => parent == null;
    bool get isVisible => isRoot || (parent.isVisible && parent.isExpanded);
  ```
- open/close toggle buttons are visible only if it has children:
  
  ```
    bool get hasChildren => children?.isNotEmpty ?? false;
    bool get expandVisible => hasChildren && !isExpanded;
    bool get collapseVisible => hasChildren && isExpanded;
  ```
- to preserve the tree-like visual layout, one needs to indent based on the depth of the item:
  
  ```
    int get depth => parent == null ? 0 : parent.depth + 1;
    int get indentPx => depth * 16;
  ```
- build the tree of the sample inbox folders:
  ```
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
  ```
  
  Note: make sure the constructor sets the `parent` field of the `children`.
- traverse the tree into a flattened list:
  ```
  List<FolderItem> items = [];
  
  void _traverseItems(FolderItem item) {
    items.add(item);
    item?.children?.forEach(_traverseItems);
  }
  
  _traverseItems(root);
  ```
- the template should be a combination of list iteration with visibility check:
  
  ```
  <div *ngFor="let item of items">
    <div *ngIf="item.isVisible" class="item">
      <!-- here comes the content -->
    </div>
  </div>
  ```
- the `.item` CSS style is a flexbox which renders the following
  blocks as they were table rows
- indentation is a simple padding:
  
  ```
  <div [style.width.px]="item.indentPx">&nbsp;</div>
  ```
- the tree controls (`+` and `-`) is handled by the following template:
  ```
  <div class="toggle">
    <span *ngIf="item.expandVisible" (click)="item.toggle()">&#x2795;</span>
    <span *ngIf="item.collapseVisible" (click)="item.toggle()">	&#x2796;</span>
  </div>
  ```
  
  and code:
  ```
  void toggle() {
    isExpanded = !isExpanded;
  }
  ```
- put there an icon
  ```
  <img [src]="item.iconUrl" class="icon"/>
  ```
  
  and the label:
  ```
  <div [class.selected]="item.isSelected"
       (click)="selectFolder(item)">{{item.label}}</div>
  ```
- implement the `selectFolder` method:
  - _deselect_ the previously selected item
  - store the current one and set its `isSelected` flag

With that, we have a simplified tree component that:
- looks and works like a tree (indentation and tree controls)
- supports custom icons and styles
- keep track of a single selected item (which can later trigger the loading the list of messages for that e-mail folder)

