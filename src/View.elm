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
import Html.Attributes exposing (id, autocomplete, type_)
import Model exposing (..)
import Update exposing (Msg(..))
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
    in
        Element.row
            [ Element.spacing 10 ]
            [ Element.column
                hovedBoksStil
                [ Element.el [] (Element.text <| "Hei " ++ info.navn)
                , Element.el [] (Element.text "Svar på oppgaven")
                , Element.row
                    [ spacing 10 ]
                    [ Element.el [] <| visOppgave info.oppgave
                    , Input.text
                        [ htmlAttribute <| id "svar"
                        , htmlAttribute <| type_ "number"
                        , Input.focusedOnLoad
                        , Keyboard.onKeydown [ Keyboard.onEnter sendSvar ]
                        , htmlAttribute <| autocomplete False
                        , width <| px 50
                        ]
                        { label = Input.labelLeft [] Element.empty
                        , text = info.skrevet
                        , onChange = Just Skrev
                        , placeholder = Nothing
                        }
                    , Input.button
                        (knappeStil ++ [ Events.onClick sendSvar ])
                        { onPress = Just sendSvar
                        , label = Element.text "Sjekk!"
                        }
                    ]
                ]
            , visRegnet info.regnet
            ]


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
                tell gjort ( riktige, gale ) =
                    case gjort.resultat of
                        Riktig ->
                            ( riktige + 1, gale )

                        Galt ->
                            ( riktige, gale + 1 )

                ( riktige, gale ) =
                    List.foldl tell ( 0, 0 ) regnet
            in
                row [ padding 5, spacing 10, width fill, centerX ]
                    [ el [ padding 5, Border.color Color.green, Border.width 5 ] <| text <| toString riktige
                    , el [ padding 5, Border.color Color.red, Border.width 5 ] <| text <| toString gale
                    ]
    in
        column [] [ oppsummering, historikk ]


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
