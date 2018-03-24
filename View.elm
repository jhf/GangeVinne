module View exposing (..)

import List
import Color
import Element exposing (Element, htmlAttribute)
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
        oppgaveUtseende
        [ Element.el [] (Element.text "Velkommen til GangeVinne!")
        , Element.el [] (Element.text "Hva heter du?")
        , Element.row []
            [ Input.text
                [ htmlAttribute <| id "navn"
                , Input.focusedOnLoad
                , Keyboard.onKeydown [ Keyboard.onEnter Navn ]
                , htmlAttribute <| autocomplete False
                ]
                { label = Input.labelLeft [] <| Element.text "Ditt navn:"
                , text = navn
                , onChange = Just Skrev
                , placeholder = Nothing
                }
            , Input.button [ Events.onClick Navn ]
                { onPress = Just Navn
                , label = Element.text "Neste"
                }
            ]
        ]


viewRegne : RegneInfo -> Element Msg
viewRegne info =
    let
        sendSvar =
            Svar info.oppgave info.skrevet
    in
        Element.row []
            [ Element.column
                oppgaveUtseende
                [ Element.el [] (Element.text <| "Hei " ++ info.navn)
                , Element.el [] (Element.text "Svar på oppgaven")
                , Element.row
                    []
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
                    , Input.button [ Events.onClick sendSvar ]
                        { onPress = Just sendSvar
                        , label = Element.text "Sjekk svaret!"
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
visOppgave (Gange a b) =
    let
        x =
            toString a

        y =
            toString b
    in
        Element.text (x ++ " * " ++ y ++ " = ")



-- Styling


oppgaveUtseende : List (Element.Attr decorative msg)
oppgaveUtseende =
    [ Background.color Color.lightBlue ]
