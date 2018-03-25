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
    | Velg OppgaveType
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

                Velg oppgaveType ->
                    let
                        info =
                            { navn = navn
                            , oppgave = Gange 0 0
                            , regnet = []
                            , skrevet = ""
                            , oppgaveType = oppgaveType
                            }
                    in
                        ( { model | steg = Regne info }
                        , lagTilfeldigOppgave info.oppgaveType
                        )

                _ ->
                    ( model, Cmd.none )

        Regne info ->
            case msg of
                Ingenting ->
                    ( model, Cmd.none )

                Velg _ ->
                    ( model, Cmd.none )

                NyOppgave oppgave ->
                    ( { model | steg = Regne { info | oppgave = oppgave } }, Cmd.none )

                Skrev noe ->
                    ( { model | steg = Regne { info | skrevet = noe } }, Cmd.none )

                Svar oppgave skrevet ->
                    case toInt skrevet of
                        Err _ ->
                            ( { model | steg = Regne { info | skrevet = "" } }, Cmd.none )

                        Ok svar ->
                            let
                                resultat =
                                    case oppgave of
                                        Gange a b ->
                                            if svar == a * b then
                                                Riktig
                                            else
                                                Galt

                                        Pluss a b ->
                                            if svar == a + b then
                                                Riktig
                                            else
                                                Galt

                                        Minus a b ->
                                            if svar == a - b then
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
                                ( { model | steg = nyttSteg }
                                , Cmd.batch
                                    [ lagTilfeldigOppgave info.oppgaveType
                                    , hoppTilSkriving
                                    ]
                                )


hoppTilSkriving : Cmd Msg
hoppTilSkriving =
    Dom.focus "svar"
        |> Task.attempt (\_ -> Ingenting)


lagTilfeldigOppgave : OppgaveType -> Cmd Msg
lagTilfeldigOppgave oppgaveType =
    case oppgaveType of
        Ganging ->
            let
                toTilfeldigeTall =
                    Random.pair (Random.int 0 10) (Random.int 0 10)

                lagOppgave ( a, b ) =
                    NyOppgave <| Gange a b
            in
                Random.generate lagOppgave toTilfeldigeTall

        PlussOgMinus ->
            let
                lageTilfeldigeTall =
                    Random.map3 lagOppgave Random.bool (Random.int 0 20) (Random.int 0 20)

                lagOppgave pluss a b =
                    if pluss then
                        Pluss a b
                    else
                        Minus a b
            in
                Random.generate NyOppgave lageTilfeldigeTall
