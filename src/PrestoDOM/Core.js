"use strict";

const prestoDayum = require("presto-ui").doms;
const webParseParams = require("presto-ui").helpers.web.parseParams;
const iOSParseParams = require("presto-ui").helpers.ios.parseParams;
const parseParams = require("presto-ui").helpers.android.parseParams;
const R = require("ramda");

const callbackMapper = require("presto-ui").helpers.android.callbackMapper;

window.callbackMapper = callbackMapper.map;


exports.storeMachine = function(machine) {
  return function(screen) {
    return function() {
      window.MACHINE = machine;
      if (screen.value0)
        window.MACHINE_MAP[screen.value0] = machine;
    }
  }
}

exports.getLatestMachine = function(screen) {
  return function() {
    if (screen.value0)
      return window.MACHINE_MAP[screen.value0];
    return window.MACHINE;
  }
}


exports.insertDom = insertDom;

window.__PRESTO_ID = window.__ui_id_sequence = typeof Android.getNewID == "function" ? parseInt(Android.getNewID()) * 1000000 : 1;

function domAll(elem) {
  if (!elem.__ref) {
    elem.__ref = window.createPrestoElement();
  }

  if (elem.props.id) {
    elem.__ref.__id = parseInt(elem.props.id, 10) || elem.__ref.__id;
  }

  const type = R.clone(elem.type);
  const props = R.clone(elem.props);
  const children = [];

  for (var i = 0; i < elem.children.length; i++) {
    children.push(domAll(elem.children[i]));
  }

  if (type == "viewPager" && window.__OS === "ANDROID") {
    const pages = children.splice(0);
    const id  = elem.__ref.__id;
    props.afterRender = function () {
      var cardWidth = 0.8;
      var plusButtonWidth = 0.2;
      if (pages.length == 1) {
        plusButtonWidth = 0.8;
      }
      JBridge.viewPagerAdapter(id, JSON.stringify(pages), cardWidth, plusButtonWidth);
    }
  }

  props.id = elem.__ref.__id;
  if(elem.parentType && window.__OS == "ANDROID")
    return prestoDayum({elemType: type, parentType: elem.parentType}, props, children);

  return prestoDayum(type, props, children);
}

function cmdForAndroid(config, set, type) {
  if (set) {
    if (config.id)
    {
      var cmd = parseParams(type, config, "set").runInUI.replace("this->setId", "set_view=ctx->findViewById").replace(/this->/g, "get_view->");
      cmd = cmd.replace(/PARAM_CTR_HOLDER[^;]*/g, "get_view->getLayoutParams;");
    }
    return cmd;
  }

  var cmd = "set_view=ctx->findViewById:i_" + config.id + ";";
  var runInUI;
  delete config.id;
  config.root = "true";
  runInUI = parseParams(type, config, "get").runInUI;
  cmd += runInUI + ';';
  return cmd;
}

function applyProp(element, attribute, set) {
  var prop = {
    id: element.__ref.__id
  }
  prop[attribute.value0] = attribute.value1;
  if (window.__OS == "ANDROID") {
    var cmd = cmdForAndroid(prop, set, element.type);
    Android.runInUI(cmd, null);
  } else if (window.__OS == "IOS"){
    Android.runInUI(prop);
  } else {
    Android.runInUI(webParseParams("linearLayout", prop, "set"));
  }
  // Android.runInUI(parseParams("linearLayout", prop, "set"));
}

function replaceView(element, attribute, removeProp) {
  // console.log("REPLACE VIEW", element.__ref.__id, element.props);
  const props = R.clone(element.props);
  props.id = element.__ref.__id;
  var rep;
  const viewGroups = ["linearLayout", "relativeLayout", "scrollView", "frameLayout", "horizontalScrollView"];

  if (viewGroups.indexOf(element.type) != -1){
    props.root = true;
    rep = prestoDayum(element.type, props, []);
  } else if (window.__OS == "ANDROID") {
    rep = prestoDayum({elemType: element.type, parentType: element.parentNode.type}, props, []);
  } else {
    rep = prestoDayum(element.type, props, []);
  }
  if(window.__OS == "ANDROID"){
    Android.replaceView(JSON.stringify(rep), element.__ref.__id);
  } else {
    Android.replaceView(rep, element.__ref.__id);
  }
}



window.removeChild = removeChild;
window.addChild = addChild;
window.replaceView = replaceView;
window.addProperty = addAttribute;
// window.removeAttribute = removeAttribute;
window.updateProperty = updateAttribute;
window.addAttribute = addAttribute;
window.insertDom = insertDom;
window.createPrestoElement = function () {
    if(typeof(window.__ui_id_sequence) != "undefined" && window.__ui_id_sequence != null) {
        return { __id : window.__ui_id_sequence++ };
    } else {
        window.__ui_id_sequence = typeof Android.getNewID == "function" ? parseInt(Android.getNewID()) * 1000000 : window.__PRESTO_ID ;
        return { __id : window.__ui_id_sequence++ };
    }
};

window.__screenSubs = {};

function removeChild(child, parent, index) {
  // console.log("Remove child :", child.type);
  Android.removeView(child.__ref.__id);
}

function addChild(child, parent, index) {
  if(child.type == null) {
    console.warn("child null");
  }
  // console.log("Add child :", child.__ref.__id, child.type);
  const viewGroups = ["linearLayout", "relativeLayout", "scrollView", "frameLayout", "horizontalScrollView"];
  if (window.__OS == "ANDROID") {
    if (viewGroups.indexOf(child.type) != -1){
      child.props.root = true;
    } else {
      child.parentType = parent.type;
    }
    Android.addViewToParent(parent.__ref.__id, JSON.stringify(domAll(child)), index, null, null);
  }
  else
    Android.addViewToParent(parent.__ref.__id, domAll(child), index, null, null);
}

function addAttribute(element, attribute) {
  // console.log("add attr :", attribute);
  element.props[attribute.value0] = attribute.value1;
  applyProp(element, attribute, true);
}

function removeAttribute(element, attribute) {
  // console.log("remove attr :", attribute);
    replaceView(element, attribute, true);
}

function updateAttribute(element, attribute) {
  // console.log("update attr :", attribute);
  element.props[attribute.value0] = attribute.value1;

  applyProp(element, attribute, false);
}


exports.setRootNode = function(nothing) {
  return function () {
    var root = {type: "relativeLayout", props: {root: "true"}, children: []};

    root.props.height = "match_parent";
    root.props.width = "match_parent";
    root.props.id = window.createPrestoElement();
    root.type = "relativeLayout";
    root.__ref = window.createPrestoElement();

    window.N = root;
    window.__CACHELIMIT = 50;
    window.__psNothing = nothing;
    window.MACHINE_MAP = {};
    window.shadowObject = {};
    window.__stashScreen = [];
    window.__CACHED_SCREEN = [];
    window.__lastCachedScreen = {};
    // Screen nothing is used for stashing the screens without namespace.
    window.__screenNothing = true;
    window.__prevScreenName = nothing;
    window.__currScreenName = nothing;
    window.__ROOTSCREEN = {
      idSet: {
        root: root.props.id,
        child: []
      }
    };

    if(window.__OS == "ANDROID"){
      if(typeof Android.getNewID == "function") {
        Android.Render(JSON.stringify(domAll(root)), null, "false");
      } else {
        Android.Render(JSON.stringify(domAll(root)), null);
      }
    } else if (window.__OS == "WEB"){
      Android.Render(domAll(root), null);
    } else {
      Android.Render(domAll(root), null);
    }

    return root;

  }

}

exports.getRootNode = function() {
  return window.N;
}

function clearStash () {
  var screen = window.__stashScreen;
  var len = screen.length;

  setTimeout(function() {
    for (var i = 0; i < len; i++) {
      Android.removeView(screen[i]);
    }
  }, 1000);
  window.__stashScreen = [];
}

function makeVisible (cache, _id) {
  if (cache) {
    var prop = {
        id: _id,
        visibility: "visible"
    }
  } else {
    var length =  window.__ROOTSCREEN.idSet.child.length;
    var prop = {
        id: window.__ROOTSCREEN.idSet.child[length - 1].id,
        visibility: "visible"
    }
  }
  if (window.__OS == "ANDROID") {
    var cmd = cmdForAndroid(prop, true, "linearLayout");
    Android.runInUI(cmd, null);
  } else if (window.__OS == "IOS"){
    Android.runInUI(prop);
  } else {
    Android.runInUI(webParseParams("relativeLayout", prop, "set"));
  }
}

function screenIsInStack(screen) {
  var ar = window.__ROOTSCREEN.idSet.child;
  for (var i = 0,l=ar.length; i < l; i++) {
    if (ar[i].name.value0 == screen.value0) {
      var rem = window.__ROOTSCREEN.idSet.child.splice(i+1);
      if (rem.length || i != l-1) {
        if (i == 0)
          window.__prevScreenName = window.__psNothing;
        else
          window.__prevScreenName = window.__ROOTSCREEN.idSet.child[i-1].name;
        window.__currScreenName = screen;

        setTimeout(function() {
          for (var j = 0,k=rem.length; j < k; j++) {
            Android.removeView(rem[j].id);
            delete window.MACHINE_MAP[rem[j].name.value0];
          }
        }, 1000);

        makeVisible(false);
      }
      return true;
    }
  }

  return false;

}

exports.saveScreenNameImpl = function(screen) {
  return function() {

    clearStash();

    if (screen == window.__psNothing) {
      window.__screenNothing = true;
      return false;
    } else {
      window.__screenNothing = false;

      var cond = screenIsInStack(screen)

      if (cond) {
        hideCachedScreen();
        return true;
      } else {
        window.__prevScreenName = window.__currScreenName;
        window.__currScreenName = screen;

        return false;
      }
    }
  }
}

function screenIsCached(screen) {
  var ar = window.__CACHED_SCREEN;
  for (var i = 0,l=ar.length; i < l; i++) {
    if (ar[i].name.value0 == screen.value0) {
      makeVisible(true, ar[i].id);
      if (window.__lastCachedScreen.name && window.__lastCachedScreen.name != ""  ){
        var prop = {
          id: window.__lastCachedScreen.id,
          visibility: "gone"
        }
        if (window.__OS == "ANDROID") {
          var cmd = cmdForAndroid(prop, true, "relativeLayout");
          Android.runInUI(cmd, null);
        } else if (window.__OS == "IOS"){
          Android.runInUI(prop);
        } else {
          Android.runInUI(webParseParams("relativeLayout", prop, "set"));
        }
    
      }

      window.__lastCachedScreen.id = ar[i].id;
      window.__lastCachedScreen.flag = true;
      return true;
    }
  }

  return false;

}


exports.cacheScreenImpl = function(screen) {
  return function() {

    clearStash();

    if (screen == window.__psNothing) {
      window.__screenNothing = true;
      return false;
    } else {
      window.__screenNothing = false;

      var cond = screenIsCached(screen)

      window.__lastCachedScreen.name = screen;

      return cond;
      // if (cond) {
      //   return true;
      // } else {

      //   return false;
      // }
    }
  }
}



// exports.getPrevScreen = function() {
//     if (window.__screenNothing) {
//       window.__screenNothing = false;
//       return window.__psNothing;
//     }
//     return window.__prevScreenName;
// }

// exports.logMe = function(tag) {
//   return function(a) {
//     console.warn(tag, "!!! : ",a);
//     return a;
//   }
// }

exports.emitter = function(a) {
    return function() {
      a();
      console.log("Logger !!! : ",a);
    }
}

function hideCachedScreen() {
  if (window.__lastCachedScreen.flag) {
    window.__lastCachedScreen.flag = false;
    var prop = {
        id: window.__lastCachedScreen.id,
        visibility: "gone"
    }

    window.__lastCachedScreen.name = "";

    if (window.__OS == "ANDROID") {
      var cmd = cmdForAndroid(prop, true, "relativeLayout");
      Android.runInUI(cmd, null);
    } else if (window.__OS == "IOS") {
      Android.runInUI(prop);
    } else {
      Android.runInUI(webParseParams("relativeLayout", prop, "set"));
    }

  }
}

function insertDom(root) {
  return function (dom) {
    return function () {
      root.children.push(dom);
      dom.parentNode = root;
      dom.__ref = window.createPrestoElement();
      window.N = root;

      var rootId = window.__ROOTSCREEN.idSet.root;

      dom.props.root = true;
      if (window.__screenNothing) {
        window.__stashScreen.push(dom.__ref.__id);
        window.__screenNothing = false;
      }
      else {
        var screenName = window.__currScreenName;

        var length = window.__ROOTSCREEN.idSet.child.push({id: dom.__ref.__id, name: screenName});
        if (length >= window.__CACHELIMIT) {
          window.__ROOTSCREEN.idSet.child.shift();
          length -= 1;
        }

        if (length >= 2) {
          var prop = {
              id: window.__ROOTSCREEN.idSet.child[length - 2].id,
              visibility: "gone"
          }

          setTimeout(function() {
            if (window.__OS == "ANDROID" && length > 1) {
              var cmd = cmdForAndroid(prop, true, "relativeLayout");
              Android.runInUI(cmd, null);
            } else if (window.__OS == "IOS"  && length > 1){
              Android.runInUI(prop);
            } else if (length > 1) {
              Android.runInUI(webParseParams("relativeLayout", prop, "set"));
            }
          }, 1000);

        }
      }

      if (window.__OS == "ANDROID") {
        var callback = window.callbackMapper(executePostProcess);
        Android.addViewToParent(rootId, JSON.stringify(domAll(dom)), length - 1, callback, null);
      }
      else {
        Android.addViewToParent(rootId, domAll(dom), length - 1, null, null);
      }

      hideCachedScreen();

    }
  }
}

exports.updateDom = function (root) {
  return function (dom) {
    return function () {
      root.children.push(dom);
      dom.parentNode = root;
      dom.__ref = window.createPrestoElement();
      window.N = root;

      var rootId = window.__ROOTSCREEN.idSet.root;

      var length = window.__ROOTSCREEN.idSet.child;
      dom.props.root = true;
      if (window.__screenNothing) {
        window.__stashScreen.push(dom.__ref.__id);
        window.__screenNothing = false;
      }
      else {
        if (window.__lastCachedScreen.name && window.__lastCachedScreen.name != ""  ){
          var prop = {
            id: window.__lastCachedScreen.id,
            visibility: "gone"
          }
          if (window.__OS == "ANDROID") {
            var cmd = cmdForAndroid(prop, true, "relativeLayout");
            Android.runInUI(cmd, null);
          } else if (window.__OS == "IOS"){
            Android.runInUI(prop);
          } else {
            Android.runInUI(webParseParams("relativeLayout", prop, "set"));
          }
      
        }
        window.__lastCachedScreen.id = dom.__ref.__id;
        window.__lastCachedScreen.flag = true;
        var screenName = window.__lastCachedScreen.name;


        window.__CACHED_SCREEN.push({id: dom.__ref.__id, name: screenName});
      }

      if (window.__OS == "ANDROID") {
        var callback = window.callbackMapper(executePostProcess);
        Android.addViewToParent(rootId, JSON.stringify(domAll(dom)), length, callback, null);
      }
      else {
        Android.addViewToParent(rootId, domAll(dom), length, null, null);
      }

    }
  }
}

var executePostProcess = function () {
  for (var tag in window.shadowObject) {
    JBridge.setShadow(window.shadowObject[tag]["level"],
                      JSON.stringify(window.shadowObject[tag]["viewId"]),
                      JSON.stringify(window.shadowObject[tag]["backgroundColor"]),
                      JSON.stringify(window.shadowObject[tag]["blurValue"]),
                      JSON.stringify(window.shadowObject[tag]["shadowColor"]),
                      JSON.stringify(window.shadowObject[tag]["dx"]),
                      JSON.stringify(window.shadowObject[tag]["dy"]),
                      JSON.stringify(window.shadowObject[tag]["spread"]),
                      JSON.stringify(window.shadowObject[tag]["factor"]));
  }
}
