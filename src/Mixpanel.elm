module Mixpanel exposing (track)

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


send : String -> String -> Value -> Task Http.Error ()
send baseUrl path data =
    Http.getString (baseUrl ++ path ++ "?data=" ++ Base64.encode (Json.encode 0 data))
        |> Http.toTask
        |> Task.map (\_ -> ())


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>
