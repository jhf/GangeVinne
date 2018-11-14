module Keydown exposing (key, matchKey, onBackspace, onCtrlDown, onCtrlUp, onDelete, onDown, onEnd, onEnter, onEsc, onHome, onKeydown, onKeydownHtml, onPageDown, onPageUp, onShiftTab, onSpace, onTab, onUp)

import Element exposing (Attribute, htmlAttribute)
import Html
import Html.Events exposing (preventDefaultOn)
import Json.Decode as Decode exposing (Decoder)


key : Decoder String
key =
    Decode.field "key" Decode.string


matchKey : String -> msg -> Decoder msg
matchKey keyToMatch msg =
    key
        |> Decode.andThen
            (\currentKey ->
                if currentKey == keyToMatch then
                    Decode.succeed msg

                else
                    Decode.fail ""
            )


onKeydown : List (Decoder msg) -> Attribute msg
onKeydown =
    onKeydownHtml >> htmlAttribute


onKeydownHtml : List (Decoder msg) -> Html.Attribute msg
onKeydownHtml decoders =
    -- TODO: Can be replaced by a Decode.oneOf when bug is fixed
    -- https://ellie-app.com/3CDyCN6B5wxa1
    Decode.value
        |> Decode.andThen
            (\val ->
                let
                    matchKeydown ds =
                        case ds of
                            decoder :: tail ->
                                val
                                    |> Decode.decodeValue decoder
                                    |> Result.map Decode.succeed
                                    |> Result.withDefault (matchKeydown tail)

                            [] ->
                                Decode.fail "No match"
                in
                matchKeydown decoders
            )
        >> Decode.map (\msg -> ( msg, True ))
        -- Prevent default is necessary to prevent some browsers from
        -- focusing on the taskbar if an input element at the bottom of the
        -- page is tabbed from.
        >> preventDefaultOn "keydown"


onDown : msg -> Decoder msg
onDown =
    matchKey "ArrowDown"


onEnter : msg -> Decoder msg
onEnter =
    matchKey "Enter"


onEsc : msg -> Decoder msg
onEsc =
    matchKey "Escape"


onUp : msg -> Decoder msg
onUp =
    matchKey "ArrowUp"


onEnd : msg -> Decoder msg
onEnd =
    matchKey "End"


onHome : msg -> Decoder msg
onHome =
    matchKey "Home"


onPageUp : msg -> Decoder msg
onPageUp =
    matchKey "PageUp"


onPageDown : msg -> Decoder msg
onPageDown =
    matchKey "PageDown"


onSpace : msg -> Decoder msg
onSpace =
    matchKey " "


onDelete : msg -> Decoder msg
onDelete =
    matchKey "Delete"


onBackspace : msg -> Decoder msg
onBackspace =
    matchKey "Backspace"


onTab : msg -> Decoder msg
onTab msg =
    key
        |> Decode.andThen
            (\k ->
                if k == "Tab" then
                    Decode.field "shiftKey" Decode.bool

                else
                    Decode.fail ""
            )
        |> Decode.andThen
            (\shift ->
                if shift then
                    Decode.fail ""

                else
                    Decode.succeed msg
            )


onShiftTab : msg -> Decoder msg
onShiftTab msg =
    key
        |> Decode.andThen
            (\k ->
                if k == "Tab" then
                    Decode.field "shiftKey" Decode.bool

                else
                    Decode.fail ""
            )
        |> Decode.andThen
            (\shift ->
                if shift then
                    Decode.succeed msg

                else
                    Decode.fail ""
            )


onCtrlUp : msg -> Decoder msg
onCtrlUp msg =
    key
        |> Decode.andThen
            (\k ->
                if k == "ArrowUp" then
                    Decode.field "ctrlKey" Decode.bool

                else
                    Decode.fail ""
            )
        |> Decode.andThen
            (\ctrl ->
                if ctrl then
                    Decode.succeed msg

                else
                    Decode.fail ""
            )


onCtrlDown : msg -> Decoder msg
onCtrlDown msg =
    key
        |> Decode.andThen
            (\k ->
                if k == "ArrowDown" then
                    Decode.field "ctrlKey" Decode.bool

                else
                    Decode.fail ""
            )
        |> Decode.andThen
            (\ctrl ->
                if ctrl then
                    Decode.succeed msg

                else
                    Decode.fail ""
            )
