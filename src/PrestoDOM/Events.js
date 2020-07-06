"use strict";

// exports.dummyEvent = function(sub) {
//   console.log("EVENTYTTTT");
//   sub(1);
// }

// exports.saveCanceler = function(ty, cance) {
//   return function (canceler) {
//     return function () {
//       window.__CANCELER.ty = canceler;
//     }
//   }
// }

exports.backPressHandlerImpl = function () {
  return function(e) {
    window.onBackPressed();
  }
}

function setManualEvents(screen) {
  return function(eventName){
    return function(callbackFunction){
      var screenName = screen.value0 || window.__dui_screen;

      // function was getting cleared when placed outside
      var isDefined = function(val){
        return (typeof val !== "undefined");
      }
      window[eventName] = isDefined(window[eventName]) ? window[eventName] : {};
      if (screenName) {
        window[eventName][screenName] = callbackFunction;
        if ( isDefined(window.__dui_screen) &&
          isDefined(window.__currScreenName) &&
          isDefined(window.__currScreenName.value0) &&
          (window.__dui_screen != window.__currScreenName.value0)
        ) {
          console.warn("window.__currScreenName is varying from window.__currScreenName");
        }
      } else {
        console.error("Please set value to __dui_screen");
      }
    }
  }
}

window.setManualEvents = setManualEvents;
exports.setManualEvents = setManualEvents;

