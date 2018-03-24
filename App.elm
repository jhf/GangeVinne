module Main exposing (..)

import Html exposing (Html)
import Model exposing (..)
import Update exposing (update, Msg, lagTilfeldigOppgave)
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
    ( { steg = SkrivNavn {navn=""}
      }
    , Cmd.none
    )


subscriptions : a -> Sub Msg
subscriptions model =
    Sub.none
