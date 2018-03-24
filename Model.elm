module Model exposing (..)

-- MODEL


type alias Model =
    { steg : Steg
    }


type Steg
    = SkrivNavn { navn : String }
    | Regne
        { navn : String
        , oppgave : Oppgave
        , regnet : List { oppgave : Oppgave, svar : Tall, resultat : Sjekk }
        , skrevet : String
        }


type Oppgave
    = Gange Tall Tall


type Sjekk
    = Riktig
    | Galt


type alias Tall =
    Int
