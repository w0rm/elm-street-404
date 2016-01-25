module Update (update) where

import Model exposing (..)
import Actions exposing (..)
import Effects exposing (Effects)
import Time exposing (Time)
import Random
import DeliveryPerson exposing (Location(..))
import Article exposing (State(..), Article)
import Obstacle exposing (Obstacle)
import Request exposing (Request)
import Category exposing (Category)
import Generator
import Config
import Customer exposing (Customer)
import IHopeItWorks
import ImageLoad
import Json.Decode as Decoder
import Task exposing (Task)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Init time ->
      ( {model | seed = Random.initialSeed (floor time)}
      , loadImage "score.png"
      )
    ImageLoaded image ->
      if image == "score.png" then
        ({model | state = Loading}, Effects.batch (List.map loadImage model.images))
      else
        let
          newModel = {model | images = List.filter ((/=) image) model.images}
        in
          if List.length newModel.images == 0 then
            ({newModel | state = Stopped}, Effects.none)
          else
            (newModel, Effects.none)
    Start ->
      (Model.start model, Effects.tick Tick)
    Tick time ->
      if model.state == Playing then
        ( model
          |> Model.animate time animate
          |> Model.timeoutRequests
          |> Model.cleanupLostArticles
          |> Model.cleanupLostRequests
          |> Model.updateCustomers
          |> Model.updateGameState
        , Effects.tick Tick
        )
      else
        ({model | animationState = Nothing}, Effects.none)
    ClickArticle article ->
      ifPlaying (onArticleClick article) model
    ClickCategory category ->
      ifPlaying (onCategoryClick category) model
    ClickWarehouse warehouse ->
      ifPlaying (Model.navigateToWarehouse warehouse) model
    ClickHouse house ->
      ifPlaying (Model.navigateToHouse house) model


ifPlaying : (Model -> Model) -> Model -> (Model, Effects Action)
ifPlaying fun model =
  if model.state == Playing then
    (fun model, Effects.none)
  else
    (model, Effects.none)


loadImage : String -> Effects Action
loadImage image =
  ImageLoad.load (Config.imageUrl image) (Decoder.succeed image) `Task.onError` always (Task.succeed image)
  |> Task.map (always (ImageLoaded image))
  |> Effects.task


animate : Time -> Model -> Model
animate elapsed model =
  model |> animateObstacles elapsed
        |> animateDeliveryPerson elapsed
        |> animateRequests elapsed
        |> animateGenerators elapsed
        |> animateCustomers elapsed


animateGenerators : Time -> Model -> Model
animateGenerators elapsed model =
  { model
  | orderGenerator = Generator.animate elapsed model.orderGenerator
  , returnGenerator = Generator.animate elapsed model.returnGenerator
  , articleGenerator = Generator.animate elapsed model.articleGenerator
  }
  |> dispatchArticles
  |> dispatchOrders
  |> dispatchReturns


dispatchArticles : Model -> Model
dispatchArticles model =
  if model.articleGenerator.active then
    Model.dispatchArticles 1 model
  else
    model


dispatchOrders : Model -> Model
dispatchOrders model =
  if model.orderGenerator.active then
    Model.dispatchOrders 1 model
  else
    model


dispatchReturns : Model -> Model
dispatchReturns model =
  if model.returnGenerator.active then
    Model.dispatchReturns 1 model
  else
    model


animateObstacles : Time -> Model -> Model
animateObstacles elapsed model =
  { model | obstacles = List.map (Obstacle.animate elapsed) model.obstacles }


animateDeliveryPerson : Time -> Model -> Model
animateDeliveryPerson elapsed model =
  { model | deliveryPerson = DeliveryPerson.animate elapsed model.deliveryPerson }


animateRequests : Time -> Model -> Model
animateRequests elapsed model =
 {model | requests = List.map (Request.animate elapsed) model.requests }


animateCustomers : Time -> Model -> Model
animateCustomers elapsed model =
 {model | customers = List.map (Customer.animate elapsed) model.customers }


-- click the 1st picked article that has the same category
onCategoryClick : Category -> Model -> Model
onCategoryClick category model =
  let
    maybeArticle = IHopeItWorks.first
      (\a -> a.category == category && Article.isPicked a)
      model.articles
  in
    case maybeArticle of
      Just article -> onArticleClick article model
      _ -> model


onArticleClick : Article -> Model -> Model
onArticleClick article model =
  case model.deliveryPerson.location of
    AtHouse house ->
      case article.state of
        AwaitingReturn house' ->
          Model.pickupReturn house house' article model
        Picked ->
          Model.deliverArticle house article model
        _ ->
          model

    AtWarehouse warehouse' ->
      case article.state of
        InStock warehouse ->
          Model.pickupArticle warehouse warehouse' article model
        Picked ->
          Model.returnArticle warehouse' article model
        _ -> model

    _ -> model