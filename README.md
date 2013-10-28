Marking surface
===============

```coffee
MarkingSurface = require 'marking-surface'
{Mark, Tool, ToolControls} = MarkingSurface
```

This is a quick overview. Read the source.

Mark
----

A `Mark` is just an hash-style object with a `set` method that fires a **change** event. In MVC terms, this is a model.

It also converts cleanly to JSON, ignoring underscore-prefixed keys.

Custom setters can be created by extending the class and including a `set propertyName` method. Not that the name has a space in it, so wrap it in quotes.

```coffee
class Point extends Mark
  x: 0
  y: 0

  'set x': (value) -> Math.min 1, Math.max 0, value
  'set y': (value) -> Math.min 1, Math.max 0, value
```

Tool
----

A `Tool` watches its instance of `Mark`, calling `render` when the mark changes. In MVC terms, it is both a view and a controller.

If you need to use a subclass of `Mark` or `ToolControls` (detailed below), you can associate them with a tool by changing the tool class's `Mark` and `Controls` property.

```coffee
class PointTool extends Tool
  @Mark: Point
  @Controls: PointControls
```

You should create all the shapes you'll need in the `initialize` method using `createShape` to ensure that events are delegated properly. `createShape` can also apply class names to new shape elements. New shape elements are added to the root `group` group, which you can use to apply global transformations.

```coffee
  initialize: ->
    @spot = @createShape 'circle.the-spot', cx: 0, cy: 0, r: 10
```

In addition to `initialize`, There are a few important methods to extend:

* `onFirstClick` fires when the mouse is first pressed on the marking surface.
* `onFirstDrag` is fired when dragging during an initial click.
* `onFirstRelease` is fired when releaseing after an initial click.
* `render` should reposition the shapes according to the properties of the tool's mark.
* `select` should change the view so it's apparent that this tool is selected (e.g. a thicker stroke), `deselect` the opposite.

Events fired on a shape will be passed to `on eventName`. Again note the space.

```coffee
  'on click': ->
    alert 'Something was clicked!'
```

And each shape can have its own event handlers:

```coffee
  'on click spot': ->
    alert 'A spot was clicked!'
```

Some special event names are `*start`, `*drag`, and `*end`, which work with mouse and touch events.

ToolControls
------------

`ToolControls` are associated with a `Tool` instance. Provide markup in the `template` property. Its `render` method is called when its tool's mark changes, and should update the markup to reflect the state of the mark. Position the controls near the tool with `moveTo`, which can be called from `render` or from the its tool's `render` method.

MarkingSurface
--------------

A `MarkingSurface` is just a holder for tools. Instantiate one, and pass it a `tool` property. Then append its `el` where you need it.

```coffee
ms = new MarkingSurface tool: PointTool
document.body.appendChild ms.el
```

* * *

During development, run `cake serve` to run a CoffeeScript-friendly dev server and compile from **src** to **lib**.
