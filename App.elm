module Main exposing (..)

import Html exposing (Html)
import Model exposing (..)
import Update exposing (update, Msg,lagTilfeldigOppgave)
import View exposing (view)


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
    ( { oppgave = Gange 0 0
      , regnet = []
      , skrevet = ""
      }
    , lagTilfeldigOppgave
    )


subscriptions : a -> Sub Msg
subscriptions model =
    Sub.none



