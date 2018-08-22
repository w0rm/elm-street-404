module OffsetClick exposing
    ( Position
    , onClick
    )

import Html
import Html.Events as Events
import Json.Decode as Json exposing (Decoder)
import Result exposing (Result)


type alias Position =
    { x : Int
    , y : Int
    }


onClick : (Position -> a) -> Html.Attribute a
onClick tagger =
    Events.on "click" (Json.map tagger position)


{-| TODO: support offset?
-}
position : Json.Decoder Position
position =
    Json.map2
        Position
        (Json.field "pageX" Json.int)
        (Json.field "pageY" Json.int)
