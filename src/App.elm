module App exposing (..)

import Html exposing (Html)
import Model exposing (..)
import Update exposing (update, Msg, lagTilfeldigOppgave)
import View exposing (view)
import Ports exposing (storageGetItem, storageGetItemReply, storageKeys)
import Json.Decode as JD


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { steg = SkrivNavn { navn = "" }
      }
    , storageGetItem storageKeys.name
    )


subscriptions : a -> Sub Msg
subscriptions model =
    let
        handler {key, value} = 
            if key == storageKeys.name then
                case JD.decodeValue JD.string value of
                    Ok name -> 
                        Update.Skrev name
                    Err msg ->
                        Update.Ingenting
            else
                Update.Ingenting

    in
    storageGetItemReply handler
