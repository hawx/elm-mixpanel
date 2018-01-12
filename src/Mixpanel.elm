module Mixpanel
    exposing
        ( Config
        , EngageProperties
        , Event
        , Properties
        , peopleAdd
        , peopleAppend
        , peopleDelete
        , peopleRemove
        , peopleSet
        , peopleSetOnce
        , peopleUnion
        , peopleUnset
        , track
        )

{-| This library allows you to send events to Mixpanel and update user profiles.

These operation simply map to those described in the [Mixpanel HTTP Tracking API
documentation](https://mixpanel.com/help/reference/http), so refer to that for
further clarification.

# Setting up

@docs Config

# Tracking events

@docs Event, Properties, track

# Updating user profiles

@docs EngageProperties, peopleSet, peopleSetOnce, peopleAdd, peopleAppend
@docs peopleUnion, peopleRemove, peopleUnset, peopleDelete

-}

import Base64
import Dict exposing (Dict)
import Http
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


{-| Configuration for accessing Mixpanel, keep this in your Model.
-}
type alias Config =
    { baseUrl : String
    , token : String
    , ip : Bool
    }


{-| Create a default Mixpanel configuration for your token.
-}
config : String -> Config
config token =
    { baseUrl = "http://api.mixpanel.com"
    , token = token
    , ip = True
    }


{-| A list of extra properties to pass to Mixpanel.
-}
type alias Properties =
    List ( String, Value )


{-| A Mixpanel event has a name and some properties.
-}
type alias Event =
    { event : String
    , properties : Properties
    }


{-| When updating Mixpanel profiles the distinctId is required, pass it here
instead of as a property.
-}
type alias EngageProperties =
    { distinctId : String }


{-| Track sends an event to Mixpanel.

    track (config "my-token")
        { event = "Signed Up"
        , properties = [ ( "Referred By", Json.Encode.string "Friend" )
                       , ( "distinct_id", Json.Encode.string "13793" )
                       ]
        }

Mixpanel also recognises some special property names.

- `distinct_id`: a per-user ID that Mixpanel uses to group events together.
- `time`: the time the event occurred, by default Mixpanel will use the time
  they receive the event.
- `ip`: used for adding geolocation information to the event, if not given and
  if config has `ip = True` then the ip of the request is used.

An example showing all three,

    track (config "my-token")
        { event = "Level Complete"
        , properties = [ ( "Level Number", Json.Encode.int 9 )
                       , ( "distinct_id", Json.Encode.string "13793" )
                       , ( "time", Json.Encode.int 1358208000 )
                       , ( "ip", Json.Encode.string "203.0.113.9" )
                       ]
        }
-}
track : Config -> Event -> Task Http.Error ()
track { baseUrl, token, ip } event =
    Json.object
        [ "event" => Json.string event.event
        , "properties" => Json.object (( "token", Json.string token ) :: event.properties)
        ]
        |> send baseUrl ip "/track"


{-| Sets the properties on a user profile.

    peopleSet (config "my-token")
        { distinctId = "13793" }
        [ ( "Address", Json.Encode.string "1313 Mockingbird Lane" )
        , ( "Birthday", Json.Encode.string "1948-01-01" ) ]

-}
peopleSet : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleSet config engageProperties properties =
    engage config engageProperties "$set" (Json.object properties)


{-| Same as peopleSet but will not overwrite existing property values.

    peopleSetOnce (config "my-token")
        { distinctId = "13793" }
        [ ( "First login date", Json.Encode.string "2013-04-01T13:20:00" ) ]

-}
peopleSetOnce : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleSetOnce config engageProperties properties =
    engage config engageProperties "$set_once" (Json.object properties)


{-| Takes properties with numerical values and adds the values to the existing
property's value (or 0). Passing negative values will decrement the profile's
value.

    peopleAdd (config "my-token")
        { distinctId = "13793" }
        [ ( "Coins Gathered", Json.Encode.int 12 ) ]

-}
peopleAdd : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleAdd config engageProperties properties =
    engage config engageProperties "$add" (Json.object properties)


{-| Takes properties and appends each value to a list associated with the
property.

    peopleAppend (config "my-token")
         { distinctId = "13793" }
         [ ( "Power Ups", Json.Encode.string "Bubble Lead" ) ]

-}
peopleAppend : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleAppend config engageProperties properties =
    engage config engageProperties "$append" (Json.object properties)


{-| Takes properties with list values and merges them with the existing profile
values.

    peopleUnion (config "my-token")
        { distinctId = "13793" }
        [ ( "Items purchased"
          , Json.Encode.list [ Json.Encode.string "socks"
                             , Json.Encode.string "shirts"
                             ]
          )
        ]

-}
peopleUnion : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleUnion config engageProperties properties =
    engage config engageProperties "$union" (Json.object properties)


{-| Takes properties and removes the values from the associated lists on the
profile.

    peopleRemove (config "my-token")
        { distinctId = "13793" }
        [ ( "Items purchased", Json.Encode.string "socks" ) ]

-}
peopleRemove : Config -> EngageProperties -> Properties -> Task Http.Error ()
peopleRemove config engageProperties properties =
    engage config engageProperties "$remove" (Json.object properties)


{-| Takes a list of property names and removes them from the profile.

    peopleUnset (config "my-token")
        { distinctId = "13793" }
        [ "Days Overdue" ]

-}
peopleUnset : Config -> EngageProperties -> List String -> Task Http.Error ()
peopleUnset config engageProperties list =
    engage config engageProperties "$unset" (Json.list (List.map Json.string list))


{-| Delete the profile from Mixpanel.

    peopleDelete (config "my-token") { distinctId = "13793" }

-}
peopleDelete : Config -> EngageProperties -> Task Http.Error ()
peopleDelete config engageProperties =
    engage config engageProperties "$delete" (Json.string "")


engage : Config -> EngageProperties -> String -> Value -> Task Http.Error ()
engage { baseUrl, token } properties operation value =
    Json.object
        [ "$token" => Json.string token
        , "$distinct_id" => Json.string properties.distinctId
        , operation => value
        ]
        |> send baseUrl False "/engage"


send : String -> Bool -> String -> Value -> Task Http.Error ()
send baseUrl ip path data =
    Http.getString (baseUrl ++ path ++ query [ "ip=1" => ip, "data=" ++ Base64.encode (Json.encode 0 data) => True ])
        |> Http.toTask
        |> Task.map (\_ -> ())


query : List (String, Bool) -> String
query =
    List.foldl (\(value, ok) acc -> if ok then acc ++ "&" ++ value else acc) "?"

(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>
