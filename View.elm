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
                SkrivNavn {navn} ->
                    viewSkrivNavn navn

                Regne info ->
                    viewRegne info
            ]



viewSkrivNavn : String  -> Element Msg
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


viewRegne info =
    let
        (Gange a b) =
            info.oppgave

        x =
            toString a

        y =
            toString b
    in
        let
            sendSvar =
                Svar info.oppgave info.skrevet

            oppgave =
                Element.text (x ++ " * " ++ y ++ " = ")
        in
            Element.column
                oppgaveUtseende
                ([ Element.el [] (Element.text <| "Hei " ++ info.navn)
                 , Element.el [] (Element.text "Svar på oppgaven")
                 , Element.row
                    []
                    [ Element.el [] oppgave
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
                    ++ let
                        visRegnet {resultat} =
                            let
                                beskjed =
                                    case resultat of
                                        Riktig ->
                                            "Riktig :-)"

                                        Galt ->
                                            "Galt :-("
                            in
                                Element.el [] (Element.text beskjed)
                       in
                        (List.map visRegnet info.regnet)
                )



-- Styling


oppgaveUtseende : List (Element.Attr decorative msg)
oppgaveUtseende =
    [ Background.color Color.lightBlue ]
