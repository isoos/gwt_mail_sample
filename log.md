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

