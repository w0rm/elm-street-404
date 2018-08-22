module View.Placeholder exposing (render)

import Box exposing (Box)
import Layers exposing (layers)
import Textures


render : ( Float, Float ) -> Box
render position =
    Box.textured
        Textures.Categories
        position
        12
        ( layers.article
        , 0
        )
