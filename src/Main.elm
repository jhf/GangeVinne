module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Model exposing (..)
import Storage
import Time exposing (every)
import Update exposing (lagTilfeldigOppgave, update)
import View exposing (view)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { steg = SkrivNavn { navn = "" }
      }
    , Storage.loadName
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        ticker =
            case model.steg of
                SkrivNavn _ ->
                    Sub.none

                Regne _ ->
                    every 1000 Tid
    in
    Sub.batch [ Storage.readName, ticker ]
