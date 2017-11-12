port module Main exposing (..)

import Http
import Json.Encode as Json
import Mixpanel
import Task exposing (Task)


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
    ( (), Task.attempt (\_ -> ()) (runCommand { baseUrl = url, token = token } command) )


runCommand : Mixpanel.Config -> String -> Task Http.Error ()
runCommand config command =
    case command of
        "track" ->
            track config

        "engage_set" ->
            engageSet config

        "engage_set_once" ->
            engageSetOnce config

        "engage_add" ->
            engageAdd config

        "engage_append" ->
            engageAppend config

        "engage_union" ->
            engageUnion config

        "engage_remove" ->
            engageRemove config

        "engage_unset" ->
            engageUnset config

        "engage_delete" ->
            engageDelete config

        _ ->
            Task.succeed ()


track config =
    Mixpanel.track config
        { event = "game", properties = [] }


engageSet config =
    Mixpanel.peopleSet config
        { distinctId = "12345" }
        [ ( "Address", Json.string "123 Fake Street" ) ]


engageSetOnce config =
    Mixpanel.peopleSetOnce config
        { distinctId = "12345" }
        [ ( "Address", Json.string "123 Fake Street" ) ]


engageAdd config =
    Mixpanel.peopleAdd config
        { distinctId = "12345" }
        [ ( "Coins Gathered", Json.int 12 ) ]


engageAppend config =
    Mixpanel.peopleAppend config
        { distinctId = "12345" }
        [ ( "Power Ups", Json.string "Bubble Lead" ) ]


engageUnion config =
    Mixpanel.peopleUnion config
        { distinctId = "12345" }
        [ ( "Items Purchased"
          , Json.list
                [ Json.string "socks"
                , Json.string "shirts"
                ]
          )
        ]


engageRemove config =
    Mixpanel.peopleRemove config
        { distinctId = "12345" }
        [ ( "Items Purchased", Json.string "socks" ) ]


engageUnset config =
    Mixpanel.peopleUnset config
        { distinctId = "12345" }
        [ "Days Overdue" ]


engageDelete config =
    Mixpanel.peopleDelete config
        { distinctId = "12345" }
