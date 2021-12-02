"use strict";

exports.saveScrollPush = function(scrollPush){
  return function (identifier){
    return function (){
      scrollState.push = scrollState.push || {}
      scrollState.push[identifier] = scrollPush
    }
  }
}

exports.getScrollPush = function(identifier){
  return function(){
    scrollState.push = scrollState.push || {}
    return scrollState.push[identifier] || function () {return function() {return function() {}}}
    }
  }

  exports.timeOutScroll = function(identifier){
    return function(scrollPush){
      return function (){
        // console.log(scrollState)
        scrollState.timeOut = scrollState.timeOut || {}
        clearTimeout(scrollState.timeOut[identifier])
        scrollState.timeOut[identifier] = setTimeout(scrollPush,200)
      }
    }
  }

exports.getLastTimeStamp = function (identifier){
  return function(){
    scrollState.lastTimeOut = scrollState.lastTimeOut || {}
    return scrollState.lastTimeOut[identifier] || Date.now()
  }
}

exports.setLastTimeStamp = function (identifier){
  return function(){
    scrollState.lastTimeOut = scrollState.lastTimeOut || {}
    scrollState.lastTimeOut[identifier] = Date.now()
  }
}


exports.backPressHandlerImpl = function () {
  return function(e) {
    window.onBackPressed();
  }
}


exports.backPressHandlerImpl = function () {
  return function(e) {
    window.onBackPressed();
  }
}

function setManualEvents(screen) {
  return function(eventName){
    return function(callbackFunction){
      return function () {
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
}

window.setManualEvents = setManualEvents;
exports.setManualEvents = setManualEvents;

exports.fireManualEvent = function (eventName) {
  return function (payload) {
    function isObject(v) {
        return typeof object === "object";
    }

    if (window.__dui_screen && isObject(window[eventName]) && window[eventName][window.__dui_screen]) {
      window[eventName][window.__dui_screen](payload);
    }
  }
};
