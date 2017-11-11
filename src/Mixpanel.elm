module Mixpanel exposing (track)

import Http
import Task exposing (Task)


track : String -> String -> Task Http.Error ()
track root event =
    Http.getString (root ++ "/track") |> Http.toTask |> Task.map (\_ -> ())
