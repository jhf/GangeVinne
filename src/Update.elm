module Update exposing (update)

import Browser.Dom as Dom
import List
import Model exposing (..)
import Random
import Storage exposing (storeName)
import String exposing (toInt)
import Task
import Time



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( _, Velg oppgaveType Nothing Nothing ) ->
            ( model
            , lagOppgave oppgaveType
            )

        ( _, Velg oppgaveType (Just oppgave) Nothing ) ->
            ( model
            , Task.perform
                (\tid ->
                    Velg oppgaveType (Just oppgave) (Just tid)
                )
                Time.now
            )

        ( _, Velg oppgaveType (Just oppgave) (Just tid) ) ->
            let
                fasit =
                    regnUt oppgave
            in
            ( Regne
                { navn =
                    case model of
                        Regne info ->
                            info.navn

                        SkrivNavn { navn } ->
                            navn
                , oppgave = oppgave
                , fasit = fasit
                , siffer = String.length <| String.fromInt <| fasit
                , regnet =
                    case model of
                        Regne info ->
                            info.regnet

                        SkrivNavn _ ->
                            []
                , skrevet = ""
                , oppgaveType = oppgaveType
                , startTid = tid
                , stopTid = tid
                , waitedSeconds = 0
                }
            , hoppTilSkriving
            )

        ( _, Velg _ _ _ ) ->
            ( model, Cmd.none )

        ( SkrivNavn { navn }, Skrev noe ) ->
            ( SkrivNavn { navn = noe }
            , storeName noe
            )

        ( Regne info, Skrev noe ) ->
            let
                skrevetSiffer =
                    String.length noe
            in
            if skrevetSiffer < info.siffer then
                ( Regne { info | skrevet = noe }, Cmd.none )

            else
                sjekkSvar info noe

        ( Regne info, Svar oppgave skrevet ) ->
            sjekkSvar info skrevet

        ( Regne info, Tid tid ) ->
            ( Regne
                { info
                    | stopTid = tid
                    , waitedSeconds =
                        (Time.posixToMillis info.stopTid - Time.posixToMillis info.startTid)
                            // 1000
                }
            , Cmd.none
            )

        ( _, Ingenting ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


sjekkSvar : RegneInfo -> String -> ( Model, Cmd Msg )
sjekkSvar info skrevet =
    case toInt skrevet of
        Nothing ->
            ( Regne { info | skrevet = "" }, Cmd.none )

        Just svar ->
            let
                resultat =
                    if svar == info.fasit then
                        Riktig

                    else
                        Galt

                gjort =
                    { oppgave = info.oppgave
                    , svar = svar
                    , resultat = resultat
                    , tid = info.waitedSeconds
                    }

                model =
                    Regne
                        { info
                            | regnet = gjort :: info.regnet
                            , skrevet = ""
                            , stopTid = info.stopTid
                            , startTid = info.stopTid
                        }
            in
            ( model, lagOppgave info.oppgaveType )


lagOppgave : OppgaveType -> Cmd Msg
lagOppgave oppgaveType =
    Random.generate
        (\oppgave ->
            Velg oppgaveType (Just oppgave) Nothing
        )
        (oppgaveGenerator oppgaveType)


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


oppgaveGenerator : OppgaveType -> Random.Generator Oppgave
oppgaveGenerator oppgaveType =
    let
        lagMinus a b =
            if a > b then
                Minus a b

            else
                Minus b a
    in
    case oppgaveType of
        Ganging ->
            Random.map2
                (\a b -> Gange a b)
                (Random.int 0 12)
                (Random.int 0 12)

        PlussOgMinus ->
            let
                minste =
                    0

                største =
                    20
            in
            Random.map3
                (\pluss a b ->
                    if pluss then
                        if a + b > største then
                            lagMinus a b

                        else
                            Pluss a b

                    else
                        lagMinus a b
                )
                (Random.uniform True [ False ])
                (Random.int minste største)
                (Random.int minste største)
