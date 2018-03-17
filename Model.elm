module Model exposing (..)

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
