"use strict";

const prestoDayum = require("presto-ui").doms;
const webParseParams = require("presto-ui").helpers.web.parseParams;
const iOSParseParams = require("presto-ui").helpers.ios.parseParams;
const parseParams = require("presto-ui").helpers.android.parseParams;
const R = require("ramda");

const callbackMapper = require("presto-ui").helpers.android.callbackMapper;

window.callbackMapper = callbackMapper.map;

exports.getScreenNumber = function() {
  if (window.scc) {
    window.scc += 1;
    return window.scc;
  }
  window.scc = 1;
  return 1;
};

exports.cacheCanceller = function(screenNumber) {
  return function(canceller) {
    return function() {
      window["currentCancellor" + screenNumber] = canceller;
    };
  };
};

exports.callAnimation = callAnimation;

exports.setScreenImpl = function(screen) {
  if (window.__dui_screen && window.__dui_screen != screen) {
    window.__dui_old_screen = window.__dui_screen;
  }
  window.__dui_screen = screen;
  if (typeof window.pageId == "undefined") {
    window.pageid = -1;
  }
  ++window.pageId;
};

function debounce(func, delay) {
  var inDebounce = void 0;
  return function() {
    var context = this;
    var args = arguments;
    clearTimeout(inDebounce);
    inDebounce = setTimeout(function() {
      return func.apply(context, args);
    }, delay);
  };
}

window.addEventListener(
  "resize",
  debounce(function() {
    console.log("Resize", window.__resizeEvent);
    if (window.__resizeEvent) {
      window.__resizeEvent(window.innerWidth);
    }
  }, 300)
);

exports.storeMachine = function(machine, screen) {
  window.MACHINE = machine;
  if (screen.value0) window.MACHINE_MAP[screen.value0] = machine;
  window.__dui_last_patch_screen = screen.value0;
};

exports.getLatestMachine = function(screen) {
  if (screen.value0) {
    return window.MACHINE_MAP[screen.value0];
  }
  return window.MACHINE;
};

exports.insertDom = insertDom;

window.__PRESTO_ID = window.__ui_id_sequence =
  typeof Android.getNewID == "function"
    ? parseInt(Android.getNewID()) * 1000000
    : 1;

exports._domAll = domAll;

function domAll(elem) {
  /*
  if (!elem.__ref) {
    elem.__ref = window.createPrestoElement();
  }

  if (elem.props.id) {
    elem.__ref.__id = parseInt(elem.props.id, 10) || elem.__ref.__id;
  }
  */

  if (elem.props.hasOwnProperty('id') && elem.props.id != '' && (elem.props.id).toString().trim() != '') {
    elem.__ref = {__id: (elem.props.id).toString().trim()}
  } else if(!elem.__ref) {
    elem.__ref = window.createPrestoElement()
  }

  window.entryAnimation = window.entryAnimation || {};
  window.entryAnimation[window.__dui_screen] =
    window.entryAnimation[window.__dui_screen] || {};

  window.entryAnimationF = window.entryAnimationF || {};
  window.entryAnimationF[window.__dui_screen] =
    window.entryAnimationF[window.__dui_screen] || {};

  window.entryAnimationB = window.entryAnimationB || {};
  window.entryAnimationB[window.__dui_screen] =
    window.entryAnimationB[window.__dui_screen] || {};

  window.exitAnimation = window.exitAnimation || {};
  window.exitAnimation[window.__dui_screen] =
    window.exitAnimation[window.__dui_screen] || {};

  window.exitAnimationF = window.exitAnimation || {};
  window.exitAnimationF[window.__dui_screen] =
    window.exitAnimationF[window.__dui_screen] || {};

  window.exitAnimationB = window.exitAnimationB || {};
  window.exitAnimationB[window.__dui_screen] =
    window.exitAnimationB[window.__dui_screen] || {};

  const type = R.clone(elem.type);
  const props = R.clone(elem.props);

  if (window.__OS !== "WEB") {
    if (
      props.entryAnimation ||
      props.entryAnimationF ||
      props.entryAnimationB
    ) {
      if (props.onAnimationEnd) {
        var callbackFunction = props.onAnimationEnd;
        var updatedCallback = function(event) {
          hideOldScreenNow(event);
          callbackFunction(event);
        };
        props.onAnimationEnd = updatedCallback;
      } else {
        props.onAnimationEnd = hideOldScreenNow;
      }
    }
    if (props.entryAnimation) {
      props.inlineAnimation = props.entryAnimation;
    }

    if (props.entryAnimationF) {
      props.inlineAnimation = props.entryAnimationF;
    }

    if (props.entryAnimationB) {
      window.entryAnimationB[window.__dui_screen][elem.__ref.__id] = {
        visibility: props.visibility ? props.visibility : "visible",
        inlineAnimation: props.entryAnimationB,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimation) {
      window.exitAnimation[window.__dui_screen][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimation,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimationF) {
      window.exitAnimationF[window.__dui_screen][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimationF,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimationB) {
      window.exitAnimationB[window.__dui_screen][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimationB,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }
  }

  if (props.focus == false && window.__OS === "ANDROID") {
    delete props.focus;
  }

  const children = [];

  for (var i = 0; i < elem.children.length; i++) {
    children.push(domAll(elem.children[i]));
  }

  // android specific code
  // if (type == "viewPager" && window.__OS === "ANDROID") {
  //   const pages = children.splice(0);
  //   const id  = elem.__ref.__id;
  //   const cardWidth = elem.props.cardWidth || 1.0;
  //   props.afterRender = function () {
  //     var plusButtonWidth = 0.2;
  //     if (pages.length == 1) {
  //       plusButtonWidth = 0.8;
  //     }
  //     JBridge.viewPagerAdapter(id, JSON.stringify(pages), cardWidth, plusButtonWidth);
  //   }
  //   delete elem.props.cardWidth;
  // }

  // if (type == "listView" && props.text) {
  //   const id  = elem.__ref.__id;
  //   const text = props.text;
  //   const cb = props.onChange;
  //   delete props.text;
  //   props.afterRender = function () {
  //     const callbackName = 'listview' + id;
  //     window.top.__BOOT_LOADER[callbackName] = function () {
  //       JBridge.bankListRefresh(id);
  //     }
  //     const fn = function(i) {
  //       if (typeof cb === "function") {
  //         cb(i);
  //       }

  //     }
  //     JBridge.bankList(id, text, callbackName, window.callbackMapper(fn));
  //   }
  // }

  if (__OS == "WEB" && props.onResize) {
    window.__resizeEvent = props.onResize;
  }

  props.id = elem.__ref.__id;
  if (elem.parentType && window.__OS == "ANDROID")
    return prestoDayum(
      {
        elemType: type,
        parentType: elem.parentType
      },
      props,
      children
    );

  return prestoDayum(type, props, children);
}

function hideOldScreenNow(tag) {
  var holdArray = window.viewsTobeRemoved;
  var tohide = window.hideold;
  window.hideold = undefined;
  window.viewsTobeRemoved = [];
  var clearCache = window.cacheClearCache;
  window.cacheClearCache = undefined;
  holdArray.forEach(function(obj) {
    Android.removeView(obj);
  });
  if (clearCache) {
    clearCache();
  }
  if (tohide) {
    tohide();
  }
  window.enableBackpress = true;
}

function cmdForAndroid(config, set, type) {
  if (set) {
    if (config.id) {
      var obj = parseParams(type, config, "set");
      var cmd = obj.runInUI
        .replace("this->setId", "set_view=ctx->findViewById")
        .replace(/this->/g, "get_view->");
      cmd = cmd.replace(/PARAM_CTR_HOLDER[^;]*/g, "get_view->getLayoutParams;");
      obj.runInUI = cmd;
      return obj;
    } else {
      console.error(
        "ID null, this is not supposed to happen. Debug this or/and raise a issue in bitbucket."
      );
    }
    return {};
  }

  const id = config.id;
  var cmd = "set_view=ctx->findViewById:i_" + id + ";";
  delete config.id;
  config.root = "true";
  var obj = parseParams(type, config, "get");
  obj.runInUI = cmd + obj.runInUI + ";";
  obj.id = id;
  return obj;
}

function applyProp(element, attribute, set) {
  var prop = {
    id: element.__ref.__id
  };
  prop[attribute.value0] = attribute.value1;

  if (
    attribute.value0 == "focus" &&
    attribute.value1 == false &&
    window.__OS == "ANDROID"
  ) {
    return;
  }

  if (window.__OS == "ANDROID") {
    var cmd = cmdForAndroid(prop, set, element.type);
    if (Android.updateProperties) {
      Android.updateProperties(JSON.stringify(cmd));
    } else {
      Android.runInUI(cmd.runInUI, null);
    }
  } else if (window.__OS == "IOS") {
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
  const viewGroups = [
    "linearLayout",
    "relativeLayout",
    "scrollView",
    "frameLayout",
    "horizontalScrollView"
  ];

  if (viewGroups.indexOf(element.type) != -1) {
    props.root = true;
    rep = prestoDayum(element.type, props, []);
  } else if (window.__OS == "ANDROID") {
    rep = prestoDayum(
      {
        elemType: element.type,
        parentType: element.parentNode.type
      },
      props,
      []
    );
  } else {
    rep = prestoDayum(element.type, props, []);
  }
  if (window.__OS == "ANDROID") {
    Android.replaceView(JSON.stringify(rep), element.__ref.__id);
  } else {
    Android.replaceView(rep, element.__ref.__id);
  }
}

window.moveChild = moveChild;
window.removeChild = removeChild;
window.addChild = addChild;
window.replaceView = replaceView;
window.addProperty = addAttribute;
// window.removeAttribute = removeAttribute;
window.updateProperty = updateAttribute;
window.addAttribute = addAttribute;
window.insertDom = insertDom;
window.createPrestoElement = function() {
  if (
    typeof window.__ui_id_sequence != "undefined" &&
    window.__ui_id_sequence != null
  ) {
    return {
      __id: ++window.__ui_id_sequence
    };
  } else {
    window.__ui_id_sequence =
      typeof Android.getNewID == "function"
        ? parseInt(Android.getNewID()) * 1000000
        : window.__PRESTO_ID;
    return {
      __id: ++window.__ui_id_sequence
    };
  }
};

window.__screenSubs = {};

function moveChild(child, parent, index) {
  Android.moveView(child.__ref.__id, index);
}

function removeChild(child, parent, index) {
  // console.log("Remove child :", child.type);
  Android.removeView(child.__ref.__id);
}

function addChild(child, parent, index) {
  if (child.type == null) {
    console.warn("child null");
  }
  // console.log("Add child :", child.__ref.__id, child.type);
  const viewGroups = [
    "linearLayout",
    "relativeLayout",
    "scrollView",
    "frameLayout",
    "horizontalScrollView"
  ];
  if (window.__OS == "ANDROID") {
    if (viewGroups.indexOf(child.type) != -1) {
      child.props.root = true;
    } else {
      child.parentType = parent.type;
    }
    Android.addViewToParent(
      parent.__ref.__id + "",
      JSON.stringify(domAll(child)),
      index,
      null,
      null
    );
  } else
    Android.addViewToParent(
      parent.__ref.__id,
      domAll(child),
      index,
      null,
      null
    );
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
  var root = {
    type: "relativeLayout",
    props: {
      root: "true"
    },
    children: []
  };

  root.props.height = "match_parent";
  root.props.width = "match_parent";
  var elemRef = window.createPrestoElement();
  root.props.id = elemRef.__id;
  root.type = "relativeLayout";
  root.__ref = elemRef;

  window.N = root;
  window.__CACHELIMIT = 50;
  window.__psNothing = nothing;
  window.MACHINE_MAP = {};
  window.__CANCELER = {};
  // Android specific shadow.
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

  if (window.__OS == "ANDROID") {
    if (typeof Android.getNewID == "function") {
      Android.Render(JSON.stringify(domAll(root)), null, "false");
    } else {
      Android.Render(JSON.stringify(domAll(root)), null);
    }
  } else if (window.__OS == "WEB") {
    Android.Render(domAll(root), null);
  } else {
    Android.Render(domAll(root), null);
  }

  return root;
};

exports.getRootNode = function() {
  return window.N;
};

function clearStash() {
  var screen = window.__stashScreen;
  var len = screen.length;

  setTimeout(function() {
    for (var i = 0; i < len; i++) {
      Android.removeView(screen[i]);
    }
  }, 1000);
  window.__stashScreen = [];
}

function makeVisible(cache, _id) {
  // console.log("SCREEN", " makeVisible", cache, _id);
  if (cache) {
    var prop = {
      id: _id,
      visibility: "visible"
    };
  } else {
    var length = window.__ROOTSCREEN.idSet.child.length;
    var prop = {
      id: window.__ROOTSCREEN.idSet.child[length - 1].id,
      visibility: "visible"
    };
  }
  // console.log("SCREEN", " makeVisible", prop);
  if (window.__OS == "ANDROID") {
    var cmd = cmdForAndroid(prop, true, "linearLayout");
    Android.runInUI(cmd.runInUI, null);
  } else if (window.__OS == "IOS") {
    Android.runInUI(prop);
  } else {
    Android.runInUI(webParseParams("relativeLayout", prop, "set"));
  }
}

function screenIsInStack(screen) {
  var ar = window.__ROOTSCREEN.idSet.child;
  window.viewsTobeRemoved = [];
  for (var i = 0, l = ar.length; i < l; i++) {
    if (ar[i].name.value0 == screen.value0) {
      var rem = window.__ROOTSCREEN.idSet.child.splice(i + 1);
      if (rem.length || i != l - 1) {
        if (i == 0) window.__prevScreenName = window.__psNothing;
        else
          window.__prevScreenName = window.__ROOTSCREEN.idSet.child[i - 1].name;
        window.__currScreenName = screen;

        // setTimeout(function() {
        for (var j = 0, k = rem.length; j < k; j++) {
          window.viewsTobeRemoved.push(rem[j].id);
          // Android.removeView(rem[j].id);
          delete window.MACHINE_MAP[rem[j].name.value0];
        }
        // }, 1000);

        makeVisible(false);
      }
      return true;
    }
  }

  return false;
}

exports.saveScreenNameImpl = function(screen) {
  clearStash();

  if (screen == window.__psNothing) {
    window.__screenNothing = true;
    return false;
  } else {
    window.__screenNothing = false;
    window.__dui_last_patch_screen = screen.value0;

    var cond = screenIsInStack(screen);

    if (cond) {
      // console.log("SCREEN", " saveScreen calling hide", screen);
      hideCachedScreen();
      return true;
    } else {
      window.__prevScreenName = window.__currScreenName;
      window.__currScreenName = screen;

      return false;
    }
  }
};

function screenIsCached(screen) {
  var ar = window.__CACHED_SCREEN;

  // console.log("SCREEN", " screenIsCached", screen);

  if (
    window.__lastCachedScreen.name &&
    window.__lastCachedScreen.name.value0 == screen.value0
  ) {
    return true;
  }

  for (var i = 0, l = ar.length; i < l; i++) {
    if (ar[i].name.value0 == screen.value0) {
      makeVisible(true, ar[i].id);
      if (
        window.__lastCachedScreen.name &&
        window.__lastCachedScreen.name != ""
      ) {
        var __visibility = window.__OS == "ANDROID" ? "gone" : "invisible";
        var prop = {
          id: window.__lastCachedScreen.id,
          visibility: __visibility
        };
        // console.log("SCREEN", " screenIsCached", screen, prop);
        if (window.__OS == "ANDROID") {
          var cmd = cmdForAndroid(prop, true, "relativeLayout");
          Android.runInUI(cmd.runInUI, null);
        } else if (window.__OS == "IOS") {
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
  clearStash();

  if (screen == window.__psNothing) {
    window.__screenNothing = true;
    return false;
  } else {
    window.__screenNothing = false;
    window.__dui_last_patch_screen = screen.value0;
    // console.log("SCREEN", " cachedScreenImpl", screen);

    var cond = screenIsCached(screen);

    window.__lastCachedScreen.name = screen;

    return cond;
    // if (cond) {
    //   return true;
    // } else {

    //   return false;
    // }
  }
};

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
  a();
  console.log("Logger !!! : ", a);
};

function hideCachedScreen() {
  if (window.__lastCachedScreen.flag) {
    window.__lastCachedScreen.flag = false;
    var __visibility = window.__OS == "ANDROID" ? "gone" : "invisible";
    var prop = {
      id: window.__lastCachedScreen.id,
      visibility: __visibility
    };
    // console.log("SCREEN", " hideCached", prop);

    window.__lastCachedScreen.name = "";

    window.cacheClearCache = function() {
      if (window.__OS == "ANDROID") {
        var cmd = cmdForAndroid(prop, true, "relativeLayout");
        Android.runInUI(cmd.runInUI, null);
      } else if (window.__OS == "IOS") {
        Android.runInUI(prop);
      } else {
        Android.runInUI(webParseParams("relativeLayout", prop, "set"));
      }
    };
    if (window.__OS == "WEB") {
      // Remove this when animation end hooks are added in WEB
      window.cacheClearCache();
    }
  }
}

exports.processWidget = function() {
  if (window.widgets) {
    window.widgets.forEach(function(obj) {
      obj.fn(obj.id_)();
    });
    window.widgets = [];
  }
};

function insertDom(root, dom) {
  root.children.push(dom);
  dom.parentNode = root;
  //dom.__ref = window.createPrestoElement();
  
  if(dom.props && dom.props.hasOwnProperty('id') && (dom.props.id).toString().trim()){
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  }else{
    dom.__ref = window.createPrestoElement();
  }

  window.N = root;

  var rootId = window.__ROOTSCREEN.idSet.root;

  dom.props.root = true;
  if (window.__screenNothing) {
    window.__stashScreen.push(dom.__ref.__id);
    window.__screenNothing = false;
  } else {
    var screenName = window.__currScreenName;

    var length = window.__ROOTSCREEN.idSet.child.push({
      id: dom.__ref.__id,
      name: screenName
    });
    if (length >= window.__CACHELIMIT) {
      window.__ROOTSCREEN.idSet.child.shift();
      length -= 1;
    }

    if (length >= 2) {
      var __visibility = window.__OS == "ANDROID" ? "gone" : "invisible";
      var prop = {
        id: window.__ROOTSCREEN.idSet.child[length - 2].id,
        visibility: __visibility
      };

      window.hideold = function() {
        if (window.__OS == "ANDROID" && length > 1) {
          var cmd = cmdForAndroid(prop, true, "relativeLayout");
          Android.runInUI(cmd.runInUI, null);
        } else if (window.__OS == "IOS" && length > 1) {
          Android.runInUI(prop);
        } else if (length > 1) {
          Android.runInUI(webParseParams("relativeLayout", prop, "set"));
        }
      };
    }
  }

  var callback = window.callbackMapper(executePostProcess("F"));
  if (window.__OS == "ANDROID") {
    Android.addViewToParent(
      rootId + "",
      JSON.stringify(domAll(dom)),
      length - 1,
      callback,
      null
    );
  } else {
    Android.addViewToParent(rootId, domAll(dom), length - 1, callback, null);
  }

  hideCachedScreen();
}

exports.updateDom = function(root, dom) {
  root.children.push(dom);
  dom.parentNode = root;
  //dom.__ref = window.createPrestoElement();
  window.N = root;
  
  if(dom.props && dom.props.hasOwnProperty('id') && (dom.props.id).toString().trim()) {
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  }else{
    dom.__ref = window.createPrestoElement();
  }

  var rootId = window.__ROOTSCREEN.idSet.root;

  var length = window.__ROOTSCREEN.idSet.child.length;
  dom.props.root = true;
  if (window.__screenNothing) {
    window.__stashScreen.push(dom.__ref.__id);
    window.__screenNothing = false;
  } else {
    if (
      window.__lastCachedScreen.id &&
      window.__lastCachedScreen.name &&
      window.__lastCachedScreen.name != ""
    ) {
      var __visibility = window.__OS == "ANDROID" ? "gone" : "invisible";
      var prop = {
        id: window.__lastCachedScreen.id,
        visibility: __visibility
      };
      if (window.__OS == "ANDROID") {
        var cmd = cmdForAndroid(prop, true, "relativeLayout");
        Android.runInUI(cmd.runInUI, null);
      } else if (window.__OS == "IOS") {
        Android.runInUI(prop);
      } else {
        Android.runInUI(webParseParams("relativeLayout", prop, "set"));
      }
    }
    window.__lastCachedScreen.id = dom.__ref.__id;
    window.__lastCachedScreen.flag = true;
    var screenName = window.__lastCachedScreen.name;

    window.__CACHED_SCREEN.push({
      id: dom.__ref.__id,
      name: screenName
    });
  }

  if (window.__OS == "ANDROID") {
    var callback = window.callbackMapper(executePostProcess(""));
    Android.addViewToParent(
      rootId,
      JSON.stringify(domAll(dom)),
      length,
      callback,
      null
    );
  } else {
    Android.addViewToParent(rootId, domAll(dom), length, null, null);
  }
};

function callAnimation(tag) {
  if (window.__dui_old_screen != window.__dui_screen) {
    window.enableBackpress = false;
    if (window.__OS == "WEB") {
      hideOldScreenNow();
      window.__dui_old_screen = window.__dui_screen;
      return;
    }
    if (
      window.__dui_screen &&
      window["entryAnimation" + tag] &&
      window["entryAnimation" + tag][window.__dui_screen]
    ) {
      for (var key in window["entryAnimation" + tag][window.__dui_screen]) {
        var config = {
          id: key,
          inlineAnimation:
            window["entryAnimation" + tag][window.__dui_screen][key]
              .inlineAnimation,
          onAnimationEnd:
            window["entryAnimation" + tag][window.__dui_screen][key]
              .onAnimationEnd,
          visibility:
            window["entryAnimation" + tag][window.__dui_screen][key].visibility
        };
        if (window.__OS == "ANDROID") {
          var cmd = cmdForAndroid(
            config,
            true,
            window["entryAnimation" + tag][window.__dui_screen][key].type
          );
          if (Android.updateProperties) {
            Android.updateProperties(JSON.stringify(cmd));
          } else {
            Android.runInUI(cmd.runInUI, null);
          }
        } else if (window.__OS == "IOS") {
          Android.runInUI(config);
        } else {
          Android.runInUI(webParseParams("linearLayout", config, "set"));
        }
      }
    }

    if (
      window.__dui_old_screen &&
      window["exitAnimation" + tag] &&
      window["exitAnimation" + tag][window.__dui_old_screen]
    ) {
      for (var key in window["exitAnimation" + tag][window.__dui_old_screen]) {
        var config2 = {
          id: key,
          inlineAnimation:
            window["exitAnimation" + tag][window.__dui_old_screen][key]
              .inlineAnimation
        };
        if (window.__OS == "ANDROID") {
          var cmd2 = cmdForAndroid(
            config2,
            true,
            window["exitAnimation" + tag][window.__dui_old_screen][key].type
          );
          if (Android.updateProperties) {
            Android.updateProperties(JSON.stringify(cmd2));
          } else {
            Android.runInUI(cmd2.runInUI, null);
          }
        } else if (window.__OS == "IOS") {
          Android.runInUI(config2);
        } else {
          Android.runInUI(webParseParams("linearLayout", config2, "set"));
        }
      }
    }
  }
  window.__dui_old_screen = window.__dui_screen;
}

function executePostProcess(cache) {
  return function() {
    callAnimation(cache);
    if (window.__dui_screen && window["afterRender"]) {
      for (var tag in window["afterRender"][window.__dui_screen]) {
        try {
          window["afterRender"][window.__dui_screen][tag]()();
          window["afterRender"][window.__dui_screen]["executed"] = true;
        } catch (err) {
          console.warn(err);
        }
      }
    }

    if (JBridge && JBridge.setShadow) {
      for (var tag in window.shadowObject) {
        JBridge.setShadow(
          window.shadowObject[tag]["level"],
          JSON.stringify(window.shadowObject[tag]["viewId"]),
          JSON.stringify(window.shadowObject[tag]["backgroundColor"]),
          JSON.stringify(window.shadowObject[tag]["blurValue"]),
          JSON.stringify(window.shadowObject[tag]["shadowColor"]),
          JSON.stringify(window.shadowObject[tag]["dx"]),
          JSON.stringify(window.shadowObject[tag]["dy"]),
          JSON.stringify(window.shadowObject[tag]["spread"]),
          JSON.stringify(window.shadowObject[tag]["factor"])
        );
      }
    } else {
      console.warn("experimental feature: JBridge is not available in native");
    }
  };
}

exports.exitUI = function(tag) {
  return function() {
    window.__dui_last_patch_screen = "";
    window["currentCancellor" + tag]();
    delete window["currentCancellor" + tag];
  };
};
