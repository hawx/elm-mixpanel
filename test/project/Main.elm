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
    ( (), Task.attempt (\_ -> ()) (runCommand url token command) )


runCommand url token command =
    case command of
        "track" ->
            track url token

        "engage" ->
            engage url token

        "engage_set_once" ->
            engageSetOnce url token

        "engage_add" ->
            engageAdd url token

        "engage_append" ->
            engageAppend url token

        "engage_union" ->
            engageUnion url token

        "engage_remove" ->
            engageRemove url token

        "engage_unset" ->
            engageUnset url token

        "engage_delete" ->
            engageDelete url token

        _ ->
            Task.succeed ()


track url token =
    Mixpanel.track
        { baseUrl = url, token = token }
        { event = "game", properties = [] }


engage url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.Set [ ( "Address", Json.string "123 Fake Street" ) ])


engageSetOnce url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.SetOnce [ ( "Address", Json.string "123 Fake Street" ) ])


engageAdd url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.Add [ ( "Coins Gathered", Json.int 12 ) ])


engageAppend url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.Append [ ( "Power Ups", Json.string "Bubble Lead" ) ])


engageUnion url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.Union
            [ ( "Items Purchased"
              , Json.list
                    [ Json.string "socks"
                    , Json.string "shirts"
                    ]
              )
            ]
        )


engageRemove url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.Remove [ ( "Items Purchased", Json.string "socks" ) ])


engageUnset url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        (Mixpanel.Unset [ "Days Overdue" ])


engageDelete url token =
    Mixpanel.engage
        { baseUrl = url, token = token }
        { distinctId = "12345" }
        Mixpanel.Delete
