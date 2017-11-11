port module Main exposing (..)

import Json.Encode as Json
import Mixpanel
import Task


type alias Flags =
    { url : String, token : String, command : String }


main : Program Flags () ()
main =
    Platform.programWithFlags
        { init = sendResult
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


sendResult : Flags -> ( (), Cmd () )
sendResult { url, token, command } =
    ( (), Task.attempt (\_ -> ()) (track url token) )


track url token =
    Mixpanel.track { baseUrl = url, token = token } { event = "game", properties = [] }
