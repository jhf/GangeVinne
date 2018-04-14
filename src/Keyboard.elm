module Keyboard exposing (..)

import Element exposing (Attribute, htmlAttribute)
import Html
import Html.Events exposing (keyCode, onWithOptions)
import Json.Decode as Decode exposing (Decoder)


exclusiveOnKeydown : Decoder msg -> Html.Attribute msg
exclusiveOnKeydown =
    onWithOptions "keydown"
        { preventDefault = True
        , stopPropagation = True
        }


onKeydown : List (Decoder msg) -> Attribute msg
onKeydown =
    onKeydownHtml >> htmlAttribute


onKeydownHtml : List (Decoder msg) -> Html.Attribute msg
onKeydownHtml decoders =
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
        |> exclusiveOnKeydown


onDown : msg -> Decoder msg
onDown msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 40 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onEnter : msg -> Decoder msg
onEnter msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 13 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onEsc : msg -> Decoder msg
onEsc msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 27 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onUp : msg -> Decoder msg
onUp msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 38 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onEnd : msg -> Decoder msg
onEnd msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 35 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onHome : msg -> Decoder msg
onHome msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 36 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onPageUp : msg -> Decoder msg
onPageUp msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 33 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onPageDown : msg -> Decoder msg
onPageDown msg =
    keyCode
        |> Decode.andThen
            (\c ->
                if c == 34 then
                    Decode.succeed msg
                else
                    Decode.fail ""
            )


onTab : msg -> Decoder msg
onTab msg =
    keyCode
        |> Decode.andThen
            (\code ->
                if code == 9 then
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
    keyCode
        |> Decode.andThen
            (\code ->
                if code == 9 then
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
    keyCode
        |> Decode.andThen
            (\code ->
                if code == 38 then
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
    keyCode
        |> Decode.andThen
            (\code ->
                if code == 40 then
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
