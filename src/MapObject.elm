module MapObject exposing
    ( Box
    , MapObject
    , MapObjectCategory(..)
    , animate
    , fountain
    , house
    , houseSlots
    , isHouse
    , placeRandom
    , splitBy
    , tree
    , warehouse
    , warehouseSlots
    )

import Fountain exposing (Fountain)
import Random


type alias Box =
    { position : ( Float, Float )
    , size : ( Float, Float )
    }


type MapObjectCategory
    = HouseCategory Int
    | WarehouseCategory Int
    | FountainCategory Fountain
    | TreeCategory


type alias MapObject_ a b =
    { a | category : b }


type alias MapObject =
    MapObject_ Box MapObjectCategory


animate : Float -> MapObject -> MapObject
animate elapsed object =
    case object.category of
        FountainCategory fountain_ ->
            { object | category = FountainCategory (Fountain.animate elapsed fountain_) }

        _ ->
            object


mapObject : ( Float, Float ) -> MapObjectCategory -> MapObject
mapObject size_ category =
    { position = ( 0, 0 )
    , size = size_
    , category = category
    }


tree : MapObject
tree =
    mapObject ( 3, 2 ) TreeCategory


fountain : MapObject
fountain =
    mapObject ( 3, 2 ) (FountainCategory Fountain.fountain)


house : MapObject
house =
    mapObject ( 2, 2 ) (HouseCategory 3)


warehouse : MapObject
warehouse =
    mapObject ( 4, 3 ) (WarehouseCategory 6)


warehouseSlots : List MapObject -> List MapObject
warehouseSlots mapObjects =
    case mapObjects of
        obj :: rest ->
            case obj.category of
                WarehouseCategory capacity ->
                    List.repeat (capacity - 1) obj ++ warehouseSlots rest

                _ ->
                    warehouseSlots rest

        [] ->
            []


houseSlots : List MapObject -> List MapObject
houseSlots mapObjects =
    case mapObjects of
        obj :: rest ->
            case obj.category of
                HouseCategory capacity ->
                    List.repeat capacity obj ++ houseSlots rest

                _ ->
                    houseSlots rest

        [] ->
            []


isHouse : MapObject -> Bool
isHouse { category } =
    case category of
        HouseCategory _ ->
            True

        _ ->
            False


size : MapObject -> ( Float, Float )
size obj =
    let
        ( w, h ) =
            obj.size
    in
    ( w + 1, h + 1 )


placeRandom : List MapObject -> List Box -> Random.Generator (List MapObject)
placeRandom objects boxes =
    case objects of
        [] ->
            Random.map (always []) (Random.int 0 0)

        object :: restObjects ->
            case filterSize (size object) boxes of
                [] ->
                    Random.map (always []) (Random.int 0 0)

                box :: restBoxes ->
                    fitRandom box (size object)
                        |> Random.andThen
                            (\position ->
                                Random.map
                                    (\objects_ -> { object | position = position } :: objects_)
                                    (placeRandom
                                        restObjects
                                        (sortBySize (splitBy { position = position, size = size object } box ++ restBoxes))
                                    )
                            )


splitBy : Box -> Box -> List Box
splitBy box1 box2 =
    let
        ( x1, y1 ) =
            box1.position

        ( w1, h1 ) =
            box1.size

        ( x2, y2 ) =
            box2.position

        ( w2, h2 ) =
            box2.size
    in
    List.filter
        (\box -> Tuple.first box.size > 0 && Tuple.second box.size > 0)
        [ { position = ( x2, y2 ), size = ( x1 - x2, h1 + y1 - y2 ) }
        , { position = ( x1, y2 ), size = ( x2 + w2 - x1, y1 - y2 ) }
        , { position = ( x1 + w1, y1 ), size = ( x2 + w2 - (x1 + w1), y2 + h2 - y1 ) }
        , { position = ( x2, y1 + h1 ), size = ( x1 + w1 - x2, y2 + h2 - (y1 + h1) ) }
        ]


fitRandom : Box -> ( Float, Float ) -> Random.Generator ( Float, Float )
fitRandom box ( w, h ) =
    Random.map
        (\( x, y ) -> ( toFloat x, toFloat y ))
        (Random.pair
            (Random.int
                (floor (Tuple.first box.position))
                (floor (Tuple.first box.position + Tuple.first box.size - w))
            )
            (Random.int
                (floor (Tuple.second box.position))
                (floor (Tuple.second box.position + Tuple.second box.size - h))
            )
        )


filterSize : ( Float, Float ) -> List Box -> List Box
filterSize ( w, h ) =
    List.filter (\obj -> Tuple.first obj.size >= w && Tuple.second obj.size >= h)


sortBySize : List Box -> List Box
sortBySize =
    List.sortBy (\obj -> Tuple.first obj.size * Tuple.second obj.size) >> List.reverse
