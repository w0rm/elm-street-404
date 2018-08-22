module PathView exposing (render)

import Actions exposing (Action)
import Html exposing (Html)
import Svg exposing (polyline, svg)
import Svg.Attributes exposing (..)


addPointToSring : Int -> ( Int, Int ) -> String -> String
addPointToSring tileSize ( x, y ) =
    (++)
        (" "
            ++ String.fromInt (x * tileSize + tileSize)
            ++ ","
            ++ String.fromInt (y * tileSize + tileSize // 2)
        )


renderPoints : Int -> List ( Int, Int ) -> Html Action
renderPoints tileSize waypoints =
    polyline
        [ points (List.foldl (addPointToSring tileSize) "" waypoints)
        , strokeLinejoin "round"
        , strokeLinecap "round"
        , stroke "#bdab82"
        , strokeWidth (String.fromInt tileSize)
        , opacity "0.5"
        , fill "transparent"
        ]
        []


render : ( Int, Int ) -> Int -> List ( Int, Int ) -> Html Action
render ( w, h ) tileSize route =
    svg
        [ version "1.1"
        , viewBox ("0 0 " ++ String.fromInt (w * tileSize) ++ " " ++ String.fromInt (h * tileSize))
        , width (String.fromInt (w * tileSize))
        , height (String.fromInt (h * tileSize))
        , style "position: absolute"
        ]
        [ renderPoints tileSize route ]
