module AnimationState exposing
    ( AnimatedObject
    , animateFrame
    )


type alias AnimatedObject a =
    { a
        | elapsed : Float
        , timeout : Float
        , frame : Int
    }


{-| incrtemens frame every time timeout is reached
-}
animateFrame : Int -> Float -> AnimatedObject a -> AnimatedObject a
animateFrame frames elapsed state =
    let
        elapsed_ =
            state.elapsed + elapsed
    in
    if elapsed_ > state.timeout then
        { state
            | elapsed = elapsed_ - state.timeout
            , frame = modBy frames (state.frame + 1)
        }

    else
        { state | elapsed = elapsed_ }
