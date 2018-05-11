"use strict";

exports.backPressHandlerImpl = function () {
  return function(e) {
    window.onBackPressed();
  }
}