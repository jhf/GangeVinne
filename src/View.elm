module View exposing (..)

import List
import Color
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Keyed as Keyed
import Element.Background as Background
import Element.Border as Border
import Html exposing (Html)
import Html.Attributes as HA exposing (id, autocomplete, type_)
import Model exposing (..)
import Keyboard


-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        Element.row
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


viewSkrivNavn : String -> Element Msg
viewSkrivNavn navn =
    Element.column
        hovedBoksStil
        [ Element.el
            [ padding 10
            , centerX
            ]
            (Element.text "Velkommen til GangeVinne!")
        , Element.el [] (Element.text "Hva heter du?")
        , Input.text
            [ htmlAttribute <| id "navn"
            , Input.focusedOnLoad
            , htmlAttribute <| autocomplete False
            ]
            { label = Input.labelLeft [] <| Element.text "Ditt navn:"
            , text = navn
            , onChange = Just Skrev
            , placeholder = Nothing
            }
        , Element.el [] (Element.text "Velg hva du vil gjøre:")
        , Element.row
            [ Element.padding 10
            , Element.spacing 20
            ]
            [ Input.button
                (knappeStil ++ [ Events.onClick <| Velg Ganging, width fill ])
                { onPress = Just <| Velg Ganging
                , label = Element.text "Ganging"
                }
            , Input.button
                (knappeStil ++ [ Events.onClick <| Velg PlussOgMinus, width fill ])
                { onPress = Just <| Velg PlussOgMinus
                , label = Element.text "Pluss og minus"
                }
            ]
        ]


hovedBoksStil : List (Attribute msg)
hovedBoksStil =
    [ Border.width 2
    , Border.rounded 5
    , Element.padding 10
    , Element.spacing 5
    , Element.height Element.shrink
    ]


knappeStil : List (Attribute msg)
knappeStil =
    [ Border.color Color.lightBlue
    , Border.solid
    , Border.rounded 5
    , Border.width 2
    , Background.color Color.white
    , padding 5
    ]


visRegne : RegneInfo -> Element Msg
visRegne info =
    let
        sendSvar =
            Svar info.oppgave info.skrevet
        seconds =
            info.venteTid
        ones =
            (floor seconds) % 10
        tens =
            floor <| seconds / 10
        hundreds =
            floor <| seconds / 100
        oneCells =
            List.repeat ones <| Element.el [Background.color Color.white] <| text "."
        tenCells =
            List.repeat tens <| Element.el [Background.color Color.lightBlue] <| text "-"
        hundredCells =
            List.repeat hundreds <| Element.el [Background.color Color.blue] <| text "|"
        timer =
            Element.row [width shrink]
                [ text "⏱"
                , Element.row [] hundredCells
                , Element.row [] tenCells
                , Element.row [] oneCells
                ]
    in
        Element.column
            [ Element.spacing 10 ]
            [ Element.column
                hovedBoksStil
                [ Element.el [] (Element.text <| info.navn ++ (badges info.regnet))
                , Element.el [] (Element.text "Svar på oppgaven")
                , Element.row
                    [ spacing 10 ]
                    [ Element.el [] <| visOppgave info.oppgave
                    , Input.text
                        [ htmlAttribute <| id "svar"
                        , htmlAttribute <| type_ "text"
                        , htmlAttribute <| HA.attribute "pattern" "[0-9]*"
                        , Input.focusedOnLoad
                        , Keyboard.onKeydown [ Keyboard.onEnter sendSvar ]
                        , htmlAttribute <| autocomplete False
                        , width <| px 75
                        ]
                        { label = Input.labelLeft [] Element.empty
                        , text = info.skrevet
                        , onChange = Just Skrev
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
                "🦉"
            else if stat.riktige > 0 then
            else
                ""
    in
        avatar ++ hastighet ++ ferdighet

statistikk : List Gjort -> {riktige: Int, gale: Int, totalTid: Float, antall: Float, vektetTid: Float, snittTid: Float}
statistikk regnet =
    let
        tidsVekt = 0.5
        tell gjort ( riktige, gale, totalTid, antall, vektetTid) =
            let
                nyttAntall = antall + 1
                nyVektetTid = gjort.tid + vektetTid*antall*tidsVekt / nyttAntall
            in
            case gjort.resultat of
                Riktig ->
                    ( riktige + 1, gale, totalTid + gjort.tid, nyttAntall, nyVektetTid )

                Galt ->
                    ( riktige, gale + 1 , totalTid + gjort.tid, nyttAntall, nyVektetTid)

        ( riktige, gale , totalTid, antall, vektetTid) =
            List.foldl tell ( 0, 0, 0, 0, 0) regnet
    in
        { riktige = riktige 
        , gale = gale 
        , totalTid = totalTid 
        , antall = antall 
        , vektetTid = vektetTid
        , snittTid = totalTid / antall
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
                [ el [ Font.alignRight ] <| text <| toString første
                , el [ Font.center ] <| text <| operator
                , el [ Font.alignRight ] <| text <| toString andre
                ]

        erLik gjort =
            case gjort.resultat of
                Riktig ->
                    el [ Font.center, Background.color Color.green ] <| text "="

                Galt ->
                    el [ Font.center, Background.color Color.red ] <| text "≠"

        visSvar gjort =
            el [ Font.alignRight ] <| text <| toString gjort.svar

        historikk =
            case regnet of
                [] ->
                    empty

                gjort :: _ ->
                    case gjort.resultat of
                        Riktig -> empty
                        Galt ->
                            row
                                (hovedBoksStil
                                    ++ [ padding 5
                                    , spacing 5
                                    ]
                                )
                                ((deler gjort)
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
                    [ el [ padding 5, alignLeft ] <| text <| "✅" ++ (toString stat.riktige)
                    , el [ padding 5, centerX ] <| text <| "⏱" ++ (toString <| round stat.snittTid)
                    , el [ padding 5, alignRight ] <| text <| "❌" ++ (toString stat.gale)
                    ]
    in
        column []
            [ oppsummering
            , historikk
            ]


visOppgave : Oppgave -> Element msg
visOppgave oppgave =
    let
        ( a, op, b ) =
            case oppgave of
                Gange a b ->
                    ( a, "*", b )

                Pluss a b ->
                    ( a, "+", b )

                Minus a b ->
                    ( a, "-", b )

        x =
            toString a

        y =
            toString b

        regneStykke =
            x ++ " " ++ op ++ " " ++ y
    in
        Element.text <| regneStykke ++ " ="
