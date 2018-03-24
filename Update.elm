module Update exposing (..)

import List
import String exposing (toInt)
import Random
import Dom
import Task
import Model exposing (..)


-- UPDATE


type Msg
    = Svar Oppgave String
    | Skrev String
    | NyOppgave Oppgave
    | Ingenting


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ingenting ->
            ( model, Cmd.none )

        NyOppgave oppgave ->
            ( { model | oppgave = oppgave }, Cmd.none )

        Skrev noe ->
            ( { model | skrevet = noe }, Cmd.none )

        Svar ((Gange a b) as oppgave) skrevet ->
            case toInt skrevet of
                Err _ ->
                    ( model, Cmd.none )

                Ok svar ->
                    let
                        resultat =
                            if svar == a * b then
                                Riktig
                            else
                                Galt

                        gjort =
                            ( oppgave, svar, resultat )

                        nyModel =
                            { model
                                | regnet = gjort :: model.regnet
                                , skrevet = ""
                            }
                    in
                        ( nyModel, Cmd.batch [ lagTilfeldigOppgave, hoppTilSkriving ] )


hoppTilSkriving : Cmd Msg
hoppTilSkriving =
    Dom.focus "svar"
        |> Task.attempt (\_ -> Ingenting)


lagTilfeldigOppgave : Cmd Msg
lagTilfeldigOppgave =
    let
        lagOppgave ( a, b ) =
            NyOppgave <| Gange a b
    in
        Random.generate lagOppgave randomPoint


randomPoint : Random.Generator ( Int, Int )
randomPoint =
    Random.pair (Random.int 0 10) (Random.int 0 10)
