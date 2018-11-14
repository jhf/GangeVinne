module View exposing (badges, hovedBoksStil, knappeStil, statistikk, view, viewSkrivNavn, visOppgave, visRegne, visRegnet)

import Art
import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Html exposing (Html)
import Html.Attributes as HA exposing (autocomplete, id, type_)
import Keydown
import List
import Model exposing (..)
import Task exposing (Task, perform)
import Time



-- VIEW


view : Model -> Browser.Document Msg
view model =
    row
        [ centerX
        , centerY
        , width <| shrink
        ]
        [ case model.steg of
            SkrivNavn { navn } ->
                viewSkrivNavn navn

            Regne info ->
                visRegne info
        ]
        |> (\ui -> { title = "Gange => Vinne", body = [ layout [] ui ] })


viewSkrivNavn : String -> Element Msg
viewSkrivNavn navn =
    column
        hovedBoksStil
        [ el
            [ padding 10
            , centerX
            ]
            (text "Velkommen til GangeVinne!")
        , el [] (text "Hva heter du?")
        , Input.text
            [ htmlAttribute <| id "navn"
            , Input.focusedOnLoad
            , htmlAttribute <| autocomplete False
            ]
            { label = Input.labelLeft [centerX] <| text "Ditt navn:"
            , text = navn
            , onChange = Skrev
            , placeholder = Nothing
            }
        , el [] (text "Velg hva du vil gjøre:")
        , row
            [ padding 10
            , spacing 20
            ]
            [ Input.button
                (knappeStil ++ [ Events.onClick <| Velg Ganging Nothing, width fill ])
                { onPress = Just <| Velg Ganging Nothing
                , label = text "Ganging"
                }
            , Input.button
                (knappeStil ++ [ Events.onClick <| Velg PlussOgMinus Nothing, width fill ])
                { onPress = Just <| Velg PlussOgMinus Nothing
                , label = text "Pluss og minus"
                }
            ]
        ]


hovedBoksStil : List (Attribute msg)
hovedBoksStil =
    [ Border.width 2
    , Border.rounded 5
    , padding 10
    , spacing 5
    , height shrink
    ]


knappeStil : List (Attribute msg)
knappeStil =
    [ Border.color Art.lightBlue
    , Border.solid
    , Border.rounded 5
    , Border.width 2
    , Background.color Art.white
    , padding 5
    ]


visRegne : RegneInfo -> Element Msg
visRegne info =
    let
        sendSvar =
            Svar info.oppgave info.skrevet

        seconds =
            Time.posixToMillis info.venteTid // 1000

        ones =
            remainderBy seconds 10

        tens =
            seconds // 10

        hundreds =
            seconds // 100

        oneCells =
            List.repeat ones <| el [ Background.color Art.white ] <| text "."

        tenCells =
            List.repeat tens <| el [ Background.color Art.lightBlue ] <| text "-"

        hundredCells =
            List.repeat hundreds <| el [ Background.color Art.blue ] <| text "|"

        timer =
            row [ width shrink ]
                [ text "⏱"
                , row [] hundredCells
                , row [] tenCells
                , row [] oneCells
                ]
    in
    column
        [ spacing 10 ]
        [ column
            hovedBoksStil
            [ el [] (text <| info.navn ++ badges info.regnet)
            , el [] (text "Svar på oppgaven")
            , row
                [ spacing 10 ]
                [ el [] <| visOppgave info.oppgave
                , Input.text
                    [ htmlAttribute <| id "svar"
                    , htmlAttribute <| type_ "text"
                    , htmlAttribute <| HA.attribute "pattern" "[0-9]*"
                    , Input.focusedOnLoad
                    , Keydown.onKeydown [ Keydown.onEnter sendSvar ]
                    , htmlAttribute <| autocomplete False
                    , width <| px 75
                    ]
                    { label = Input.labelLeft [] none
                    , text = info.skrevet
                    , onChange = Skrev
                    , placeholder = Nothing
                    }
                ]
            , timer
            ]
        , visRegnet info.regnet
        ]


badges : List Gjort -> String
badges regnet =
    let
        stat =
            statistikk regnet

        avatar =
            if stat.antall > 30 then
                "🐅"

            else if stat.antall > 20 then
                "🐈"

            else if stat.antall > 10 then
                "🐁"

            else if stat.antall > 0 then
                "🐀"

            else
                ""

        hastighet =
            if stat.vektetTid > 20 then
                "🐢"

            else if stat.vektetTid > 10 then
                "🐕"

            else if stat.vektetTid > 0 then
                "🐇"

            else
                ""

        ferdighet =
            if stat.riktige > 20 then
                "🐘"

            else if stat.riktige > 10 then
                "🐬"

            else if stat.riktige > 0 then
                "\u{1F989}"

            else
                ""
    in
    avatar ++ hastighet ++ ferdighet


statistikk : List Gjort -> { riktige : Int, gale : Int, totalTid : Float, antall : Float, vektetTid : Float, snittTid : Float }
statistikk regnet =
    let
        tidsVekt =
            0.5

        tell gjort stat =
            let
                nyttAntall =
                    stat.antall + 1

                nyVektetTid =
                    toFloat gjort.tid + stat.vektetTid * stat.antall * tidsVekt / nyttAntall

                nextStat =
                    { stat
                        | antall = nyttAntall
                        , vektetTid = nyVektetTid
                        , totalTid = stat.totalTid + toFloat gjort.tid
                    }
            in
            case gjort.resultat of
                Riktig ->
                    { nextStat | riktige = stat.riktige + 1 }

                Galt ->
                    { nextStat | gale = stat.gale + 1 }

        stats : { riktige : Int, gale : Int, totalTid : Float, antall : Float, vektetTid : Float }
        stats =
            List.foldl tell { riktige = 0, gale = 0, totalTid = 0, antall = 0, vektetTid = 0 } regnet
    in
    { riktige = stats.riktige
    , gale = stats.gale
    , totalTid = stats.totalTid
    , antall = stats.antall
    , vektetTid = stats.vektetTid
    , snittTid = stats.totalTid / stats.antall
    }


visRegnet : List Gjort -> Element Msg
visRegnet regnet =
    let
        deler gjort =
            let
                ( første, operator, andre ) =
                    case gjort.oppgave of
                        Gange a b ->
                            ( a, "*", b )

                        Pluss a b ->
                            ( a, "+", b )

                        Minus a b ->
                            ( a, "-", b )
            in
            [ el [ Font.alignRight ] <| text <| String.fromInt første
            , el [ Font.center ] <| text <| operator
            , el [ Font.alignRight ] <| text <| String.fromInt andre
            ]

        erLik gjort =
            case gjort.resultat of
                Riktig ->
                    el [ Font.center, Background.color Art.green ] <| text "="

                Galt ->
                    el [ Font.center, Background.color Art.red ] <| text "≠"

        visSvar gjort =
            el [ Font.alignRight ] <| text <| String.fromInt gjort.svar

        historikk =
            case regnet of
                [] ->
                    none

                gjort :: _ ->
                    case gjort.resultat of
                        Riktig ->
                            none

                        Galt ->
                            row
                                (hovedBoksStil
                                    ++ [ padding 5
                                       , spacing 5
                                       ]
                                )
                                (deler gjort
                                    ++ [ erLik gjort
                                       , visSvar gjort
                                       ]
                                )

        oppsummering =
            let
                stat =
                    statistikk regnet
            in
            row [ padding 5, spacing 10, width fill, centerX ]
                [ el [ padding 5, alignLeft ] <| text <| "✅" ++ String.fromInt stat.riktige
                , el [ padding 5, centerX ] <| text <| "⏱" ++ (String.fromInt <| round stat.snittTid)
                , el [ padding 5, alignRight ] <| text <| "❌" ++ String.fromInt stat.gale
                ]
    in
    column []
        [ oppsummering
        , historikk
        ]


visOppgave : Oppgave -> Element msg
visOppgave oppgave =
    let
        ( a_, op, b_ ) =
            case oppgave of
                Gange a b ->
                    ( a, "*", b )

                Pluss a b ->
                    ( a, "+", b )

                Minus a b ->
                    ( a, "-", b )

        a__ =
            String.fromInt a_

        b__ =
            String.fromInt b_

        regneStykke =
            a__ ++ " " ++ op ++ " " ++ b__
    in
    text <| regneStykke ++ " ="
