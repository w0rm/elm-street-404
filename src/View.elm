module View exposing (view)

import Actions exposing (Action)
import Html exposing (Html, br, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Model exposing (Model)
import OffsetClick
import PathView
import WebGLView


debug : Model -> Html Action
debug model =
    div
        [ style "background" "linear-gradient(0deg, #000000 0, rgba(0,0,0,0) 2px, rgba(0,0,0,0) 100%), linear-gradient(90deg, #000000 0, rgba(0,0,0,0) 2px, rgba(0,0,0,0) 100%)"
        , style "background-origin" "padding-box"
        , style "background-clip" "border-box"
        , style "background-size" (String.fromInt model.tileSize ++ "px " ++ String.fromInt model.tileSize ++ "px")
        , style "position" "absolute"
        , style "left" "0"
        , style "top" "0"
        , style "width" "100%"
        , style "height" "100%"
        ]
        []


view : Model -> Html Action
view model =
    let
        mapWidth =
            Tuple.first model.gridSize * model.tileSize

        mapHeight =
            Tuple.second model.gridSize * model.tileSize

        screenWidth =
            max (Tuple.first model.dimensions) mapWidth

        screenHeight =
            max (Tuple.second model.dimensions) mapHeight
    in
    case model.state of
        Model.Suspended _ ->
            text ""

        _ ->
            div
                [ style "background-image" ("url(" ++ model.imagesUrl ++ "/bg-tile.jpg" ++ ")")
                , style "background-size" "560px 560px"
                , style "background-position" "50% 50%"
                , style "position" "absolute"
                , style "left" "0"
                , style "top" "0"
                , style "width" (String.fromInt screenWidth ++ "px")
                , style "height" (String.fromInt screenHeight ++ "px")
                , style "-ms-user-select" "none"
                , style "-moz-user-select" "none"
                , style "-webkit-user-select" "none"
                , style "user-select" "none"
                ]
                (div
                    [ style "position" "absolute"
                    , style "width" (String.fromInt mapWidth ++ "px")
                    , style "height" (String.fromInt mapHeight ++ "px")
                    , style "left" (String.fromInt ((screenWidth - mapWidth) // 2) ++ "px")
                    , style "top" (String.fromInt ((screenHeight - mapHeight) // 2) ++ "px")
                    , style "-webkit-tap-highlight-color" "transparent"
                    , OffsetClick.onClick
                        (\{ x, y } ->
                            Actions.Click
                                { x = x - (screenWidth - mapWidth) // 2
                                , y = y - (screenHeight - mapHeight) // 2
                                }
                        )
                    ]
                    [ PathView.render model.gridSize model.tileSize model.deliveryPerson.route
                    , WebGLView.render model.devicePixelRatio model.gridSize model.tileSize model.textures model.texturedBoxes
                    ]
                    :: (if model.embed then
                            [ closeButton model.closeButtonActive (toFloat model.tileSize) (model.imagesUrl ++ "/close.png") ]

                        else
                            []
                       )
                )


closeButton : Bool -> Float -> String -> Html Action
closeButton active size url =
    button
        [ onClick Actions.Suspend
        , onMouseLeave (Actions.HoverCloseButton False)
        , onMouseOver (Actions.HoverCloseButton True)
        , style "position" "absolute"
        , style "right" "0"
        , style "top" "0"
        , style "border" "none"
        , style "padding" "0"
        , style "margin" "0"
        , style "width" (String.fromInt (round (size * 110 / 80)) ++ "px")
        , style "height" (String.fromInt (round (size * 110 / 97)) ++ "px")
        , style "background-color" "transparent"
        , style "background-image" ("url(" ++ url ++ ")")
        , style "background-size" "200% 100%"
        , style "background-position"
            (if active then
                "-100% 0"

             else
                "0 0"
            )
        , style "outline" "none"
        , style "cursor" "pointer"
        , style "touch-action" "manipulation"
        ]
        []
