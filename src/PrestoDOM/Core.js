"use strict";

// TODO: Have it in PrestoUI
const callbackMapper = require("presto-ui").helpers.android.callbackMapper;

window.callbackMapper = callbackMapper.map;


// TODO: Add the resize event listner in PrestoUI?
function debounce(func, delay) {
  var inDebounce = void 0;
  return function () {
    var context = this;
    var args = arguments;
    clearTimeout(inDebounce);
    inDebounce = setTimeout(function () {
      return func.apply(context, args);
    }, delay);
  };
};

window.addEventListener('resize', debounce(function () {
  console.log("Resize", window.__resizeEvent);
  if (window.__resizeEvent) {
    window.__resizeEvent(window.innerWidth);
  }
}, 300));

window.__PRESTO_ID = window.__ui_id_sequence = typeof Android.getNewID == "function" ? parseInt(Android.getNewID()) * 1000000 : 1;


// TODO: Where this variable being used?
window.__screenSubs = {};


exports.insertDom = PrestoUI.insertDom;


// window.__currScreenName
// window.__dui_last_patch_screen

exports.setRootNode = function(nothing) {
  var root = {type: "relativeLayout", props: {root: "true"}, children: []};

  root.props.height = "match_parent";
  root.props.width = "match_parent";
  var elemRef = PrestoUI.createPrestoElement();
  root.props.id = elemRef.__id;
  root.type = "relativeLayout";
  root.__ref = elemRef;

  // TODO: Debug purpose?
  window.N = root;

  // TODO: Remove this window variable dependency from halogen-vdom
  window.__CANCELER = {};
  // TODO: Android specific shadow. add to inflateView
  window.shadowObject = {};

  window.__ROOTSCREEN = {
    idSet: {
      root: root.props.id,
      child: []
    }
  };

  if(window.__OS == "ANDROID" && typeof Android.getNewID == "function") {
    Android.Render(PrestoUI.domAll(root), null, "false");
  } else {
    Android.Render(PrestoUI.domAll(root), null);
  }

  return root;
}


exports.makeVisible = function (id) {
  // console.log("SCREEN", " makeVisible", id);

  var prop = {
    id: id,
    visibility: "visible"
  }

  var cmd = PrestoUI.getRunInUICmd(prop);
  Android.runInUI(cmd, null);
}




// exports.logMe = function(tag) {
//   return function(a) {
//     console.warn(tag, "!!! : ",a);
//     return a;
//   }
// }

exports.emitter = function(a) {
  a();
  console.log("Logger !!! : ",a);
}


exports.processWidget = function (){
  if(window.widgets) {
    window.widgets.forEach(function (obj) {
      obj.fn(obj.id_)();
    });
    window.widgets = [];
  }
}


exports.makeInvisible = function(id, timeout) {
  // console.log("makeInvisible", id);
  var __visibility = window.__OS == "IOS" ? "invisible" : "gone";
  var prop = {
    id: id,
    visibility: __visibility
  }

  var cmd = PrestoUI.getRunInUICmd(prop);
  Android.runInUI(cmd, null);
}


exports.removeFromDom  = function(idArray, timeout) {
  // console.log("removeFromDom", idArray);
  setTimeout(function() {
    for (var j = 0, k = idArray.length; j < k; j++) {
      var toRemove = idArray[j];
      Android.removeView(toRemove);

      var index = window.__ROOTSCREEN.idSet.child.indexOf(toRemove);
      if (index > -1) {
        window.__ROOTSCREEN.idSet.child.splice(index, 1);
      }
    }
  }, timeout);
}



