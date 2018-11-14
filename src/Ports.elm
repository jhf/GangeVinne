port module Ports exposing (storageClear, storageGetItem, storageGetItemReply, storageKey, storageKeyReply, storageRemoveItem, storageSetItem)

import Json.Encode as JE



{-
   Storage.key() // When passed a number n, this method will return the name of the nth key in the storage.
   Storage.getItem() // When passed a key name, will return that key's value.
   Storage.setItem() // When passed a key name and value, will add that key to the storage, or update that key's value if it already exists.
   Storage.removeItem() // When passed a key name, will remove that key from the storage.
   Storage.clear() // When invoked, will empty all keys out of the storage.
-}
-- Elm -> JS


port storageKey : Int -> Cmd msg


port storageGetItem : String -> Cmd msg


port storageSetItem : { key : String, value : JE.Value } -> Cmd msg


port storageRemoveItem : String -> Cmd msg


port storageClear : () -> Cmd msg



-- JS -> Elm


port storageKeyReply : ({ index : Int, key : String } -> msg) -> Sub msg


port storageGetItemReply : ({ key : String, value : JE.Value } -> msg) -> Sub msg
