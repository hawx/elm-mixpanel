# elm-mixpanel

Pure Elm library for sending events to [Mixpanel](http://mixpanel.com/) and
tracking profiles.

```elm
type alias Model =
    { config : Mixpanel.Config
    , userId : String
    }

type Msg = NoOp | Save String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Save item ->
            { model | items = item :: items }
            ! [ do <| Mixpanel.track model.config
                    { event = "Saved"
                    , properties = [ ("distinct_id", Json.Encode.string model.userId ) ]
                    }
              , do <| Mixpanel.peopleAppend model.config
                    { distinctId = model.userId }
                    [ ( "Items", Json.Encode.string item ) ]
              ]

        NoOp -> model ! []

do : Task a e -> Cmd Msg
do task =
    Task.attempt (\_ -> NoOp) task
```
