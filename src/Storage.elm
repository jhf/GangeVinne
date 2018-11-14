module Storage exposing (loadName, readName, storageKeys, storeName)

import Json.Decode as JD
import Json.Encode as JE
import Model exposing (..)
import Ports exposing (storageGetItem, storageGetItemReply, storageSetItem)


storageKeys =
    { name = "name" }


loadName : Cmd msg
loadName =
    storageGetItem storageKeys.name


storeName : String -> Cmd msg
storeName name =
    storageSetItem { key = storageKeys.name, value = JE.string name }


readName : Sub Msg
readName =
    let
        handler { key, value } =
            if key == storageKeys.name then
                case JD.decodeValue JD.string value of
                    Ok name ->
                        Skrev name

                    Err msg ->
                        Ingenting

            else
                Ingenting
    in
    storageGetItemReply handler
