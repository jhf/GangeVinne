module View exposing (view)

import Art
import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA exposing (autocomplete, id, type_)
import Keydown
import List
import Model exposing (..)
import Time



-- VIEW


view : Model -> Browser.Document Msg
view model =
    row
        [ centerX
        , centerY
        , width <| shrink
        ]
        [ case model of
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
            { label = Input.labelLeft [ centerX ] <| text "Ditt navn:"
            , text = navn
            , onChange = Skrev
            , placeholder = Nothing
            }
        , el [] (text "Velg hva du vil gjøre:")
        , let
            ganging =
                Velg Ganging Nothing Nothing

            plussogminus =
                Velg PlussOgMinus Nothing Nothing
          in
          row
            [ padding 10
            , spacing 20
            ]
            [ Input.button
                (width fill :: Keydown.onKeydown [ Keydown.onSpace ganging ] :: knappeStil)
                { onPress = Just ganging
                , label = text "Ganging"
                }
            , Input.button
                (width fill :: Keydown.onKeydown [ Keydown.onSpace plussogminus ] :: knappeStil)
                { onPress = Just plussogminus
                , label = text "Pluss og minus"
                }
            ]
        ]


standardSkrift : List (Attribute msg)
standardSkrift =
    [ Font.size 48 ]


hovedBoksStil : List (Attribute msg)
hovedBoksStil =
    standardSkrift
        ++ [ Border.width 2
           , Border.rounded 5
           , padding 10
           , spacing 5
           , height shrink
           ]


knappeStil : List (Attribute msg)
knappeStil =
    standardSkrift
        ++ [ Border.color Art.lightBlue
           , Border.solid
           , Border.rounded 5
           , Border.width 2
           , padding 5
           ]


visRegne : RegneInfo -> Element Msg
visRegne info =
    let
        sendSvar =
            Svar info.oppgave info.skrevet

        seconds =
            (Time.posixToMillis info.stopTid - Time.posixToMillis info.startTid)
                // 1000

        ones =
            seconds |> modBy 10

        tens =
            seconds // 10 |> modBy 10

        hundreds =
            seconds // 100 |> modBy 10

        oneCells =
            List.repeat ones <| el [ Background.color Art.white ] <| text "."

        tenCells =
            List.repeat tens <| el [ Background.color Art.lightBlue ] <| text "-"

        hundredCells =
            List.repeat hundreds <| el [ Background.color Art.blue ] <| text "|"

        timer =
            row [ width shrink ]
                [ Input.button
                    [ focused []
                    ]
                    { onPress = Just Pause
                    , label =
                        text <|
                            if info.pause then
                                "💤"

                            else
                                "⏱"
                    }
                , row [] hundredCells
                , row [] tenCells
                , row [] oneCells
                ]
    in
    column
        (standardSkrift ++ [ spacing 10 ])
        [ column
            hovedBoksStil
            [ el [] (text <| info.navn ++ badges info.regnet)
            , el [ centerX ]
                (text <|
                    if info.pause then
                        "Pause"

                    else
                        "Svar på oppgaven"
                )
            , if info.pause then
                el [ centerX ] <| text "😴"

              else
                el [ centerX ]
                    (row
                        [ spacing 10 ]
                        [ el [] <| visOppgave info.oppgave
                        , Input.text
                            [ htmlAttribute <| id htmlIdSvar
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
                    )
            , timer
            ]
        , el [ width fill ] <| visRegnet info.regnet
        ]


badges : List Gjort -> String
badges regnet =
    let
        stat =
            statistikk regnet

        avatar =
            if stat.antall > 50 then
                "🐙"

            else if stat.antall > 40 then
                "🐳"

            else if stat.antall > 30 then
                "🐅"

            else if stat.antall > 20 then
                "🐈"

            else if stat.antall > 10 then
                "🐁"

            else if stat.antall > 5 then
                "🐀"

            else
                "🐞"

        hastighet =
            if stat.vektetTid > 30 then
                "🐌"

            else if stat.vektetTid > 20 then
                "🐢"

            else if stat.vektetTid > 10 then
                "🐕"

            else if stat.vektetTid > 0 then
                "🐇"

            else
                ""

        ferdighet =
            if stat.riktige > 20 then
                "🐊"

            else if stat.riktige > 10 then
                "\u{1F9A7}"

            else if stat.riktige > 0 then
                "🐬"

            else if stat.riktige == 0 then
                "🐘"

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
    , snittTid =
        if stats.antall > 0 then
            stats.totalTid / stats.antall

        else
            0
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
            row [ padding 5, spacing 10, width fill ]
                [ el [ padding 5, alignLeft ] <| text <| "✅" ++ String.fromInt stat.riktige
                , el [ padding 5, centerX ] <| text <| "⏱" ++ (String.fromInt <| round stat.snittTid)
                , el [ padding 5, alignRight ] <| text <| "❌" ++ String.fromInt stat.gale
                ]
    in
    column [ width fill ]
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
