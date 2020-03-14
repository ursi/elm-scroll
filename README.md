# elm-scroll

`elm-scroll` lets you easily accomplish the not-so-trivial task of scrolling an element to a specific spot in a viewport, be it the main window or inside another element. The scrolling is instant. However, for browsers that support it, you can get a smooth scroll with the [`scroll-behavior`](https://www.w3.org/TR/2016/WD-cssom-view-1-20160317/#propdef-scroll-behavior) CSS property.

## Positioning

`elm-scroll` uses a relative system to specify where an element should be positioned on the screen after the scroll has taken place.

Positioning uses two numbers between `0` and `1`.

When in a vertical context, `0` represents the top and `1` represents the bottom.

When in a horizontal context, `0` represents the left and `1` represents the right.

To position an inner element relative to an outer element, a position number is specified for each. The inner element is positioned such that the two places specified by the positioning numbers line up.

For example (`outer` `inner`):
- `0` `0`: top/left align
- `0.5` `0.5`: center
- `1` `1`: bottom/right align
- `0.25 0`: top/left of the inner element is 25% of the way down/right the outer element

## Limitations

- Due to how Elm retrieves the information necessary to accomplish scrolling, performing these tasks very rapidly can cause them to not work properly, especially for the [`Element`](Scroll/#scroll-an-element) functions. If you need to adjust both the vertical and horizontal scroll position, use one of the functions that can do both at once, instead of batching a vertical and a horizontal scroll together.
- Sometimes the element can be placed a single pixel off from the desired position. This seems like a limitation on Elm's part and I'm not sure if it can be improved any further.
