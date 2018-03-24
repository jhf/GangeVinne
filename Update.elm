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
    | Navn
    | Skrev String
    | NyOppgave Oppgave
    | Ingenting


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.steg of
        SkrivNavn { navn } ->
            case msg of
                Skrev noe ->
                    ( { model | steg = SkrivNavn { navn = noe } }, Cmd.none )
                Navn ->
                    let
                        info =
                            { navn = navn
                            , oppgave = Gange 0 0
                            , regnet = []
                            , skrevet = ""
                            }
                    in
                    ( {model | steg = Regne info}
                    , lagTilfeldigOppgave
                    )

                _ ->
                    ( model, Cmd.none )

        Regne info ->
            case msg of
                Ingenting ->
                    ( model, Cmd.none )

                Navn ->
                    ( model, Cmd.none )

                NyOppgave oppgave ->
                    ( { model | steg = Regne { info | oppgave = oppgave } }, Cmd.none )

                Skrev noe ->
                    ( { model | steg = Regne { info | skrevet = noe } }, Cmd.none )

                Svar ((Gange a b) as oppgave) skrevet ->
                    case toInt skrevet of
                        Err _ ->
                            ( { model | steg = Regne { info | skrevet = "" } }, Cmd.none )

                        Ok svar ->
                            let
                                resultat =
                                    if svar == a * b then
                                        Riktig
                                    else
                                        Galt

                                gjort =
                                    { oppgave = oppgave, svar = svar, resultat = resultat }

                                nyttSteg =
                                    Regne
                                        { info
                                            | regnet = gjort :: info.regnet
                                            , skrevet = ""
                                        }
                            in
                                ( { model | steg = nyttSteg }, Cmd.batch [ lagTilfeldigOppgave, hoppTilSkriving ] )


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
        Random.generate lagOppgave toTilfeldigeTall


toTilfeldigeTall : Random.Generator ( Int, Int )
toTilfeldigeTall =
    Random.pair (Random.int 0 10) (Random.int 0 10)
