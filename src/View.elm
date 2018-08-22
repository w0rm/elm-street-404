module View exposing (view)

import Actions exposing (Action)
import Html exposing (Html, br, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Model exposing (Model)
import OffsetClick
import PathView
import WebGLView


(=>) : a -> b -> ( a, b )
(=>) =
    \a b -> ( a, b )


debug : Model -> Html Action
debug model =
    div
        [ (\( a, b ) -> style a b) ("background" => "linear-gradient(0deg, #000000 0, rgba(0,0,0,0) 2px, rgba(0,0,0,0) 100%), linear-gradient(90deg, #000000 0, rgba(0,0,0,0) 2px, rgba(0,0,0,0) 100%)")
        , (\( a, b ) -> style a b) ("background-origin" => "padding-box")
        , (\( a, b ) -> style a b) ("background-clip" => "border-box")
        , (\( a, b ) -> style a b) ("background-size" => (toString model.tileSize ++ "px " ++ toString model.tileSize ++ "px"))
        , (\( a, b ) -> style a b) ("position" => "absolute")
        , (\( a, b ) -> style a b) ("left" => "0")
        , (\( a, b ) -> style a b) ("top" => "0")
        , (\( a, b ) -> style a b) ("width" => "100%")
        , (\( a, b ) -> style a b) ("height" => "100%")
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
                [ (\( a, b ) -> style a b) ("background-image" => ("url(" ++ model.imagesUrl ++ "/bg-tile.jpg" ++ ")"))
                , (\( a, b ) -> style a b) ("background-size" => "560px 560px")
                , (\( a, b ) -> style a b) ("background-position" => "50% 50%")
                , (\( a, b ) -> style a b) ("position" => "relative")
                , (\( a, b ) -> style a b) ("width" => (toString screenWidth ++ "px"))
                , (\( a, b ) -> style a b) ("height" => (toString screenHeight ++ "px"))
                , (\( a, b ) -> style a b) ("-ms-user-select" => "none")
                , (\( a, b ) -> style a b) ("-moz-user-select" => "none")
                , (\( a, b ) -> style a b) ("-webkit-user-select" => "none")
                , (\( a, b ) -> style a b) ("user-select" => "none")
                ]
                (div
                    [ (\( a, b ) -> style a b) ("position" => "absolute")
                    , (\( a, b ) -> style a b) ("width" => (toString mapWidth ++ "px"))
                    , (\( a, b ) -> style a b) ("height" => (toString mapHeight ++ "px"))
                    , (\( a, b ) -> style a b) ("left" => (toString ((screenWidth - mapWidth) // 2) ++ "px"))
                    , (\( a, b ) -> style a b) ("top" => (toString ((screenHeight - mapHeight) // 2) ++ "px"))
                    , (\( a, b ) -> style a b) ("-webkit-tap-highlight-color" => "transparent")
                    , OffsetClick.onClick Actions.Click
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
        , (\( a, b ) -> style a b) ("position" => "absolute")
        , (\( a, b ) -> style a b) ("right" => "0px")
        , (\( a, b ) -> style a b) ("top" => "0px")
        , (\( a, b ) -> style a b) ("border" => "none")
        , (\( a, b ) -> style a b) ("padding" => "0")
        , (\( a, b ) -> style a b) ("margin" => "0")
        , (\( a, b ) -> style a b) ("width" => (toString (round (size * 110 / 80)) ++ "px"))
        , (\( a, b ) -> style a b) ("height" => (toString (round (size * 110 / 97)) ++ "px"))
        , (\( a, b ) -> style a b) ("background-color" => "transparent")
        , (\( a, b ) -> style a b) ("background-image" => ("url(" ++ url ++ ")"))
        , (\( a, b ) -> style a b) ("background-size" => "200% 100%")
        , (\( a, b ) -> style a b)
            ("background-position"
                => (if active then
                        "-100% 0"

                    else
                        "0 0"
                   )
            )
        , (\( a, b ) -> style a b) ("outline" => "none")
        , (\( a, b ) -> style a b) ("cursor" => "pointer")
        , (\( a, b ) -> style a b) ("touch-action" => "manipulation")
        ]
        []
