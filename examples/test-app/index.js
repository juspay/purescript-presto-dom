/*
* Copyright (c) 2012-2017 "JUSPAY Technologies"
* JUSPAY Technologies Pvt. Ltd. [https://www.juspay.in]
*
* This file is part of JUSPAY Platform.
*
* JUSPAY Platform is free software: you can redistribute it and/or modify
* it for only educational purposes under the terms of the GNU Affero General
* Public License (GNU AGPL) as published by the Free Software Foundation,
* either version 3 of the License, or (at your option) any later version.
* For Enterprise/Commerical licenses, contact <info@juspay.in>.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  The end user will
* be liable for all damages without limitation, which is caused by the
* ABUSE of the LICENSED SOFTWARE and shall INDEMNIFY JUSPAY for such
* damages, claims, cost, including reasonable attorney fee claimed on Juspay.
* The end user has NO right to claim any indemnification based on its use
* of Licensed Software. See the GNU Affero General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with this program. If not, see <https://www.gnu.org/licenses/agpl.html>.
*/

window.hyper_session_id = guid();
window.hyper_pay_version = "1.0rc5_13";
function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
          s4() + '-' + s4() + s4() + s4();
}

window.moveChild = function(view, baap, idx) {
  Android.moveView(view.__ref.__id, idx)
}

// const purescript = require("./src/Main.purs");

// const purescript = require("./output/Main");
window.onBackPressedEvent = () => { if(typeof window.onBackPressedEvent === "function") { window.onBackPressedEvent() } };

window.isObject = function(object){
  return (typeof object == "object");
}
window.manualEventsName = ["onBackPressedEvent","onNetworkChange"];

var isUndefined = function(val){
  return (typeof val == "undefined");
}

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

window["onEvent'"] = function(fnName,args,callback) {
    console.log("----------------\n\n\n\n\n",fnName)
    if(fnName == "onBackPressed") {
      if(typeof window.onBackPressed === "function") { window.onBackPressed() };
      if(window.__dui_screen && window.isObject(window.onBackPressedEvent) && window.onBackPressedEvent[window.__dui_screen]) {
        window.onBackPressedEvent[window.__dui_screen]();
      }
    } else if(fnName == "onNetworkChange") {
      if(window.__dui_screen && window.isObject(window.onNetworkChange) && window.onNetworkChange[window.__dui_screen]) {
        window.onNetworkChange[window.__dui_screen]()
      }
    } else if (fnName == "onResume" && JBridge.requestKeyboardHide) {
      setTimeout(() => {
        JBridge.requestKeyboardHide();
      }, 150);
    }
}

window.onBundleUpdate = function() {}


window.DUIGatekeeper = {
  getSessionInfo: function getSessionInfo() {
    return JSON.stringify({});
  }

}

// if(__OS == "ANDROID") {
  // require("./dist/src.js");
var purescript = require("./output/Main");
purescript.main()
// } else {
//   var purescript = require("./output/Main");
//   purescript.main()
// }
if(typeof window.JOS != "undefined") {
  window.JOS.addEventListener("onEvent'")();
  top.__PROXY_FN = window.__PROXY_FN;
} else {
  console.error("JOS not present")
}

