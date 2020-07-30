
const prestoUI = require("presto-ui")
const prestoDayum = window.prestoUI ? window.prestoUI.doms : prestoUI.doms;
var webParseParams, iOSParseParams, parseParams;
var getNewID = window.josAndroid ? window.josAndroid.getNewID : Android.getNewID;

const state = {
  animationStack : []
, animationCache : []
, lastAnimatedScreen : ""
}

const callbackMapper = prestoUI.callbackMapper;

if (window.__OS === "WEB") {
  webParseParams = prestoUI.helpers.web.parseParams;
} else if (window.__OS == "IOS") {
  iOSParseParams = prestoUI.helpers.ios.parseParams;
} else {
  parseParams = prestoUI.helpers.android.parseParams;
}


window.callbackMapper = callbackMapper.map;

exports.terminateUI = function (){
  if(window.__OS == "ANDROID" && Android.runInUI && window.__ROOTSCREEN && window.__ROOTSCREEN.idSet) {
    Android.runInUI(";set_v=ctx->findViewById:i_" + window.__ROOTSCREEN.idSet.root + ";set_p=get_v->getParent;get_p->removeView:get_v;", null);
  } else if(JOS && JOS.parent && JOS.parent != "java" && window.__ROOTSCREEN && window.__ROOTSCREEN.idSet) {
    Android.removeView(window.__ROOTSCREEN.idSet.root);
  } else {
    Android.runInUI(["removeAllUI"], null);
  }
  state.animationStack = []
  state.animationCache = []
  state.lastAnimatedScreen = ""
  window.__VIEWS = [];
  window.__ROOTSCREEN = undefined;
  window.MACHINE = undefined;
  window.MACHINE_MAP = undefined;
  window.N = undefined;
  window.__dui_last_patch_screen = undefined;
  window.__dui_screen = undefined;
  window.__dui_old_screen = undefined;

  /**
   * checks if pre-rendering is being done and reset variables accordingly
   */
  if (window.__CACHED_MACHINE && Object.keys(window.__CACHED_MACHINE).length > 0){
    for(var screen in window["afterRender"]){
      /**
       * tags in pre-rendered screens will be reused, where as in normal screen
       * they will be recreated. Hence resetting it accordingly
       */
      if (screen in window.__CACHED_MACHINE){
        window["afterRender"][screen]["executed"] = false;
      } else {
        window["afterRender"][screen] = undefined;
      }
    }
  }else{
    window.__usedIDS = undefined;
    /**
     * Reason to reset: Since afterRender events is been handeled in JS side, we
     * are maintaining it's state of execution to prevent repetative trigers in
     * one iteration. Hence a need to reset
     */
    window.afterRender = undefined;
  }
}

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
    window.__dui_old_screen = window.__dui_screen + "";

    /**
     * Resetting afterRender state for previous screen
     */
    if( window["afterRender"] && window["afterRender"][window.__dui_screen] && window["afterRender"][window.__dui_screen]["executed"]){
      window["afterRender"][window.__dui_screen]["executed"] = false;
    }
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
  if(window.__CACHED_MACHINE[screen.value0]) {
    window.__CACHED_MACHINE[screen.value0] = machine;
  }
};

exports.getLatestMachine = function(screen) {
  if (screen.value0) {
    return window.MACHINE_MAP[screen.value0];
  }
  return window.MACHINE;
};

exports.cacheMachine = function(machine, screenName) {
  if (! window.hasOwnProperty("__CACHED_MACHINE")){
    window.__CACHED_MACHINE = {}
  }
  window.__CACHED_MACHINE[screenName] = machine;
};

/**
 * returns Nothing if __CACHED_MACHINE don't have machine
 * This function will make sure that addScreen logic don't get executed
 * if machine not present.
 *
 */
exports.getCachedMachineImpl = function(just,nothing,screenName) {
  if (window.__OS === "ANDROID"){
    var machine = window.__CACHED_MACHINE[screenName];
    if (machine != null && (typeof machine == "object")){
      return just(machine);
    } else {
      return nothing;
    }
  } else {
    return nothing;
  }
}

exports.insertDom = insertDom;

function getPrestoID() {
  if (window.__OS === "WEB") {
    return 1;
  }

  return top.__PRESTO_ID ? ++top.__PRESTO_ID : 1;
}

window.__PRESTO_ID = window.__ui_id_sequence =
  typeof getNewID == "function"
    ? parseInt(getNewID()) * 1000000
    : getPrestoID() * 1000000;

exports._domAll = domAll;

function domAll(elem){
  return domAllImpl(elem, window.__dui_screen, {});
}

/**
 * Creates DUI element from machine element
 * Note: Only for Android
 * @param {object} elem - machine
 * @param {object} screenName
 * @param {object} VALIDATE_ID - for validating duplicate IDs, always pass empty object
 * @return {DUIElement}
 *
 * Can be called in pre-rendering, doesn't depend on window.__dui_screen
 */
function domAllImpl(elem, screenName, VALIDATE_ID) {
  /*
  if (!elem.__ref) {
    elem.__ref = window.createPrestoElement();
  }

  if (elem.props.id) {
    elem.__ref.__id = parseInt(elem.props.id, 10) || elem.__ref.__id;
  }
  */

  if (elem.props.hasOwnProperty('id') && elem.props.id != '' && (elem.props.id).toString().trim() != '') {
    var id = (elem.props.id).toString().trim();
    elem.__ref = {__id: id };
    if (VALIDATE_ID.hasOwnProperty(id)){
      console.warn("Found duplicate ID! ID: "+ id +
        " maybe caused because of overiding `id` prop. This may produce unwanted behvior. Please fix..");
    }else{
      VALIDATE_ID[id] = 'used';
    }
  } else if(!elem.__ref) {
    elem.__ref = window.createPrestoElement()
  }

  window.entryAnimation = window.entryAnimation || {};
  window.entryAnimation[screenName] =
    window.entryAnimation[screenName] || {};

  window.entryAnimationF = window.entryAnimationF || {};
  window.entryAnimationF[screenName] =
    window.entryAnimationF[screenName] || {};

  window.entryAnimationB = window.entryAnimationB || {};
  window.entryAnimationB[screenName] =
    window.entryAnimationB[screenName] || {};

  window.exitAnimation = window.exitAnimation || {};
  window.exitAnimation[screenName] =
    window.exitAnimation[screenName] || {};

  window.exitAnimationF = window.exitAnimation || {};
  window.exitAnimationF[screenName] =
    window.exitAnimationF[screenName] || {};

  window.exitAnimationB = window.exitAnimationB || {};
  window.exitAnimationB[screenName] =
    window.exitAnimationB[screenName] || {};

  var type = prestoUI.prestoClone(elem.type);
  var props = prestoUI.prestoClone(elem.props);

  if (window.__OS !== "WEB") {
    if(props.hasOwnProperty("afterRender")){
      window.afterRender = window.afterRender || {}
      window.afterRender[screenName] = window.afterRender[screenName] || {}
      var x = props.afterRender;
      window.afterRender[screenName][elem.__ref.__id] = function(){
        return x;
      }
      delete props.afterRender
    }
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
      window.entryAnimation[screenName]["hasAnimation"] = true
      window.entryAnimation[screenName][elem.__ref.__id] = {
        visibility: props.visibility ? props.visibility : "visible",
        inlineAnimation: props.entryAnimation,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.entryAnimationF) {
        window.entryAnimationF[screenName]["hasAnimation"] = true
        window.entryAnimationF[screenName][elem.__ref.__id] = {
          visibility: props.visibility ? props.visibility : "visible",
          inlineAnimation: props.entryAnimationF,
          onAnimationEnd: props.onAnimationEnd,
          type: type
        };
        props.inlineAnimation = props.entryAnimationF;
    }

    if (props.entryAnimationB) {
      window.entryAnimationB[screenName]["hasAnimation"] = true
      window.entryAnimationB[screenName][elem.__ref.__id] = {
        visibility: props.visibility ? props.visibility : "visible",
        inlineAnimation: props.entryAnimationB,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimation) {
      window.exitAnimation[screenName]["hasAnimation"] = true
      window.exitAnimation[screenName][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimation,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimationF) {
      window.exitAnimationF[screenName]["hasAnimation"] = true
      window.exitAnimationF[screenName][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimationF,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimationB) {
      window.exitAnimationB[screenName]["hasAnimation"] = true
      window.exitAnimationB[screenName][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimationB,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }
  }

  if (props.focus == false && window.__OS === "ANDROID") {
    delete props.focus;
  }

  var children = [];

  for (var i = 0; i < elem.children.length; i++) {
    children.push(domAllImpl(elem.children[i], screenName, VALIDATE_ID));
  }

  // android specific code
  // if (type == "viewPager" && window.__OS === "ANDROID") {
  //   var pages = children.splice(0);
  //   var id  = elem.__ref.__id;
  //   var cardWidth = elem.props.cardWidth || 1.0;
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
  //   var id  = elem.__ref.__id;
  //   var text = props.text;
  //   var cb = props.onChange;
  //   delete props.text;
  //   props.afterRender = function () {
  //     var callbackName = 'listview' + id;
  //     window.top.__BOOT_LOADER[callbackName] = function () {
  //       JBridge.bankListRefresh(id);
  //     }
  //     var fn = function(i) {
  //       if (typeof cb === "function") {
  //         cb(i);
  //       }

  //     }
  //     JBridge.bankList(id, text, callbackName, window.callbackMapper(fn));
  //   }
  // }

  if (window.__OS == "WEB" && props.onResize) {
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
  var holdArray = window.viewsTobeRemoved || [];
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

  var id = config.id;
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

function replaceView(element) {
  // console.log("REPLACE VIEW", element.__ref.__id, element.props);
  var props = prestoUI.prestoClone(element.props);
  props.id = element.__ref.__id;
  var rep;
  var viewGroups = [
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

window.createPrestoElement = createPrestoElement;

function createPrestoElement() {
  if (
    typeof window.__ui_id_sequence != "undefined" &&
    window.__ui_id_sequence != null
  ) {
    return {
      __id: ++window.__ui_id_sequence
    };
  } else {
    window.__ui_id_sequence =
      typeof getNewID == "function"
        ? parseInt(getNewID()) * 1000000
        : window.__PRESTO_ID;
    return {
      __id: ++window.__ui_id_sequence
    };
  }
};


exports.replaceView = replaceView;
exports.addChild = addChild;
exports.moveChild = moveChild;
exports.removeChild = removeChild;
exports.createPrestoElement = createPrestoElement;
exports.addProperty = function (key, val, obj) {
  addAttribute(obj, {value0: key, value1: val})
};
exports.updateProperty = function (key, val, obj) {
  updateAttribute(obj, {value0: key, value1: val});
};
exports.cancelBehavior = function (ty) {
    var canceler = window.__CANCELER[ty];
    canceler();
}

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
  var viewGroups = [
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
  // replaceView(element, attribute, true);
  replaceView(element);
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
      root: "true",
      height: "match_parent",
      width: "match_parent",
      clickable: "true",
      focusable: "true"
    },
    children: []
  };

  var elemRef = window.createPrestoElement();
  root.props.id = elemRef.__id;
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
  // store pre-rendered dom
  if (! window.hasOwnProperty("__CACHED_MACHINE")){
    window.__CACHED_MACHINE = {}
  }
  if (window.__OS == "ANDROID") {
    if (typeof getNewID == "function") {
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

  var callback = window.callbackMapper(executePostProcess(false));
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
    var callback = window.callbackMapper(executePostProcess(true));
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
        if (key == "hasAnimation")
          continue;
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
      window["exitAnimation" + tag][window.__dui_old_screen] &&
      window["exitAnimation" + tag][window.__dui_old_screen]["hasAnimation"]
    ) {
      for (var key in window["exitAnimation" + tag][window.__dui_old_screen]) {
        if (key == "hasAnimation")
          continue;
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
    } else {
      hideOldScreenNow()
    }
  }
  window.__dui_old_screen = window.__dui_screen;
}

function executePostProcess(cache) {
  return function() {
    callAnimation__(window.__dui_screen) (cache) ();
    if (window.__dui_screen && window["afterRender"] && window["afterRender"][window.__dui_screen] && !window["afterRender"][window.__dui_screen].executed) {
      for (var tag in window["afterRender"][window.__dui_screen]) {
        if (tag === "executed")
          continue;
        try {
          window["afterRender"][window.__dui_screen][tag]()();
          window["afterRender"][window.__dui_screen]["executed"] = true;
        } catch (err) {
          console.warn(err);
        }
      }
    }

    if (window.postRenderCallback) {
      window.postRenderCallback(window.__dui_screen);
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

/**
 * Implicit animation logic.
 * 1. If two consecutive screens are runscreen. Call animation on both.
 * 2. If screen is show screen and previous screen is runscreen. Call animation only on showScreen
 * 3. If screen is run screen and previous is show. Call animation on show, run and previous visible run.\
 * animationStack : Array of runscreens where exit animation has not be called
 * animationCache : Array of showscreens.
 */

function callAnimation__ (screenName) {
  return function(cache) {
    return function(){
      if (screenName == state.lastAnimatedScreen)
        return;
      var isRunScreen = state.animationStack.indexOf(screenName) != -1;
      var isShowScreen = state.animationCache.indexOf(screenName) != -1;
      var isLastAnimatedCache = state.animationCache.indexOf(state.lastAnimatedScreen) != -1;
      var topOfStack = state.animationStack[state.animationStack.length - 1];
      var animationArray = []
      if (isLastAnimatedCache){
        animationArray.push({ screenName : state.lastAnimatedScreen + "", tag : "exitAnimation"});
      }
      if (isRunScreen || isShowScreen) {
        if(isRunScreen) {
          if(topOfStack != screenName) {
            animationArray.push({ screenName : screenName, tag : "entryAnimationB"})
            animationArray.push({ screenName : topOfStack, tag : "exitAnimationB"})
            while (state.animationStack[state.animationStack.length - 1] != screenName){
              state.animationStack.pop();
            }
          }
        } else {
          animationArray.push({ screenName : screenName, tag : "entryAnimation"})
        }
      } else {
        // Newscreen case
        if (cache){
          state.animationCache.push(screenName); // TODO :: Use different data structure. Array does not realy fit the bill.
        } else {
          // new runscreen case call forward exit animation of previous runscreen
          var previousScreen = state.animationStack[state.animationStack.length - 1]
          animationArray.push({ screenName : previousScreen, tag : "exitAnimationF"})
          state.animationStack.push(screenName);
        }
      }
      callAnimation_(animationArray, false)
      state.lastAnimatedScreen = screenName;
    }
  }
}

function callAnimation_ (screenArray, resetAnimation) {
  window.enableBackpress = false;
  if (window.__OS == "WEB") {
    hideOldScreenNow();
    return;
  }
  var hasAnimation = false;
  screenArray.forEach(
    function (animationJson) {
      if (window[animationJson.tag] && window[animationJson.tag][animationJson.screenName]) {
        var animationJson = window[animationJson.tag][animationJson.screenName]
        for (var key in animationJson) {
          if (key == "hasAnimation")
            continue;
          hasAnimation = true;
          var config = {
            id: key,
            inlineAnimation: animationJson[key].inlineAnimation,
            onAnimationEnd: animationJson[key].onAnimationEnd,
            visibility: animationJson[key].visibility
          };
          if (resetAnimation){
            config["resetAnimation"] = true;
          }
          if (window.__OS == "ANDROID") {
            var cmd = cmdForAndroid(
              config,
              true,
              animationJson[key].type
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
    }
  );
  if (!hasAnimation){
    hideOldScreenNow()
  }
}

exports.callAnimation_ = callAnimation__;

/**
 * Renders dom ahead of time it's actually to be seen.
 * Note: Only for Android
 * @param {function} callback - function to be called after completing native render
 * @param {String} screenName - to store reference
 * @param {object} dom - dom object to render
 * @return {void}
 *
 * this function will create dom and send it to mystique in order
 * to keep UI ready ahead of time
 */
exports.prepareDom = prepareDom;
function prepareDom (callback, screenName, dom){
  if (window.__OS == "ANDROID"){
    if(dom.props && dom.props.hasOwnProperty('id') && (dom.props.id).toString().trim()){
      dom.__ref = {__id: (dom.props.id).toString().trim()};
    }else{
      dom.__ref = window.createPrestoElement();
    }
    dom.props.root = true;

    /**
     * Adding callback to make sure that prepareScreen returns controll only
     * after native rendering is completed
     */
    var callB = window.callbackMapper(callback());
    Android.prepareAndStoreView(
      screenName,
      JSON.stringify(domAllImpl(dom, screenName, {})),
      callB
    );
  } else {
    console.warn("Implementation of prepareDom function missing for "+ window.__OS );
    callback()();
  }
}

/**
 * Inflates view depending on screeen name. Always call after prepareDom().
 * Note: Only for Android
 * @param {object} root - root object, to maintain screen stack
 * @param {object} dom - dom object to render
 * @param {String} screenName - to store reference
 * @return {void}
 *
 * This function will attach screen to root node. The screen is assumed to be cached
 * at android side. Native side should handle the case where screen is not yet ready
 * and is been processed
 */
exports.attachScreen = attachScreen;
function attachScreen(root,dom, screenName){
  if (window.__OS == "ANDROID") {
    root.children.push(dom);
    window.N = root;
    var rootId = window.__ROOTSCREEN.idSet.root;
    if (window.__screenNothing) {
      window.__stashScreen.push(dom.__ref.__id);
      window.__screenNothing = false;
    } else {
      var currScreenName = window.__currScreenName;
      // push() returns array length
      var length = window.__ROOTSCREEN.idSet.child.push({
        id: dom.__ref.__id,
        name: currScreenName
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
    /**
     * Set visiblity to GONE, after attaching to root. Once the patch is done, well
     * set this visible again
     */
    var cmdHideChild = cmdForAndroid({
      id: dom.__ref.__id,
      visibility : "gone"
    }, true, "relativeLayout");

    var cmdScrollViewReset = getScrollViewResetCmds(dom);
    var cmds = cmdHideChild.runInUI+ ";" + cmdScrollViewReset;
    Android.addStoredViewToParent(
      rootId + "",
      screenName,
      length - 1,
      null,
      null,
      cmds
    );
  }else{
    console.warn("Implementation of addScreen function missing for "+ window.__OS );
  }
}

/**
 * This will return dui commands  to reset scrolled screen state
 * @param {object} dom
 * @return {string}
 */
function getScrollViewResetCmds(dom){
  var scrollViewIDs = getScrollViewIDs(dom);
  var cmdScrollViewReset = "";
  /**
   * genrate cmds for resetting scrolled view
   * android equivalent function is
   * scrollView.fullScroll(View.FOCUS_UP);
   */
  for(var i =0; i< scrollViewIDs.length; i++){
    cmdScrollViewReset += "set_view=ctx->findViewById:i_"+ scrollViewIDs[i] +";get_view->fullScroll:i_33;";
  }
  return cmdScrollViewReset;

}

/**
 * This will return the ID of scrollView to reset scrolled screen state
 * @param {object} dom
 * @return {array Int}
 */
function getScrollViewIDs(dom){
  var idArray = [];
  if (dom["type"] == "scrollView"){
    idArray.push(dom["__ref"]["__id"]);
  }
  for (var i= 0; i < dom["children"].length; i++){
    idArray = idArray.concat(getScrollViewIDs(dom["children"][i]));
  }
  return idArray;
}

/**
 * Will be called after patch on screen is complete. It'll set visiblity to visible
 * again, and then start animation on atttached screen.
 * @param {object} dom - dom object to get ID
 * @param {String} screenName - to start animation
 * @return {void}
 */
exports.addScreenWithAnim = function (dom,  screenName){
  if (window.__OS == "ANDROID") {
    var cmdMakeChildVisible = cmdForAndroid({
      id: dom.__ref.__id,
      visibility : "visible"
    }, true, "relativeLayout");
    Android.runInUI(cmdMakeChildVisible.runInUI, null);
    executePostProcess(false)();
    callAnimation_([{ screenName : screenName, tag : "entryAnimationF"}], true);
    hideCachedScreen();
  }
}

/**
 * This function is for maintaining backward compatibility between Mystique
 * and purescript-presto-dom. It'll also make sure that prepareScreen
 * only gets executed in Android.
 *
 */
exports.canPreRender = function (){
  if (window.__OS == "ANDROID"){
    if ( typeof Android.addStoredViewToParent == "function" &&
      typeof Android.prepareAndStoreView == "function"
    ) {
      return true;
    } else{
      console.warn("Mystique version not compatible. Skipping pre-rendering");
      return false;
    }
  } else {
    console.warn("Skipping Pre-Rendering for " + window.__OS );
    return false;
  }
}


