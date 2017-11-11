module Mixpanel exposing (track)

import Base64
import Http
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


track : String -> String -> Task Http.Error ()
track root event =
    send root "/track" (Json.object [])


send : String -> String -> Value -> Task Http.Error ()
send baseUrl path data =
    Http.getString (baseUrl ++ path ++ "?data=" ++ Base64.encode (Json.encode 0 data))
        |> Http.toTask
        |> Task.map (\_ -> ())
