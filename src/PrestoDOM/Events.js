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

var isUndefined = function(val){
  return (typeof val == "undefined");
}

window.manualEventsName = ["onBackPressedEvent","onNetworkChange"];

function setManualEvents(eventName,callbackFunction){
  window[eventName] = (!isUndefined(window[eventName])) ? window[eventName] : {};
  if(!isUndefined(window.__dui_screen)){
    window[eventName][window.__dui_screen] = callbackFunction;
    if((!isUndefined(window.__currScreenName.value0)) && (window.__dui_screen != window.__currScreenName.value0)){
      console.warn("window.__currScreenName is varying from window.__currScreenName");
    }
  } else {
    console.error("Please set value to __dui_screen");
  }
}

window.setManualEvents = setManualEvents;