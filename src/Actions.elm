module Actions exposing (Action(..), EventAction(..))

import Article exposing (Article)
import Category exposing (Category)
import MapObject exposing (MapObject)
import OffsetClick exposing (Position)
import Textures exposing (TextureId)
import Time exposing (Time)
import WebGL exposing (Texture)
import Window exposing (Size)


type EventAction
    = DispatchArticles Int
    | DispatchOrders Int
    | DispatchReturns Int
    | DispatchCustomers
    | TimeoutRequestsAndCleanup


type Action
    = Tick Time
    | Start
    | BackToStart
    | Suspend
    | Restore
    | Click Position
    | ClickArticle Article
    | ClickCategory Category
    | ClickMapObject MapObject (Maybe Action)
    | TextureLoaded TextureId (Maybe Texture)
    | Dimensions Size
    | HoverCloseButton Bool
    | Event EventAction
    | NoOp
