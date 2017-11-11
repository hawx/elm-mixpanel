port module Main exposing (..)

import Mixpanel
import Task


type alias Flags =
    { url : String, command : String }


main : Program Flags () ()
main =
    Platform.programWithFlags
        { init = sendResult
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


sendResult : Flags -> ( (), Cmd () )
sendResult { url, command } =
    ( (), Task.attempt (\_ -> ()) (Mixpanel.track url "cool") )
