module Mixpanel exposing (track)

import Base64
import Dict exposing (Dict)
import Http
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


{- {"event": "game", "properties": {"ip": "123.123.123.123", "distinct_id": "13793", "token": "e3bb4100330c35722740fb8c6f5abddc", "time": 1245613885, "action": "play"}} -}


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
    send baseUrl
        "/track"
        (Json.object
            [ "event" => Json.string event.event
            , "properties" => Json.object (( "token", Json.string token ) :: event.properties)
            ]
        )


send : String -> String -> Value -> Task Http.Error ()
send baseUrl path data =
    Http.getString (baseUrl ++ path ++ "?data=" ++ Base64.encode (Json.encode 0 data))
        |> Http.toTask
        |> Task.map (\_ -> ())


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>
