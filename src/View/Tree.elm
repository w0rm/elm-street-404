module View.Tree exposing (render)

import Box exposing (Box)
import Layers exposing (layers)
import MapObject exposing (MapObject)
import Textures


render : MapObject -> List Box
render { position } =
    [ Box.offsetTextured ( 0, -3 ) Textures.Tree position 0 ( layers.obstacle, 0 ) ]
