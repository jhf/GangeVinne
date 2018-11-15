'use strict'

const { Elm } = require('./Main')
var app = Elm.Main.init({})

/*
Storage.key() // When passed a number n, this method will return the name of the nth key in the storage.
Storage.getItem() // When passed a key name, will return that key's value.
Storage.setItem() // When passed a key name and value, will add that key to the storage, or update that key's value if it already exists.
Storage.removeItem() // When passed a key name, will remove that key from the storage.
Storage.clear() // When invoked, will empty all keys out of the storage.
*/

/* eslint-env browser */

if (app.ports.storageKey !== undefined) {
  app.ports.storageKey.subscribe(function (index) {
    var key = localStorage.key(index)
    app.ports.storageKeyReply.send({ index: index, key: key })
  })
};

if (app.ports.storageGetItem !== undefined) {
  app.ports.storageGetItem.subscribe(function (key) {
    var value = localStorage.getItem(key)
    app.ports.storageGetItemReply.send({ key: key, value: value })
  })
};

if (app.ports.storageSetItem !== undefined) {
  app.ports.storageSetItem.subscribe(function (args) {
    localStorage.setItem(args.key, args.value)
  })
};

if (app.ports.storageRemoveItem !== undefined) {
  app.ports.storageRemoveItem.subscribe(function (key) {
    localStorage.removeItem(key)
  })
};

if (app.ports.storageClear !== undefined) {
  app.ports.storageClear.subscribe(function () {
    localStorage.clear()
  })
};
