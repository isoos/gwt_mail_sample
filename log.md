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
