"use strict";

exports.dummyEvent = function(sub) {
  console.log("EVENTYTTTT");
  sub(1);
}

exports.saveCanceler = function(ty) {
  return function (canceler) {
    return function () {
      window.__CANCELER.ty = canceler;
    }
  }
}

exports.backPressHandlerImpl = function () {
  return function(e) {
    window.onBackPressed();
  }
}