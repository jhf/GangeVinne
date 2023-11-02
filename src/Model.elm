module Model exposing (Gjort, Model(..), Msg(..), Oppgave(..), OppgaveType(..), RegneInfo, Sjekk(..), Tall, htmlIdSvar)

import Time exposing (Posix)



-- MODEL


type Model
    = SkrivNavn { navn : String }
    | Regne RegneInfo


type Msg
    = Svar Oppgave String
    | Velg OppgaveType (Maybe Oppgave) (Maybe Posix)
    | Start RegneInfo
    | Skrev String
    | Ingenting
    | Tid Posix
    | Pause


type alias RegneInfo =
    { navn : String
    , oppgave : Oppgave
    , siffer : Int
    , fasit : Int
    , regnet : List Gjort
    , skrevet : String
    , oppgaveType : OppgaveType
    , startTid : Posix
    , stopTid : Posix
    , sekunderVentet : Int
    , pause : Bool
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


htmlIdSvar : String
htmlIdSvar =
    "svar"
