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


### Handle e-mail data (MailItems)

In the GWT application, the list of e-mails is stored in `MailItems.java`
as a static field, and it is generated in a consistent way. The mail-related
components access it though the static methods.

This approach makes testing, mocking and encapsulation harder, and instead,
we'll use an injected service to achieve better coupling.

- create `lib/mail/mail_service.dart`
- migrate `MailItem.java` and create the following data holder class:
  
  ```
  class MailItem {
    String sender;
    String email;
    String subject;
    String body;
  
    MailItem(this.sender, this.email, this.subject, this.body);
  }
  ```
- create the service interface:
  
  ```
  abstract class MailService {
  }
  ```
- add folder selection:
  
  ```
    String get selectedFolder;
    Future selectFolder(String label);
  ```
  
  `selectFolder` is an asynchronous method that returns with a `Future`,
  which will complete once the service completes loading the first page.
- add information about the current folder:
  
  ```
    int get mailCount;
    List<MailItem> get pageItems;
  ```
- add pagination information and page switching methods:
  
  ```
    int get pageIndex;
    int get pageCount;
    int get pageSize;
    Future nextPage();
    Future prevPage();
  ```
  
  Similarly to the above, the methods complete when the service finishes
  loading the mail items.

The next step is to create a mock `MailService` implementation:
- create `lib/mail/mock_mail_service.dart` and start implementing the
  previously create interface:
  - keep track of the `selectedFolder`, `mailCount`, `pageIndex`,
    `pageCount` and `pageItems` properties as private fields 
  - hardcode `int get pageSize => 20` for simplicity
- copy the prepared values from `MailItems.java` into private
  top-level fields (some values need to be fixed, e.g. escape `$` signs)
- redirect all async methods to a single mail item generator:
  
  ```
    Future nextPage() => _generateItems(selectedFolder, pageIndex + 1);
    Future prevPage() => _generateItems(selectedFolder, pageIndex - 1);
    Future selectFolder(String label) => _generateItems(label, 0);
  
    Future _generateItems(String label, int newPageIndex) async {
    }
  ```

To implement the `_generateItems` method, follow similar logic as
in `MailItems.createFakeMail()`, with the following additions:
- initialize e-mail count based on the `label`'s hash
- check if `page` is valid for that count and reset to `0` if needed
- calculate how many items needs to be on the page and generate them
- use `label`, `_pageIndex, and `index` (on page) to initialize the
  "random" pointers when creating a new mail item

To make it available for components through injection, register it
in `main.dart` as a provided service. Note that the we register the
abstract interface, and provide a concrete instance that implements it:

```
main() {
  bootstrap(AppComponent, [
    new Provider(MailService, useValue: new MockMailService()),
  ]);
}
```

Injecting it into the `MailFolder` component requires a small change
in the constructor:

```
class MailFolder {
  final MailService mailService;
  MailFolder(this.mailService) {
  // ...
```

Add its use to the `selectFolder` method:

```
  void selectFolder(FolderItem item) {
    // ...
    mailService.selectFolder(item.label);
  }
```

### Migrate NavBar

Assuming e-mail is always ordered by descending date, the `older >`
and `< newer` buttons in the NavBar can be easily matched with the
`MailService`'s `nextPage()` and `prevPage()` methods:

- create the `MailNavBar` component in `lib/mail/list/mail_nav_bar.dart`
  with its usual `html` and `css` files
- add the component to `AppComponent`:
  - `<mail-navbar>` to the template
  - `MailNavBar` to the `directives` annotation
- inject the `MailService` into this new component
- create a very simple template like:
  
  ```
  <material-button dense *ngIf="hasNewer" (click)="newer()">&lt; newer</material-button>
  {{start}}-{{end}} of {{total}}
  <material-button dense [disabled]="!hasOlder" (click)="older()">older &gt;</material-button>
  ```
  
  Note: while the newer button becomes visible only after the first page,
  the older button is always there, but may be disabled. That way the
  height of the component doesn't change if neither of them is visible.
- implement the above field and methods like the following:
  
  ```
    int get total => mailService.mailCount;
    bool get hasNewer => mailService.pageIndex > 0;
    bool get hasOlder => end < total;
    
    void newer() {
      mailService.prevPage();
    }
  ```
- adapt the `.anchor` CSS style from `NavBar.ui.xml` and
  apply it on `material-button`

# Migrate MailList

As we don't have a full-blown open source material table yet,
we will fill in the gap with `*ngFor` and some styling.

- create the `MailList` component in `lib/mail/list/mail_list.dart`
  with its usual `html` and `css` files
- inject the `MailService` into this new component

Add the component to `AppComponent`, and at the same time remove
the `MailNavBar` from it (we'll add it to the header of the list):
- `<mail-list>` to the template
- `MailList` to the `directives` annotation
- use a new CSS style in a `div` to position the mail list component:
  
  ```
  .right-side {
    margin-left: 260px;
  }
  ```

Adapt the style properties for the table, mixing new ones with
`MailList.ui.xml`:
- create `.table` style to set the outer border
- use `.row` with flexbox to create tabular layout
- set fixed width for the `sender` and `email` columns, restrict their size increase (`flex-grow: 0`)
- set padding for the columns
- set background shade and gradient for the `.header`
- set different background for hovering and for the selected row
- introduce a content area where rows are going to be scrolled:
  
  ```
  .content {
    height: 200px;
    overflow: auto;
    cursor: pointer;
  }
  ```

Create the base layout of the table:

```
<div class="table">
  <div class="header">
    <div class="row">
      <div class="col sender">Sender</div>
      <div class="col email">Email</div>
      <div class="col subject">
        Subject
      </div>
      <mail-nav-bar></mail-nav-bar>
    </div>
  </div>
  <div class="content">
    <div *ngFor="let item of items"
         class="row"
         (click)="selectRow(item)"
         [class.selected]="isSelectedRow(item)">
      <div class="col sender">{{item.sender}}</div>
      <div class="col email">{{item.email}}</div>
      <div class="col subject">{{item.subject}}</div>
    </div>
  </div>
</div>
```

The `items` can be a simple pass-through:

```
  List<MailItem> get items => mailService.pageItems;
```

To align the `mail-nav-bar` to the right, use some additional styling:

```
mail-nav-bar {
  display: block;
  text-align: right;
  flex-grow: 1;
}
```

In the simplest case `isSelectedRow` and `selectRow` could be implemented
by introducing a new `MailItem selected` field in the component, but we
know that we want to expose the same instance in the `MailDetail`, a
component that we'll build in the next step.

One way to share the data between the two is to place the field inside
`MailService`, and update it each time the mailbox folder or the pagination
changes:

```
  void selectRow(MailItem item) {
    mailService.selectedItem = item;
  }

  bool isSelectedRow(MailItem item) => mailService.selectedItem == item;
```

### Migrate MailDetail

- create the `MailDetail` component in `lib/mail/detail/mail_detail.dart`
  with its usual `html` and `css` files
- inject the `MailService` into this new component
- add the component to `AppComponent`:
  - `<mail-detail>` to the template
  - `MailDetail` to the `directives` annotation
- copy most of the styling from `MailDetail.ui.xml`
- migrate the template, it will be roughly as simple as:
  
  ```
  <div class="detail">
    <div class="header">
      <div class="headerItem">{{subject}}</div>
      <div class="headerItem"><b>From: </b>{{sender}}</div>
      <div class="headerItem"><b>To: </b>{{recipient}}</div>
    </div>
    <div class="body" [innerHTML]="body"></div>
  </div>
  ```
- the fields shall be delegates:
  
  ```
    String get subject => mailService.selectedItem?.subject;
    String get sender => mailService.selectedItem?.sender;
    String get recipient => 'foo@example.com';
    String get body => mailService.selectedItem?.body;
  ```
- add margin and overflow CSS properties

### Clean GWT backlog

Check the remaining files, but everything should have been migrated
and they are safe to remove.

- replace the GWT logos with the Dart logo

### Make the design fresh

- update borders with a light-gray version (`rgba(0,0,0,0.12)`)
- remove the dark gradient background from headers, make it much lighter
- remove `text-shadow` styles
- increase global font size (11pt)
- use more whitespace and a nicer hovering effect in side menus
- add ripple to the mail item selection
- don't hide the 'newer' button, disable instead
- add proper site name to the top nav, remove logo overlap
- add link to the source code in the top nav
- replace icons in side panel with material glyphs
- replace icons in mail folder with material glyphs (and migrate to the new list widget)
- let the side panel to be collapsed

### Resize panels on dragging the resizer between them

In the absence of layout- or docking panels, we can keep track of
our panels' desired dimension and bind it to the appropriate CSS property.

- in `MailList` component create a new property:
  
  ```
    @Input()
    int height = 200;
  ```

- bind it to the height CSS:
  
  ```
  <div class="content" [style.height.px]="height">
  ```
  
  Note: at this point the `height: 200px` can be removed from the CSS.

- create three flex-based panel list in `AppComponent`:
  - one for the top (with fixed height) and the rest
  - one for the side panel (with a resizer) and the rest of mail panels
  - one for the separation of `mail-list` and `mail-detail`

- create new fields for the dimensions:
  
  ```
    int sideWidthPx = 250;
    int mailHeightPx = 250;
  ```

- bind their values to the components:
  
  ```
  <side-panel [style.flex-basis.px]="sideWidthPx"></side-panel>
  <mail-list [height]="mailHeightPx"></mail-list>
  ```

- Handling the resize can be implemented by listening on `mousedown`
  events, and on each of these, track the `mousemove` and `mouseup`
  on the `document` Element. For example:
  
  ```
    <div class="side-resizer" (mousedown)="resizeSide($event)"></div>
  ```
  
  ```
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
  ```

- set the appropriate mouse cursor on the `-resizer` styles

### Stretch the components to fill the available space

The internal scroll handling (`overflow:auto`) of the components
doesn't make it easy to stretch the components to fill the screen.
Instead, we can monitor the layout with `DomService` and act on any
event the affects the layout.

The following guide is for `MailDetail`, implement a similar
mechanism for `SidePanel`:

- Annotate the bottommost `div` with `#bottom` (or create a new one at
  the end of the html template):
  
  ```
  <div #bottom></div>
  ```

- Make sure it is injected into the component:
  
  ```
    @ViewChild('bottom')
    ElementRef bottomRef;
  ```

- Initialize a height value for the content area, and calculate the
  gap (the difference that it needs to add to the value):
  
  ```
    int heightPx = 200;
    
    int _calculateGap() {
      Element element = bottomRef.nativeElement;
      int bottom = element.offsetTop + element.offsetHeight;
      return window.innerHeight - bottom;
    }
  ```

- Import and inject `DomService`. It is a useful utility that enables
  very efficient (and forced relayout-free) tracking of changes on
  the UI.

- Implement `AfterContentInit` and `OnDestroy` on the component class.
  On initialization we subscribe to layout tracking, and on destroy the
  subscription needs be cleared up:
  
  ```
    StreamSubscription _layoutSubscription;
    
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
  ```

- Bind the height value in the template:
  
  ```
  <div class="body" [innerHTML]="body" [style.height.px]="heightPx"></div>
  ```

### Trim down the generated code size

Developing the application and working with the material components was
was easy, because we did import everything available, like the following code:

```
import 'package:angular2_components/angular2_components.dart';

@Component(
  // ...
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
```

But the convenience has it price: it prevents proper tree-shaking, and the
`dart2js` compiler won't be able to decide which components need to be
included in final build. To make it easier for the tools, as a last step, we
shall clear up our dependencies, and only import the directly used ones:

```
import 'package:angular2_components/src/components/material_popup/material_popup.dart';
import 'package:angular2_components/src/laminate/popup/popup.dart';

@Component(
  // ...
  directives: const [MaterialPopupComponent],
)
```

Guiding tree-shaking with the above approach helps to remove a good chunk
of unused code. In addition to that, we can fine-tune the `dart2js` compilation
with additional command line attributes in the `pubspec.yaml`:

```
- $dart2js:
     commandLineOptions: [--trust-type-annotations --trust-primitives]
```

