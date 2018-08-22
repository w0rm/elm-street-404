port module Update exposing (loadImage, update)

import Actions exposing (..)
import Article exposing (Article, State(..))
import Browser.Dom exposing (getViewport)
import Category exposing (Category)
import DeliveryPerson exposing (Location(..))
import Dict
import IHopeItWorks
import MapObject exposing (MapObject, MapObjectCategory(..))
import Model exposing (..)
import Task exposing (Task)
import Textures exposing (TextureId)
import View.Model
import WebGL.Texture as Texture


port suspended : Bool -> Cmd msg


update : Action -> Model -> ( Model, Cmd Action )
update action model =
    case action of
        HoverCloseButton active ->
            ( { model | closeButtonActive = active }
            , Cmd.none
            )

        Dimensions width height ->
            ( Model.resize ( width, height ) model |> View.Model.render, Cmd.none )

        GetViewport { viewport } ->
            ( Model.resize ( round viewport.width, round viewport.height ) model |> View.Model.render, Cmd.none )

        TextureLoaded textureFilename maybeTexture ->
            let
                loadTexture =
                    case Dict.get textureFilename model.textures of
                        Just data ->
                            Dict.insert
                                textureFilename
                                { data
                                    | texture =
                                        Maybe.map
                                            (\texture ->
                                                { size =
                                                    ( toFloat (Tuple.first (Texture.size texture))
                                                    , toFloat (Tuple.second (Texture.size texture))
                                                    )
                                                , texture = texture
                                                }
                                            )
                                            maybeTexture
                                }
                                model.textures

                        Nothing ->
                            model.textures

                newModel =
                    { model | textures = loadTexture }

                texturesToLoad =
                    Textures.loadTextures newModel.textures
            in
            if textureFilename == Textures.filename Textures.Score then
                case model.state of
                    Suspended _ ->
                        ( { newModel | state = Suspended Loading }
                        , Cmd.batch (List.map (loadImage model.imagesUrl) texturesToLoad)
                        )

                    _ ->
                        ( { newModel | state = Loading }
                        , Cmd.batch (List.map (loadImage model.imagesUrl) texturesToLoad)
                        )

            else if List.length texturesToLoad == 0 then
                case model.state of
                    Suspended _ ->
                        ( View.Model.render { newModel | state = Suspended Stopped }
                        , Cmd.none
                        )

                    _ ->
                        ( View.Model.render { newModel | state = Stopped }
                        , Cmd.none
                        )

            else
                ( View.Model.render newModel
                , Cmd.none
                )

        BackToStart ->
            ( View.Model.render { model | state = Stopped }
            , Cmd.none
            )

        Start ->
            ( View.Model.render (Model.start model)
            , Cmd.none
            )

        Tick time ->
            let
                ( newModel, maybeAction ) =
                    Model.animate time model
            in
            ( View.Model.render newModel
            , case maybeAction of
                Just action_ ->
                    Task.perform identity (Task.succeed action_)

                Nothing ->
                    Cmd.none
            )

        Click { x, y } ->
            let
                effect =
                    case Model.click ( x, y ) model of
                        Just action_ ->
                            Task.perform identity (Task.succeed action_)

                        Nothing ->
                            Cmd.none
            in
            ( model, effect )

        ClickArticle article ->
            ifPlaying (onArticleClick article) model

        ClickCategory category ->
            ifPlaying (onCategoryClick category) model

        ClickMapObject mapObject maybeAction ->
            ifPlaying (Model.navigateToMapObject mapObject maybeAction) model

        Suspend ->
            case ( model.embed, model.state ) of
                ( True, Suspended _ ) ->
                    ( model
                    , Cmd.none
                    )

                _ ->
                    ( { model | state = Suspended model.state, closeButtonActive = False }
                    , suspended True
                    )

        Restore ->
            case ( model.embed, model.state ) of
                ( True, Suspended prevState ) ->
                    ( { model | state = prevState }
                    , Task.perform GetViewport getViewport
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        Event eventAction ->
            ifPlaying (Model.dispatch eventAction) model

        NoOp ->
            ( model
            , Cmd.none
            )


ifPlaying : (Model -> Model) -> Model -> ( Model, Cmd Action )
ifPlaying fun model =
    if model.state == Playing then
        ( fun model
        , Cmd.none
        )

    else
        ( model
        , Cmd.none
        )


loadImage : String -> String -> Cmd Action
loadImage imagesUrl textureSrc =
    Texture.load (imagesUrl ++ "/" ++ textureSrc)
        |> Task.attempt (Result.toMaybe >> TextureLoaded textureSrc)



-- click the 1st picked article that has the same category


onCategoryClick : Category -> Model -> Model
onCategoryClick category model =
    let
        isPickedCategory a =
            a.category == category && Article.isPicked a
    in
    case IHopeItWorks.find isPickedCategory model.articles of
        Just article ->
            onArticleClick article model

        _ ->
            model


onArticleClick : Article -> Model -> Model
onArticleClick article model =
    case model.deliveryPerson.location of
        At mapObject _ ->
            case ( mapObject.category, article.state ) of
                ( HouseCategory _, AwaitingReturn house ) ->
                    Model.pickupReturn mapObject house article model

                ( HouseCategory _, Picked ) ->
                    Model.deliverArticle mapObject article model

                ( WarehouseCategory _, InStock warehouse ) ->
                    Model.pickupArticle warehouse mapObject article model

                ( WarehouseCategory _, Picked ) ->
                    Model.returnArticle mapObject article model

                _ ->
                    model

        _ ->
            model
