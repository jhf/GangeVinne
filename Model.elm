module Model exposing (..)

-- MODEL


type alias Model =
    { steg : Steg
    }


type Steg
    = SkrivNavn { navn : String }
    | Regne RegneInfo


type alias RegneInfo =
    { navn : String
    , oppgave : Oppgave
    , regnet : List Gjort
    , skrevet : String
    }


type alias Gjort =
    { oppgave : Oppgave, svar : Tall, resultat : Sjekk }


type Oppgave
    = Gange Tall Tall


type Sjekk
    = Riktig
    | Galt


type alias Tall =
    Int
