module Main exposing (..)

import List
import String exposing (toInt)
import Maybe
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
import Random
import Dom
import Task


-- MODEL


type alias Model =
    { oppgave : Oppgave
    , regnet : List ( Oppgave, Tall, Sjekk )
    , skrevet : String
    }


type Oppgave
    = Gange Tall Tall


type Sjekk
    = Riktig
    | Galt


type alias Tall =
    Int


init : ( Model, Cmd Msg )
init =
    ( { oppgave = Gange 0 0
      , regnet = []
      , skrevet = ""
      }
    , lagTilfeldigOppgave
    )


subscriptions : a -> Sub Msg
subscriptions model =
    Sub.none



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



-- UPDATE


type Msg
    = Svar Oppgave String
    | Skrev String
    | NyOppgave Oppgave
    | Ingenting


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ingenting -> (model, Cmd.none)
        NyOppgave oppgave ->
            ( { model | oppgave = oppgave }, Cmd.none )

        Skrev noe ->
            ( { model | skrevet = noe }, Cmd.none )

        Svar ((Gange a b) as oppgave) skrevet ->
            case toInt skrevet of
                Err _ ->
                    ( model, Cmd.none )

                Ok svar ->
                    let
                        resultat =
                            if svar == a * b then
                                Riktig
                            else
                                Galt

                        gjort =
                            ( oppgave, svar, resultat )

                        nyModel =
                            { model
                                | regnet = gjort :: model.regnet
                                , skrevet = ""
                            }
                    in
                        ( nyModel, Cmd.batch [lagTilfeldigOppgave,hoppTilSkriving] )



-- VIEW


view : Model -> Html Msg
view model =
    E.layout stylesheet <|
        let
            (Gange a b) =
                model.oppgave

            x =
                toString a

            y =
                toString b
        in
            E.column None
                [ Ea.width Ea.fill
                , Ea.height Ea.fill
                ]
                [ E.row None
                    [ Ea.verticalCenter
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
                                    [Ea.id "svar"]
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
                ]


hoppTilSkriving : Cmd Msg
hoppTilSkriving =
    Dom.focus "svar"
    |> Task.attempt (\_ -> Ingenting)


lagTilfeldigOppgave : Cmd Msg
lagTilfeldigOppgave =
    let
        lagOppgave ( a, b ) =
            NyOppgave <| Gange a b
    in
        Random.generate lagOppgave randomPoint


randomPoint : Random.Generator ( Int, Int )
randomPoint =
    Random.pair (Random.int 0 10) (Random.int 0 10)
