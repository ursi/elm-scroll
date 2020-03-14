module Example exposing (..)

import Browser exposing (Document)
import Browser.Events as BE
import Css as C exposing (Style)
import Css.Colors exposing (..)
import Css.Global as CG
import Html.Styled as H exposing (Html)
import Html.Styled.Attributes as A
import Html.Styled.Events as E
import Scroll
import Task
import Throttle exposing (Throttle)
import Time exposing (Posix)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { outer : ( Float, Float, Float )
    , inner : ( Float, Float, Float )
    , throttler : Throttle Msg
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { outer = ( 0, 0, 0 )
      , inner = ( 0, 0, 0 )
      , throttler = Throttle.create 3
      }
    , Cmd.batch
        [ scrollOuter ( 0, 0, 0 )
        , scrollInner ( 0, 0, 0 )
        ]
    )


scrollOuter : ( Float, Float, Float ) -> Cmd Msg
scrollOuter ( xPos, yPos, offset ) =
    Task.attempt (\_ -> NoOp) <|
        Scroll.scrollWithOffset outerBoxId xPos xPos offset yPos yPos offset


scrollInner : ( Float, Float, Float ) -> Cmd Msg
scrollInner ( xPos, yPos, offset ) =
    Task.attempt (\_ -> NoOp) <|
        Scroll.scrollElementWithOffset outerBoxId innerBoxId xPos xPos offset yPos yPos offset



-- UPDATE


type Msg
    = Scroll InnerOuter Component Float
    | UpdateThrottle Posix
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateThrottle _ ->
            let
                ( newThrottle, cmd ) =
                    Throttle.update model.throttler
            in
            ( { model | throttler = newThrottle }
            , if cmd /= Cmd.none then
                cmd

              else
                cmd
            )

        Scroll innerOuter component value ->
            let
                ( x, y, offset ) =
                    if innerOuter == Outer then
                        model.outer

                    else
                        model.inner

                newValues =
                    case component of
                        X ->
                            ( value, y, offset )

                        Y ->
                            ( x, value, offset )

                        Offset ->
                            ( x, y, value )
            in
            case innerOuter of
                Outer ->
                    ( { model | outer = newValues }
                    , scrollOuter newValues
                    )

                Inner ->
                    let
                        ( newThrottle, cmd ) =
                            Throttle.try
                                (scrollInner newValues)
                                model.throttler
                    in
                    ( { model
                        | inner = newValues
                        , throttler = newThrottle
                      }
                    , cmd
                    )

        NoOp ->
            ( model, Cmd.none )


type InnerOuter
    = Inner
    | Outer


type Component
    = X
    | Y
    | Offset


outerBoxId : String
outerBoxId =
    "outer-box"


innerBoxId : String
innerBoxId =
    "inner-box"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Throttle.ifNeeded
        (BE.onAnimationFrame UpdateThrottle)
        model.throttler



-- VIEW


view : Model -> Document Msg
view model =
    { title = ""
    , body =
        [ H.div
            [ A.id outerBoxId
            , A.css
                [ C.width <| C.vw boxSizeVw
                , C.height <| C.vh boxSizeVw
                , C.backgroundColor gray
                , C.position C.relative
                , C.overflow C.scroll
                ]
            ]
            [ H.div
                [ A.css
                    [ C.width <| C.pct 300
                    , C.height <| C.pct 300
                    , doubleCenter
                    ]
                ]
                [ H.div
                    [ A.id innerBoxId
                    , A.css
                        [ C.width <| C.px 200
                        , C.height <| C.px 200
                        , C.backgroundColor lightblue
                        ]
                    ]
                    []
                ]
            ]
        , H.div
            [ A.css
                [ C.position C.fixed
                , C.bottom C.zero
                , C.left C.zero
                , C.displayFlex
                ]
            ]
            [ adjusters model.outer Outer
            , adjusters model.inner Inner
            ]
        , CG.global
            [ CG.body
                [ C.width <| C.vw 300
                , C.height <| C.vh 300
                , doubleCenter
                ]
            ]
        ]
            |> List.map H.toUnstyled
    }



-- STYLES


doubleCenter : Style
doubleCenter =
    C.batch
        [ C.displayFlex
        , C.justifyContent C.center
        , C.alignItems C.center
        ]


stack : Style
stack =
    C.batch
        [ C.displayFlex
        , C.flexDirection C.column
        ]


adjusters : ( Float, Float, Float ) -> InnerOuter -> Html Msg
adjusters ( x, y, offset ) innerOuter =
    H.div
        [ A.css [ stack ] ]
        [ H.text <|
            if innerOuter == Outer then
                "Outer"

            else
                "Inner"
        , scrollSlider x y X innerOuter
        , scrollSlider x y Y innerOuter
        , H.label []
            [ H.text "Offset "
            , H.input
                [ A.type_ "range"
                , A.min "-100"
                , A.max "100"
                , A.step "1"
                , A.list "zero"
                , A.value <| String.fromFloat offset
                , E.onInput <| rangeToFloat <| Scroll innerOuter Offset
                ]
                []
            , H.datalist [ A.id "zero" ] [ H.option [ A.value "0" ] [] ]
            ]
        ]


scrollSlider : Float -> Float -> Component -> InnerOuter -> Html Msg
scrollSlider x y axis innerOuter =
    let
        ( label, value, toMsg ) =
            case axis of
                X ->
                    ( "X ", String.fromFloat x, Scroll )

                Y ->
                    ( "Y ", String.fromFloat y, Scroll )

                _ ->
                    ( "", "", Scroll )
    in
    H.label []
        [ H.text label
        , H.input
            [ A.type_ "range"
            , A.min "0"
            , A.max "1"
            , A.step ".01"
            , A.value value
            , E.onInput <| rangeToFloat <| toMsg innerOuter axis
            ]
            []
        ]


rangeToFloat : (Float -> Msg) -> String -> Msg
rangeToFloat toMsg strNum =
    case String.toFloat strNum of
        Just n ->
            toMsg n

        Nothing ->
            toMsg 0


boxSizeVw : Float
boxSizeVw =
    50
