Marking surface
===============

Make sure `window.jQuery` and `window.Raphael` are available.

BaseClass
---------

Everything extends `BaseClass`. Its constructor takes a params object and mixes in any properties it shares with the instance. It also includes jQuery's `on`, `one`, `trigger`, and `off` event methods, and a `destroy` method.

Mark
------

A `Mark` is just an hash-style object with a `set` method that fires a **change** event. In MVC terms, this is a model.

It also converts cleanly to JSON.

Custom setters can be created by extending the class and including a `set propertyName` method. Not that the name has a space in it, so wrap it in quotes.

```
class Point extends Mark
  x: 0
  y: 0

  'set x': (value) ->
    Math.min 1, Math.max 0, value
```

Tool
----

A `Tool` watches a `Mark`, calling `render` when the mark changes. In MVC terms, it is both a view and a controller.

If you need a subclass of `Mark`, you can associate it with a tool by changing the tool class's `Mark` property.

```
class PointTool extends Tool
  @Mark: Point
```

You should create all the shapes you'll need in the `initialize` method using `createShape` to ensure that events are attached properly.

```
initialize: ->
  @spot = @createShape 'circle', 0, 0, 10, 10, fill: red
```

There are a few important methods to extend:

* `onFirstClick` fires when the mouse is first pressed on the marking surface.
* `onFirstDrag` is fired when dragging during an initial click.
* `onFirstRelease` is fired when releaseing after an initial click.
* `render` should reposition the shapes according to the properties of the tool's mark.
* `select` should change the view so it's apparent that this tool is selected (e.g. a thicker stroke), `deselect` the opposite.

Events fired on a shape will be passed to `on eventName`. Again note the space.

```
'on click': ->
  alert 'Something was clicked!'
```

And each shape can have its own event handlers:

```
'on click spot': ->
  alert 'A spot was clicked!'
```

A cursor can be applied to any shape by using the `cursors` property.

```
cursors:
  spot: 'move'
```

MarkingSurface
--------------

A `MarkingSurface` is just a holder for tools. Instantiate one, and pass it a `tool` property and an optional `background` image property. Then append its `container` where you need it.

```
ms = new MarkingSurface tool: PointTool
ms.container.appendTo document.body
```

* * *

During development, run `cake serve` to run a CoffeeScript-friendly dev server and compile from **src** to **lib**.
