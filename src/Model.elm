module Model exposing (Gjort, Model, Msg(..), Oppgave(..), OppgaveType(..), RegneInfo, Sjekk(..), Steg(..), Tall)

import Time exposing (Posix)



-- MODEL


type alias Model =
    { steg : Steg
    }


type Msg
    = Svar Oppgave String
    | Velg OppgaveType (Maybe Time.Posix)
    | Skrev String
    | NyOppgave Oppgave
    | Ingenting
    | Tid Posix


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
    , startTid : Posix
    , venteTid : Posix
    }


type alias Gjort =
    { oppgave : Oppgave, svar : Tall, resultat : Sjekk, tid : Int }


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
