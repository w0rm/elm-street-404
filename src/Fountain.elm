module Fountain exposing (Fountain, animate, fountain)

import AnimationState exposing (AnimatedObject, animateFrame)
import Time exposing (Time)


animate : Time -> Fountain -> Fountain
animate =
    animateFrame 3


type alias Fountain =
    AnimatedObject {}


fountain : Fountain
fountain =
    { elapsed = 0
    , timeout = 150
    , frame = 0
    }
