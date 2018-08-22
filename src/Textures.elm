module Textures exposing
    ( TextureId(..)
    , Textures
    , filename
    , loadTextures
    , loadedTextures
    , textures
    )

import Dict exposing (Dict)
import WebGL
import WebGL.Texture exposing (Texture)


type alias Textures =
    Dict String TextureData


type TextureId
    = FountainSpring
    | HouseBubble Int
    | House
    | Customers
    | Tree
    | WarehouseShadow
    | Categories
    | DeliveryPersonBack
    | DeliveryPersonFront
    | Fountain
    | InventoryBubble
    | Shirts
    | Trousers
    | Warehouse
    | ClickToStart
    | FountainShadow
    | HouseShadow
    | Scarves
    | Shoes
    | WarehouseBubble
    | ElmStreet404
    | Score
    | Boxes
    | EndGame
    | Heart
    | Spotlight


filename : TextureId -> String
filename textureId =
    case textureId of
        FountainSpring ->
            "fountain-spring.png"

        HouseBubble n ->
            "house-bubble-" ++ String.fromInt n ++ ".png"

        House ->
            "house.png"

        Customers ->
            "customers.png"

        Tree ->
            "tree.png"

        WarehouseShadow ->
            "warehouse-shadow.png"

        Categories ->
            "categories.png"

        DeliveryPersonBack ->
            "delivery-person.png"

        DeliveryPersonFront ->
            "obstructing-delivery-person.png"

        Fountain ->
            "fountain.png"

        InventoryBubble ->
            "inventory-bubble.png"

        Shirts ->
            "shirts.png"

        Trousers ->
            "trousers.png"

        Warehouse ->
            "warehouse.png"

        ClickToStart ->
            "click-to-start.png"

        FountainShadow ->
            "fountain-shadow.png"

        HouseShadow ->
            "house-shadow.png"

        Scarves ->
            "scarves.png"

        Shoes ->
            "shoes.png"

        WarehouseBubble ->
            "warehouse-bubble.png"

        ElmStreet404 ->
            "404-elm-street.png"

        Score ->
            "score.png"

        Boxes ->
            "boxes.png"

        EndGame ->
            "end-game.png"

        Heart ->
            "heart.png"

        Spotlight ->
            "spotlight.png"


textures : Dict String TextureData
textures =
    Dict.fromList
        [ ( filename Categories, TextureData ( 1, 1 ) 14 Nothing )
        , ( filename ClickToStart, TextureData ( 10, 2 ) 1 Nothing )
        , ( filename Customers, TextureData ( 2, 3 ) 18 Nothing )
        , ( filename DeliveryPersonFront, TextureData ( 2, 4 ) 29 Nothing )
        , ( filename DeliveryPersonBack, TextureData ( 2, 4 ) 29 Nothing )
        , ( filename Boxes, TextureData ( 2, 4 ) 29 Nothing )
        , ( filename ElmStreet404, TextureData ( 13, 2 ) 1 Nothing )
        , ( filename Fountain, TextureData ( 3, 2 ) 1 Nothing )
        , ( filename FountainShadow, TextureData ( 4, 2 ) 1 Nothing )
        , ( filename FountainSpring, TextureData ( 1, 2 ) 4 Nothing )
        , ( filename House, TextureData ( 2, 3 ) 1 Nothing )
        , ( filename (HouseBubble 1), TextureData ( 3, 3 ) 1 Nothing )
        , ( filename (HouseBubble 2), TextureData ( 3, 4 ) 1 Nothing )
        , ( filename (HouseBubble 3), TextureData ( 3, 5 ) 1 Nothing )
        , ( filename HouseShadow, TextureData ( 3, 2 ) 1 Nothing )
        , ( filename InventoryBubble, TextureData ( 7, 3 ) 1 Nothing )
        , ( filename Scarves, TextureData ( 2, 3 ) 3 Nothing )
        , ( filename Score, TextureData ( 1, 1 ) 13 Nothing )
        , ( filename Shirts, TextureData ( 2, 3 ) 12 Nothing )
        , ( filename Shoes, TextureData ( 2, 3 ) 4 Nothing )
        , ( filename Tree, TextureData ( 3, 5 ) 1 Nothing )
        , ( filename Trousers, TextureData ( 2, 3 ) 3 Nothing )
        , ( filename Warehouse, TextureData ( 4, 4 ) 1 Nothing )
        , ( filename WarehouseBubble, TextureData ( 4, 5 ) 1 Nothing )
        , ( filename WarehouseShadow, TextureData ( 5, 4 ) 1 Nothing )
        , ( filename EndGame, TextureData ( 10, 7 ) 3 Nothing )
        , ( filename Heart, TextureData ( 2, 1 ) 2 Nothing )
        , ( filename Spotlight, TextureData ( 4, 2 ) 1 Nothing )
        ]


loadedTextures : Textures -> Int
loadedTextures textures_ =
    (1
        - toFloat (List.length (loadTextures textures_))
        / toFloat (Dict.size textures_)
    )
        * 100
        |> round


loadTextures : Textures -> List String
loadTextures textures_ =
    Dict.toList textures_
        |> List.filter (\( id, data ) -> data.texture == Nothing)
        |> List.map Tuple.first


type alias TextureWithSize =
    { size : ( Float, Float )
    , texture : Texture
    }


type alias TextureData =
    { size : ( Float, Float )
    , frames : Int
    , texture : Maybe TextureWithSize
    }
