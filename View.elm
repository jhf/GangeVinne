module View exposing (..)

import List
import Style exposing (..)
import Style.Color as Sc
import Style.Font as Sf
import Color
import Element as E
import Element.Attributes as Ea
import Element.Events as Ev
import Element.Input as Ei
import Element.Keyed as Ek
import Html exposing (Html)
import Model exposing (..)
import Update exposing (Msg(..))


-- VIEW


view : Model -> Html Msg
view model =
    E.layout stylesheet <|
        E.screen <|
            let
                (Gange a b) =
                    model.oppgave

                x =
                    toString a

                y =
                    toString b
            in
                E.row None
                    [ Ea.width <| Ea.percent 100
                    , Ea.height <| Ea.percent 100
                    , Ea.verticalCenter
                    , Ea.center
                    ]
                    [ let
                        sendSvar =
                            Svar model.oppgave model.skrevet
                      in
                        E.column Oppgave
                            []
                            ([ E.el None [] (E.text "Hei Sunniva!")
                             , E.el None [] (E.text "Svar på oppgaven")
                             , E.row None
                                []
                                [ E.el None [] (E.text (x ++ " * " ++ y ++ " = "))
                                , Ei.text None
                                    [ Ea.id "svar" ]
                                    { label = Ei.hiddenLabel "Svar"
                                    , options =
                                        [ Ei.focusOnLoad
                                        , Ei.textKey <|
                                            toString <|
                                                List.length model.regnet
                                        ]
                                    , value = model.skrevet
                                    , onChange = Skrev
                                    }
                                , E.button None [ Ev.onClick sendSvar ] (E.text "Sjekk svaret!")
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
                                            E.el None [] (E.text resultat)
                                   in
                                    (List.map visRegnet model.regnet)
                            )
                    ]


-- Styling


type Styling
    = None
    | Oppgave


stylesheet : StyleSheet Styling variation
stylesheet =
    Style.styleSheet
        [ Style.style None []
        , Style.style Oppgave
            [ Sc.background Color.darkBlue, Sc.text Color.white ]
        ]







