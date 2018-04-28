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
    , siffer : Int
    , regnet : List Gjort
    , skrevet : String
    , oppgaveType : OppgaveType
    }


type alias Gjort =
    { oppgave : Oppgave, svar : Tall, resultat : Sjekk }


type Oppgave
    = Gange Tall Tall
    | Pluss Tall Tall
    | Minus Tall Tall


type Sjekk
    = Riktig
    | Galt


type alias Tall =
    Int


type OppgaveType
    = Ganging
    | PlussOgMinus
