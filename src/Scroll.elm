module Scroll exposing
    ( scrollY, scrollX, scroll
    , scrollYWithOffset, scrollXWithOffset, scrollWithOffset
    , scrollElementY, scrollElementX, scrollElement
    , scrollElementYWithOffset, scrollElementXWithOffset, scrollElementWithOffset
    )

{-|


# Scroll the Window

@docs scrollY, scrollX, scroll
@docs scrollYWithOffset, scrollXWithOffset, scrollWithOffset


# Scroll an Element

@docs scrollElementY, scrollElementX, scrollElement
@docs scrollElementYWithOffset, scrollElementXWithOffset, scrollElementWithOffset

-}

import Browser.Dom as Dom exposing (Error)
import Task exposing (Task)



-- 'roundFloat' is used to improve accuracy, as the floats end up getting truncated.


{-|

    scrollY
        elementId
        windowPositionNumber
        elementPositionNumber

-}
scrollY : String -> Float -> Float -> Task Error ()
scrollY id outerPos innerPos =
    Task.map2
        (\{ viewport } { element } ->
            Dom.setViewport
                viewport.x
                (element.y
                    + element.height
                    * innerPos
                    - viewport.height
                    * outerPos
                    |> roundFloat
                )
        )
        Dom.getViewport
        (Dom.getElement id)
        |> Task.andThen identity


{-|

    scrollX
        elementId
        windowPositionNumber
        elementPositionNumber

-}
scrollX : String -> Float -> Float -> Task Error ()
scrollX id outerPos innerPos =
    Task.map2
        (\{ viewport } { element } ->
            Dom.setViewport
                (element.x
                    + element.width
                    * innerPos
                    - viewport.width
                    * outerPos
                    |> roundFloat
                )
                viewport.y
        )
        Dom.getViewport
        (Dom.getElement id)
        |> Task.andThen identity


{-|

    scroll
        elementId
        xWindowPositionNumber
        xElementPositionNumber
        yWindowPositionNumber
        yElementPositionNumber

-}
scroll : String -> Float -> Float -> Float -> Float -> Task Error ()
scroll id outerXPos innerXPos outerYPos innerYPos =
    Task.map2
        (\{ viewport } { element } ->
            Dom.setViewport
                (element.x
                    + element.width
                    * innerXPos
                    - viewport.width
                    * outerXPos
                    |> roundFloat
                )
                (element.y
                    + element.height
                    * innerYPos
                    - viewport.height
                    * outerYPos
                    |> roundFloat
                )
        )
        Dom.getViewport
        (Dom.getElement id)
        |> Task.andThen identity


{-|

    scrollYWithOffset
        elementId
        windowPositionNumber
        elementPositionNumber
        offsetInPixels

-}
scrollYWithOffset : String -> Float -> Float -> Float -> Task Error ()
scrollYWithOffset id outerPos innerPos offset =
    Task.map2
        (\{ viewport } { element } ->
            Dom.setViewport
                viewport.x
                (element.y
                    + element.height
                    * innerPos
                    - viewport.height
                    * outerPos
                    - offset
                    |> roundFloat
                )
        )
        Dom.getViewport
        (Dom.getElement id)
        |> Task.andThen identity


{-|

    scrollXWithOffset
        elementId
        windowPositionNumber
        elementPositionNumber
        offsetInPixels

-}
scrollXWithOffset : String -> Float -> Float -> Float -> Task Error ()
scrollXWithOffset id outerPos innerPos offset =
    Task.map2
        (\{ viewport } { element } ->
            Dom.setViewport
                (element.x
                    + element.width
                    * innerPos
                    - viewport.width
                    * outerPos
                    - offset
                    |> roundFloat
                )
                viewport.y
        )
        Dom.getViewport
        (Dom.getElement id)
        |> Task.andThen identity


{-|

    scrollWithOffset
        elementId
        xWindowPositionNumber
        xElementPositionNumber
        xOffsetInPixels
        yWindowPositionNumber
        yElementPositionNumber
        yOffsetInPixels

-}
scrollWithOffset : String -> Float -> Float -> Float -> Float -> Float -> Float -> Task Error ()
scrollWithOffset id outerXPos innerXPos xOffset outerYPos innerYPos yOffset =
    Task.map2
        (\{ viewport } { element } ->
            Dom.setViewport
                (element.x
                    + element.width
                    * innerXPos
                    - viewport.width
                    * outerXPos
                    - xOffset
                    |> roundFloat
                )
                (element.y
                    + element.height
                    * innerYPos
                    - viewport.height
                    * outerYPos
                    - yOffset
                    |> roundFloat
                )
        )
        Dom.getViewport
        (Dom.getElement id)
        |> Task.andThen identity


{-|

    scrollElementY
        outerElementId
        innerElementId
        outerPositionNumber
        innerPositionNumber

-}
scrollElementY : String -> String -> Float -> Float -> Task Error ()
scrollElementY outerId innerId outerPos innerPos =
    Task.map3
        (\outerVp outerE innerE ->
            outerVp.viewport.y
                + innerE.element.y
                + innerPos
                * innerE.element.height
                - outerE.element.y
                - outerPos
                * outerVp.viewport.height
                |> roundFloat
                |> Dom.setViewportOf outerId outerVp.viewport.x
        )
        (Dom.getViewportOf outerId)
        (Dom.getElement outerId)
        (Dom.getElement innerId)
        |> Task.andThen identity


{-|

    scrollElementX
        outerElementId
        innerElementId
        outerPositionNumber
        innerPositionNumber

-}
scrollElementX : String -> String -> Float -> Float -> Task Error ()
scrollElementX outerId innerId outerPos innerPos =
    Task.map3
        (\outerVp outerE innerE ->
            outerVp.viewport.x
                + innerE.element.x
                + innerPos
                * innerE.element.width
                - outerE.element.x
                - outerPos
                * outerVp.viewport.width
                |> roundFloat
                |> Dom.setViewportOf outerId
                >> (|>) outerVp.viewport.y
        )
        (Dom.getViewportOf outerId)
        (Dom.getElement outerId)
        (Dom.getElement innerId)
        |> Task.andThen identity


{-|

    scrollElement
        outerElementId
        innerElementId
        xOuterPositionNumber
        xInnerPositionNumber
        yOuterPositionNumber
        yInnerPositionNumber

-}
scrollElement : String -> String -> Float -> Float -> Float -> Float -> Task Error ()
scrollElement outerId innerId outerXPos innerXPos outerYPos innerYPos =
    Task.map3
        (\outerVp outerE innerE ->
            Dom.setViewportOf outerId
                (outerVp.viewport.x
                    + innerE.element.x
                    + innerXPos
                    * innerE.element.width
                    - outerE.element.x
                    - outerXPos
                    * outerVp.viewport.width
                    |> roundFloat
                )
                (outerVp.viewport.y
                    + innerE.element.y
                    + innerYPos
                    * innerE.element.height
                    - outerE.element.y
                    - outerYPos
                    * outerVp.viewport.height
                    |> roundFloat
                )
        )
        (Dom.getViewportOf outerId)
        (Dom.getElement outerId)
        (Dom.getElement innerId)
        |> Task.andThen identity


{-|

    scrollElementY
        outerElementId
        innerElementId
        outerPositionNumber
        innerPositionNumber
        offsetInPixels

-}
scrollElementYWithOffset : String -> String -> Float -> Float -> Float -> Task Error ()
scrollElementYWithOffset outerId innerId outerPos innerPos offset =
    Task.map3
        (\outerVp outerE innerE ->
            outerVp.viewport.y
                + innerE.element.y
                + innerPos
                * innerE.element.height
                - outerE.element.y
                - outerPos
                * outerVp.viewport.height
                - offset
                |> roundFloat
                |> Dom.setViewportOf outerId outerVp.viewport.x
        )
        (Dom.getViewportOf outerId)
        (Dom.getElement outerId)
        (Dom.getElement innerId)
        |> Task.andThen identity


{-|

    scrollElementX
        outerElementId
        innerElementId
        outerPositionNumber
        innerPositionNumber
        offsetInPixels

-}
scrollElementXWithOffset : String -> String -> Float -> Float -> Float -> Task Error ()
scrollElementXWithOffset outerId innerId outerPos innerPos offset =
    Task.map3
        (\outerVp outerE innerE ->
            outerVp.viewport.x
                + innerE.element.x
                + innerPos
                * innerE.element.width
                - outerE.element.x
                - outerPos
                * outerVp.viewport.width
                - offset
                |> roundFloat
                |> Dom.setViewportOf outerId
                >> (|>) outerVp.viewport.y
        )
        (Dom.getViewportOf outerId)
        (Dom.getElement outerId)
        (Dom.getElement innerId)
        |> Task.andThen identity


{-|

    scrollElementWithOffset
        outerElementId
        innerElementId
        xOuterPositionNumber
        xInnerPositionNumber
        xOffsetInPixels
        yOuterPositionNumber
        yInnerPositionNumber
        yOffsetInPixels

-}
scrollElementWithOffset : String -> String -> Float -> Float -> Float -> Float -> Float -> Float -> Task Error ()
scrollElementWithOffset outerId innerId outerXPos innerXPos xOffset outerYPos innerYPos yOffset =
    Task.map3
        (\outerVp outerE innerE ->
            Dom.setViewportOf outerId
                (outerVp.viewport.x
                    + innerE.element.x
                    + innerXPos
                    * innerE.element.width
                    - outerE.element.x
                    - outerXPos
                    * outerVp.viewport.width
                    - xOffset
                    |> roundFloat
                )
                (outerVp.viewport.y
                    + innerE.element.y
                    + innerYPos
                    * innerE.element.height
                    - outerE.element.y
                    - outerYPos
                    * outerVp.viewport.height
                    - yOffset
                    |> roundFloat
                )
        )
        (Dom.getViewportOf outerId)
        (Dom.getElement outerId)
        (Dom.getElement innerId)
        |> Task.andThen identity


roundFloat : Float -> Float
roundFloat =
    round >> toFloat
