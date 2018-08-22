port module Main exposing (escapeToSuspend, main, restore, subscriptions, suspend)

import Actions exposing (Action(..))
import Browser
import Browser.Dom exposing (Viewport, getViewport)
import Browser.Events exposing (onAnimationFrameDelta, onKeyDown, onKeyUp, onResize)
import Html
import Html.Events exposing (keyCode)
import Json.Decode as Decode exposing (Value)
import Model exposing (Model)
import Process
import Task
import Textures
import Time
import Update
import View


port suspend : (Bool -> msg) -> Sub msg


port restore : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Action
subscriptions model =
    case model.state of
        Model.Suspended _ ->
            restore (\_ -> Actions.Restore)

        _ ->
            Sub.batch
                [ if model.state == Model.Playing || model.state == Model.Lost || model.state == Model.Won then
                    onAnimationFrameDelta Tick

                  else
                    Sub.none
                , onResize Dimensions
                , if model.embed then
                    onKeyDown (Decode.map escapeToSuspend keyCode)

                  else
                    Sub.none
                , suspend (\_ -> Suspend)
                , model.events
                    |> List.map (\( time, action ) -> Time.every time (\_ -> Event action))
                    |> Sub.batch
                ]


main : Program Value Model Action
main =
    Browser.element
        { init =
            \flags ->
                let
                    imagesUrl =
                        flags
                            |> Decode.decodeValue (Decode.field "imagesUrl" Decode.string)
                            |> Result.withDefault "../img"

                    randomSeed =
                        flags
                            |> Decode.decodeValue (Decode.field "randomSeed" Decode.int)
                            |> Result.withDefault 0

                    embed =
                        flags
                            |> Decode.decodeValue (Decode.field "embed" Decode.bool)
                            |> Result.withDefault False

                    devicePixelRatio =
                        flags
                            |> Decode.decodeValue (Decode.field "devicePixelRatio" Decode.float)
                            |> Result.withDefault 1
                in
                ( Model.initial randomSeed imagesUrl embed devicePixelRatio
                , Cmd.batch
                    [ Update.loadImage imagesUrl (Textures.filename Textures.Score)
                    , Task.perform GetViewport
                        (Process.sleep 100 |> Task.andThen (\_ -> getViewport))
                    ]
                )
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }


escapeToSuspend : Int -> Action
escapeToSuspend keyCode =
    case keyCode of
        27 ->
            Actions.Suspend

        _ ->
            Actions.NoOp
