module App exposing (..)

import Html exposing (Html)
import Model exposing (..)
import Update exposing (update, lagTilfeldigOppgave)
import View exposing (view)
import Storage


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
    , Storage.loadName
    )


subscriptions : a -> Sub Msg
subscriptions model =
    Storage.readName