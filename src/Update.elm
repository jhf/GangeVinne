module Update exposing (..)

import List
import String exposing (toInt)
import Random
import Dom
import Task
import Model exposing (..)
import Storage exposing (storeName)


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.steg of
        SkrivNavn { navn } ->
            case msg of
                Skrev noe ->
                    ( { model | steg = SkrivNavn { navn = noe } }
                    , storeName noe
                    )

                Velg oppgaveType ->
                    let
                        info =
                            { navn = navn
                            , oppgave = Gange 0 0
                            , siffer = 1
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
                    let
                        fasit =
                            regnUt oppgave

                        siffer =
                            String.length <| toString <| fasit
                    in
                        ( { model | steg = Regne { info | oppgave = oppgave, siffer = siffer } }, Cmd.none )

                Skrev noe ->
                    let
                        skrevetSiffer =
                            String.length noe
                    in
                        if skrevetSiffer < info.siffer then
                            ( { model | steg = Regne { info | skrevet = noe } }, Cmd.none )
                        else
                            let
                                ( steg, cmd ) =
                                    svar info noe
                            in
                                ( { model | steg = steg }, cmd )

                Svar oppgave skrevet ->
                    let
                        ( steg, cmd ) =
                            svar info skrevet
                    in
                        ( { model | steg = steg }, cmd )


svar : RegneInfo -> String -> ( Steg, Cmd Msg )
svar info skrevet =
    case toInt skrevet of
        Err _ ->
            ( Regne { info | skrevet = "" }, Cmd.none )

        Ok svar ->
            let
                fasit =
                    regnUt info.oppgave

                resultat =
                    if svar == fasit then
                        Riktig
                    else
                        Galt

                gjort =
                    { oppgave = info.oppgave, svar = svar, resultat = resultat }

                nyttSteg =
                    Regne
                        { info
                            | regnet = gjort :: info.regnet
                            , skrevet = ""
                        }
            in
                ( nyttSteg
                , Cmd.batch
                    [ lagTilfeldigOppgave info.oppgaveType
                    , hoppTilSkriving
                    ]
                )


regnUt : Oppgave -> Int
regnUt oppgave =
    case oppgave of
        Gange a b ->
            a * b

        Pluss a b ->
            a + b

        Minus a b ->
            a - b


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
                minste =
                    0

                største =
                    20

                lageTilfeldigeTall =
                    Random.map3 lagOppgave Random.bool (Random.int minste største) (Random.int minste største)

                lagMinus a b =
                    if a > b then
                        Minus a b
                    else
                        Minus b a

                lagOppgave pluss a b =
                    if pluss then
                        if a + b > største then
                            lagMinus a b
                        else
                            Pluss a b
                    else
                        lagMinus a b
            in
                Random.generate NyOppgave lageTilfeldigeTall
