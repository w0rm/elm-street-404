module Actions exposing (Action(..), EventAction(..))

import Article exposing (Article)
import Browser.Dom exposing (Viewport)
import Category exposing (Category)
import MapObject exposing (MapObject)
import OffsetClick exposing (Position)
import Textures exposing (TextureId)
import WebGL.Texture exposing (Texture)


type EventAction
    = DispatchArticles Int
    | DispatchOrders Int
    | DispatchReturns Int
    | DispatchCustomers
    | TimeoutRequestsAndCleanup


type Action
    = Tick Float
    | Start
    | BackToStart
    | Suspend
    | Restore
    | Click Position
    | ClickArticle Article
    | ClickCategory Category
    | ClickMapObject MapObject (Maybe Action)
    | TextureLoaded String (Maybe Texture)
    | Dimensions Int Int
    | GetViewport Viewport
    | HoverCloseButton Bool
    | Event EventAction
    | NoOp
