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
    let
        (Gange a b) =
            model.oppgave

        x =
            toString a

        y =
            toString b
    in
        Element.layout [] <|
            Element.row
                [ Element.centerX
                , Element.centerY
                , Element.width <| Element.shrink
                ]
                [ let
                    sendSvar =
                        Svar model.oppgave model.skrevet

                    oppgave =
                        Element.text (x ++ " * " ++ y ++ " = ")
                  in
                    Element.column
                        oppgaveUtseende
                        ([ Element.el [] (Element.text "Hei Sunniva!")
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
                                , text = model.skrevet
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
                                visRegnet ( Gange a b, svar, sjekk ) =
                                    let
                                        resultat =
                                            case sjekk of
                                                Riktig ->
                                                    "Riktig :-)"

                                                Galt ->
                                                    "Galt :-("
                                    in
                                        Element.el [] (Element.text resultat)
                               in
                                (List.map visRegnet model.regnet)
                        )
                ]



-- Styling


oppgaveUtseende : List (Element.Attr decorative msg)
oppgaveUtseende =
    [ Background.color Color.lightBlue ]
