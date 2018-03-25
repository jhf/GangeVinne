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
import Html.Attributes exposing (id, autocomplete)
import Model exposing (..)
import Update exposing (Msg(..))
import Keyboard


-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        Element.row
            [ Element.centerX
            , Element.centerY
            , Element.width <| Element.shrink
            ]
            [ case model.steg of
                SkrivNavn { navn } ->
                    viewSkrivNavn navn

                Regne info ->
                    viewRegne info
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


viewRegne : RegneInfo -> Element Msg
viewRegne info =
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
                        , Input.focusedOnLoad
                        , Keyboard.onKeydown [ Keyboard.onEnter sendSvar ]
                        , htmlAttribute <| autocomplete False
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
            , viewRegnet info.regnet
            ]


viewRegnet : List Gjort -> Element Msg
viewRegnet regnet =
    let
        visRegnet gjort =
            let
                svar : Element msg
                svar =
                    let
                        tall =
                            toString gjort.svar
                    in
                        case gjort.resultat of
                            Riktig ->
                                Element.el
                                    [ Background.color Color.lightGreen ]
                                    (Element.text tall)

                            Galt ->
                                Element.el
                                    [ Background.color Color.lightRed ]
                                    (Element.text tall)
            in
                Element.row [] [ visOppgave gjort.oppgave, svar ]
    in
        Element.column [] <| List.map visRegnet regnet


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
