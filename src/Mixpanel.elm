module Mixpanel exposing (Config, Event, UpdateOperation(..), engage, track)

import Base64
import Dict exposing (Dict)
import Http
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


type alias Config =
    { baseUrl : String
    , token : String
    }


type alias Event =
    { event : String
    , properties : List ( String, Value )
    }


track : Config -> Event -> Task Http.Error ()
track { baseUrl, token } event =
    Json.object
        [ "event" => Json.string event.event
        , "properties" => Json.object (( "token", Json.string token ) :: event.properties)
        ]
        |> send baseUrl "/track"


type UpdateOperation
    = Set (List ( String, Value ))
    | SetOnce (List ( String, Value ))
    | Add (List ( String, Value ))
    | Append (List ( String, Value ))
    | Union (List ( String, Value ))
    | Remove (List ( String, Value ))
    | Unset (List String)
    | Delete


type alias EngageProperties =
    { distinctId : String }


engage : Config -> EngageProperties -> UpdateOperation -> Task Http.Error ()
engage { baseUrl, token } properties operation =
    Json.object
        [ "$token" => Json.string token
        , "$distinct_id" => Json.string properties.distinctId
        , case operation of
            Set object ->
                "$set" => Json.object object

            SetOnce object ->
                "$set_once" => Json.object object

            Add object ->
                "$add" => Json.object object

            Append object ->
                "$append" => Json.object object

            Union object ->
                "$union" => Json.object object

            Remove object ->
                "$remove" => Json.object object

            Unset list ->
                "$unset" => Json.list (List.map Json.string list)

            Delete ->
                "$delete" => Json.string ""
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
