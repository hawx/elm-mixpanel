module Mixpanel
    exposing
        ( Config
        , EngageProperties
        , Event
        , Properties
        , peopleAdd
        , peopleAppend
        , peopleDelete
        , peopleRemove
        , peopleSet
        , peopleSetOnce
        , peopleUnion
        , peopleUnset
        , track
        )

import Base64
import Dict exposing (Dict)
import Http
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


type alias Config =
    { baseUrl : String
    , token : String
    }


type alias Properties =
    List ( String, Value )


type alias Event =
    { event : String
    , properties : Properties
    }


type alias EngageProperties =
    { distinctId : String }


track : Config -> Event -> Task Http.Error ()
track { baseUrl, token } event =
    Json.object
        [ "event" => Json.string event.event
        , "properties" => Json.object (( "token", Json.string token ) :: event.properties)
        ]
        |> send baseUrl "/track"


peopleSet : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleSet config engageProperties properties =
    engage config engageProperties "$set" (Json.object properties)


peopleSetOnce : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleSetOnce config engageProperties properties =
    engage config engageProperties "$set_once" (Json.object properties)


peopleAdd : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleAdd config engageProperties properties =
    engage config engageProperties "$add" (Json.object properties)


peopleAppend : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleAppend config engageProperties properties =
    engage config engageProperties "$append" (Json.object properties)


peopleUnion : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleUnion config engageProperties properties =
    engage config engageProperties "$union" (Json.object properties)


peopleRemove : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleRemove config engageProperties properties =
    engage config engageProperties "$remove" (Json.object properties)


peopleUnset : Config -> EngageProperties -> List String -> Task Http.Error ()
peopleUnset config engageProperties list =
    engage config engageProperties "$unset" (Json.list (List.map Json.string list))


peopleDelete : Config -> EngageProperties -> Task Http.Error ()
peopleDelete config engageProperties =
    engage config engageProperties "$delete" (Json.string "")


engage : Config -> EngageProperties -> String -> Value -> Task Http.Error ()
engage { baseUrl, token } properties operation value =
    Json.object
        [ "$token" => Json.string token
        , "$distinct_id" => Json.string properties.distinctId
        , operation => value
        ]
        |> send baseUrl "/engage"


send : String -> String -> Value -> Task Http.Error ()
send baseUrl path data =
    Http.getString (baseUrl ++ path ++ "?data=" ++ Base64.encode (Json.encode 0 data))
        |> Http.toTask
        |> Task.map (\_ -> ())


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>
