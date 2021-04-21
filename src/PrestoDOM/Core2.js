const prestoUI = require("presto-ui")
const prestoDayum = prestoUI.doms;
const callbackMapper = prestoUI.callbackMapper;
var webParseParams, iOSParseParams, parseParams;

if (window.__OS === "WEB") {
  webParseParams = prestoUI.helpers.web.parseParams;
} else if (window.__OS == "IOS") {
  iOSParseParams = prestoUI.helpers.ios.parseParams;
} else {
  parseParams = prestoUI.helpers.android.parseParams;
}

const state = {
  scopedState : {}
}

var getIdFromNamespace = function(namespace) {
  var ns = state.scopedState[namespace].id ? state.scopedState[namespace].id : undefined
  if(window.__OS == "ANDROID")
    ns = state.scopedState[namespace].id ? state.scopedState[namespace].id : null;
  return ns;
}

function getPrestoID() {
  if (window.__OS === "WEB") {
    return 1;
  }

  return top.__PRESTO_ID ? ++top.__PRESTO_ID : 1;
}


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
      typeof Android.getNewID == "function"
        ? parseInt(Android.getNewID()) * 1000000
        : window.__PRESTO_ID || getPrestoID() * 1000000;
    return {
      __id: ++window.__ui_id_sequence
    };
  }
};

function removeViewFromNameSpace (namespace, id) {
  // Return a callback, which can be used to remove the screen
  return function() {
    Android.removeView(id, getIdFromNamespace(namespace))
  }
}


function hideViewInNameSpace (id, namespace) {
  // Return callback to hide screens
  return function () {
    var __visibility = window.__OS == "IOS" ? "invisible" : "gone";
    var prop = {
      id: id,
      visibility: __visibility
    };
    if (window.__OS == "ANDROID") {
      var cmd = cmdForAndroid(prop, true, "relativeLayout");
      Android.runInUI(cmd.runInUI, null);
    } else if (window.__OS == "IOS") {
      Android.runInUI(prop, getIdFromNamespace(namespace));
    } else {
      Android.runInUI(webParseParams("relativeLayout", prop, "set"), getIdFromNamespace(namespace));
    }
  }
}

function showViewInNameSpace (id, namespace) {
  // Return callback to show screens
  return function () {
    var prop = {
      id: id,
      visibility: "visible"
    };
    if (window.__OS == "ANDROID") {
      var cmd = cmdForAndroid(prop, true, "relativeLayout");
      Android.runInUI(cmd.runInUI, null);
    } else if (window.__OS == "IOS") {
      Android.runInUI(prop, getIdFromNamespace(namespace));
    } else {
      Android.runInUI(webParseParams("relativeLayout", prop, "set"), getIdFromNamespace(namespace));
    }
  }
}

function domAll(elem, screenName, namespace){
  return domAllImpl(elem, screenName, {}, namespace);
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
function domAllImpl(elem, screenName, VALIDATE_ID, namespace) {
  /*
  if (!elem.__ref) {
    elem.__ref = createPrestoElement();
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
    } else {
      VALIDATE_ID[id] = 'used';
    }
  } else if(!elem.__ref) {
    elem.__ref = createPrestoElement()
  }

  var type = prestoUI.prestoClone(elem.type);
  var props = prestoUI.prestoClone(elem.props);

  if(type == "microapp") {
    // Add to queue of m-app ui to be triggered.
    // Queue to be fired on callback of AddViewToParent
    var mappBootData = {
      payload : props.payload
    , viewGroupTag : props.viewGroupTag
    , requestId : elem.requestId
    , service : props.service
    , elemId : elem.__ref.__id
    }
    state.scopedState[namespace].mappQueue.push(mappBootData);
    type = "linearLayout"
  }

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
          state.scopedState[namespace].activateScreen = true;
          hideOldScreenNow(namespace);
          callbackFunction(event);
        };
        props.onAnimationEnd = updatedCallback;
      } else {
        props.onAnimationEnd = function() {
            state.scopedState[namespace].activateScreen = true;
            hideOldScreenNow(namespace);
          }
      }
    }
    if (props.entryAnimation) {
      props.inlineAnimation = props.entryAnimation;
      state.scopedState[namespace].animations.entry[screenName].hasAnimation = true
      state.scopedState[namespace].animations.entry[screenName][elem.__ref.__id] = {
          visibility: props.visibility ? props.visibility : "visible",
          inlineAnimation: props.entryAnimation,
          onAnimationEnd: props.onAnimationEnd,
          type: type
        };
    }
    
    if (props.entryAnimationF) {
      state.scopedState[namespace].animations.entryF[screenName].hasAnimation = true
      state.scopedState[namespace].animations.entryF[screenName][elem.__ref.__id] = {
          visibility: props.visibility ? props.visibility : "visible",
          inlineAnimation: props.entryAnimationF,
          onAnimationEnd: props.onAnimationEnd,
          type: type
        };
      props.inlineAnimation = props.entryAnimationF;
    }

    if (props.entryAnimationB) {
      state.scopedState[namespace].animations.entryB[screenName].hasAnimation = true
      state.scopedState[namespace].animations.entryB[screenName][elem.__ref.__id] = {
        visibility: props.visibility ? props.visibility : "visible",
        inlineAnimation: props.entryAnimationB,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimation) {
      state.scopedState[namespace].animations.exit[screenName].hasAnimation = true
      state.scopedState[namespace].animations.exit[screenName][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimation,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimationF) {
      state.scopedState[namespace].animations.exitF[screenName].hasAnimation = true
      state.scopedState[namespace].animations.exitF[screenName][elem.__ref.__id] = {
        inlineAnimation: props.exitAnimationF,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    }

    if (props.exitAnimationB) {
      state.scopedState[namespace].animations.exitB[screenName].hasAnimation = true
      state.scopedState[namespace].animations.exitB[screenName][elem.__ref.__id] = {
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
    children.push(domAllImpl(elem.children[i], screenName, VALIDATE_ID, namespace));
  }

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

function hideOldScreenNow(namespace) {
  while(state.scopedState[namespace].hideList.length > 0) {
    var screenName = state.scopedState[namespace].hideList.pop();
    var cb = state.scopedState[namespace].screenHideCallbacks[screenName]
    if(typeof cb == "function") {
      cb();
    }
  }
  while(state.scopedState[namespace].removeList.length > 0) {
    var screenName = state.scopedState[namespace].removeList.pop();
    var cb = state.scopedState[namespace].screenRemoveCallbacks[screenName]
    if(typeof cb == "function") {
      cb();
    }
  }
  if (state.scopedState[namespace].shouldHideCacheRoot){
    state.scopedState[namespace].shouldHideCacheRoot = false
    hideViewInNameSpace(state.scopedState[namespace].cacheRoot, namespace)()
  }
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

exports.callAnimation = callAnimation__

/**
 * Implicit animation logic.
 * 1. If two consecutive screens are runscreen. Call animation on both.
 * 2. If screen is show screen and previous screen is runscreen. Call animation only on showScreen
 * 3. If screen is run screen and previous is show. Call animation on show, run and previous visible run.\
 * animationStack : Array of runscreens where exit animation has not be called
 * animationCache : Array of showscreens.
 */

function callAnimation__ (screenName, namespace, cache) {
  state.scopedState[namespace].activateScreen = false;
  state.scopedState[namespace].activeScreen = screenName;
  if (screenName == state.scopedState[namespace].animations.lastAnimatedScreen)
      return;
  var isRunScreen = state.scopedState[namespace].animations.animationStack.indexOf(screenName) != -1;
  var isShowScreen = state.scopedState[namespace].animations.animationCache.indexOf(screenName) != -1;
  var isLastAnimatedCache = state.scopedState[namespace].animations.animationCache.indexOf(state.scopedState[namespace].animations.lastAnimatedScreen) != -1;
  var topOfStack = state.scopedState[namespace].animations.animationStack[state.scopedState[namespace].animations.animationStack.length - 1];
  var animationArray = []
  if (isLastAnimatedCache){
    animationArray.push({ screenName : state.scopedState[namespace].animations.lastAnimatedScreen + "", tag : "exit"});
    state.scopedState[namespace].hideList.push(state.scopedState[namespace].animations.lastAnimatedScreen);
  }
  if (isRunScreen || isShowScreen) {
    if(isRunScreen) {
      if(topOfStack != screenName) {
        animationArray.push({ screenName : screenName, tag : "entryB"})
        animationArray.push({ screenName : topOfStack, tag : "exitB"})
        while (state.scopedState[namespace].animations.animationStack[state.scopedState[namespace].animations.animationStack.length - 1] != screenName){
          state.scopedState[namespace].animations.animationStack.pop();
        }
      }
    } else {
      animationArray.push({ screenName : screenName, tag : "entry"})
    }
  } else {
    // Newscreen case
    if (cache){
      state.scopedState[namespace].animations.animationCache.push(screenName); // TODO :: Use different data structure. Array does not realy fit the bill.
    } else {
      // new runscreen case call forward exit animation of previous runscreen
      var previousScreen = state.scopedState[namespace].animations.animationStack[state.scopedState[namespace].animations.animationStack.length - 1]
      animationArray.push({ screenName : previousScreen, tag : "exitF"})
      state.scopedState[namespace].hideList.push(previousScreen);
      state.scopedState[namespace].animations.animationStack.push(screenName);
    }
  }
  console.log(namespace, animationArray, false, screenName)
  callAnimation_(namespace, animationArray, false, screenName)
  state.scopedState[namespace].animations.lastAnimatedScreen = screenName;
}

function callAnimation_ (namespace, screenArray, resetAnimation, screenName) {
  window.enableBackpress = false;
  if (window.__OS == "WEB") {
    state.scopedState[namespace].activateScreen = true;
    hideOldScreenNow(namespace);
    return;
  }
  var hasAnimation = false;
  screenArray.forEach(
    function (animationJson) {
      console.log(namespace, animationJson, false, screenName)
      if (state.scopedState[namespace].animations[animationJson.tag] && state.scopedState[namespace].animations[animationJson.tag][animationJson.screenName]) {
        var animationJson = state.scopedState[namespace].animations[animationJson.tag][animationJson.screenName]
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
              Android.updateProperties(JSON.stringify(cmd), getIdFromNamespace(namespace));
            } else {
              Android.runInUI(cmd.runInUI, null);
            }
          } else if (window.__OS == "IOS") {
            Android.runInUI(config, getIdFromNamespace(namespace));
          } else {
            Android.runInUI(webParseParams("linearLayout", config, "set"), getIdFromNamespace(namespace));
          }
        }
      }
    }
  );
  if (!hasAnimation){
    state.scopedState[namespace].activateScreen = true;
    hideOldScreenNow(namespace)
  }
}

function processMapps(namespace) {
  state.scopedState[namespace].mappQueue.forEach( 
    function(payload) {
      payload.payload.fragmentViewGroups[payload.viewGroupTag] = Android.addToContainerList(parseInt(payload.elemId), getIdFromNamespace(namespace));
      JOS.emitEvent(payload.service)("onMerchantEvent")(["process", JSON.stringify(payload.payload)])
    }
  )
}

function executePostProcess(name, namespace, cache) {
  return function() {
    console.log("Hyper was here" , state)
    callAnimation__(name, namespace, cache);
    processMapps(namespace)
    // if (window.__dui_screen && window["afterRender"] && window["afterRender"][window.__dui_screen] && !window["afterRender"][window.__dui_screen].executed) {
    //   for (var tag in window["afterRender"][window.__dui_screen]) {
    //     if (tag === "executed")
    //       continue;
    //     try {
    //       window["afterRender"][window.__dui_screen][tag]()();
    //       window["afterRender"][window.__dui_screen]["executed"] = true;
    //     } catch (err) {
    //       console.warn(err);
    //     }
    //   }
    // }
  };
}

exports.checkAndDeleteFromHideAndRemoveStacks = function (namespace, screenName) {
  try {
    var index = state.scopedState[namespace].hideList.indexOf(screenName)
    if(index != -1) {
      delete state.scopedState[namespace].hideList[index];
    }
    var index = state.scopedState[namespace].removeList.indexOf(screenName)
    if(index != -1) {
      delete state.scopedState[namespace].removeList[index];
    }
  } catch(e) {
    // Ignored this will happen ever first time for each screen
  }
}

exports.setUpBaseState = function (namespace) {
  return function (id) {
    return function () {
      state.scopedState[namespace] = state.scopedState[namespace] || {}
      state.scopedState[namespace].id = id
      var elemRef = createPrestoElement();
      var stackRef = createPrestoElement();
      var cacheRef = createPrestoElement();
      state.scopedState[namespace].root = {
          type: "relativeLayout",
          props: {
            id : elemRef.__id,
            root: "true",
            height: "match_parent",
            width: "match_parent"
          },
          __ref : elemRef,
          children: [
            { type: "relativeLayout"
            , props: {
                id : stackRef.__id,
                root: "true",
                height: "match_parent",
                width: "match_parent"
              }
            , __ref : stackRef
            , children: []
            },
            { type: "relativeLayout"
            , props: {
                id : cacheRef.__id,
                root: "true",
                height: "match_parent",
                width: "match_parent",
                visibility : "gone"
              }
            , __ref : cacheRef
            , children: []
            }
          ]
        };
      state.scopedState[namespace].MACHINE_MAP = {}
      state.scopedState[namespace].screenStack = []
      state.scopedState[namespace].hideList = []
      state.scopedState[namespace].removeList = []
      state.scopedState[namespace].screenCache = []
      state.scopedState[namespace].screenHideCallbacks = {}
      state.scopedState[namespace].screenShowCallbacks = {}
      state.scopedState[namespace].screenRemoveCallbacks = {}
      state.scopedState[namespace].cancelers = {}
      state.scopedState[namespace].stackRoot = stackRef.__id
      state.scopedState[namespace].cacheRoot = cacheRef.__id

      state.scopedState[namespace].animations = {}
      state.scopedState[namespace].animations.entry = {}
      state.scopedState[namespace].animations.exit = {}
      state.scopedState[namespace].animations.entryF = {}
      state.scopedState[namespace].animations.exitF = {}
      state.scopedState[namespace].animations.entryB = {}
      state.scopedState[namespace].animations.exitB = {}
      state.scopedState[namespace].animations.animationStack = []
      state.scopedState[namespace].animations.animationCache = []
      state.scopedState[namespace].animations.lastAnimatedScreen = ""
      state.scopedState[namespace].registeredEvents = {}
      state.scopedState[namespace].shouldHideCacheRoot = false
      state.scopedState[namespace].mappQueue = []
      
      
      if (window.__OS == "ANDROID") {
        if (typeof Android.getNewID == "function") { 
          // TODO change this to mystique version check.
          // TODO add mystique reject / alternate handling, when required version is not present
          Android.render(JSON.stringify(domAll(state.scopedState[namespace].root, "base", namespace)), null, "false", (id ? id : null));
        } else {
          Android.render(JSON.stringify(domAll(state.scopedState[namespace].root), "base", namespace), null);
        }
      } else if (window.__OS == "WEB") {
        Android.Render(domAll(state.scopedState[namespace].root, "base", namespace), null, (id ? id : undefined));
      } else {
        Android.render(domAll(state.scopedState[namespace].root, "base", namespace), null, (id ? id : undefined)); // Add support for iOS
      }
    }
  }
}

exports.insertDom = function(namespace, name, dom, cache) {
  if(!state.scopedState[namespace]) {
    console.error("Call initUI for namespace :: " + namespace + "before triggering run/show screen")
    return;
  }

  state.scopedState[namespace].animations.entry[name] = {}
  state.scopedState[namespace].animations.exit[name] = {}
  state.scopedState[namespace].animations.entryF[name] = {}
  state.scopedState[namespace].animations.exitF[name] = {}
  state.scopedState[namespace].animations.entryB[name] = {}
  state.scopedState[namespace].animations.exitB[name] = {}
  state.scopedState[namespace].root.children.push(dom);
  if (dom.props && dom.props.hasOwnProperty('id') && (dom.props.id).toString().trim()) {
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  } else {
    dom.__ref = createPrestoElement();
  }
  if(dom.props) {
    dom.props.root = true
  }
  var rootId = cache ? state.scopedState[namespace].cacheRoot : state.scopedState[namespace].stackRoot
  var length = cache ? state.scopedState[namespace].screenCache.length : state.scopedState[namespace].screenStack.length
  // TODO implement cache limit later
  state.scopedState[namespace].screenHideCallbacks[name] = hideViewInNameSpace(dom.__ref.__id, namespace)
  state.scopedState[namespace].screenShowCallbacks[name] = showViewInNameSpace(dom.__ref.__id, namespace)
  state.scopedState[namespace].screenRemoveCallbacks[name] = removeViewFromNameSpace(namespace, dom.__ref.__id)
  var callback = callbackMapper.map(executePostProcess(name, namespace, cache))
  if (window.__OS == "ANDROID") {
    Android.addViewToParent(
      rootId + "",
      JSON.stringify(domAll(dom, name, namespace)),
      length - 1,
      callback,
      null,
       getIdFromNamespace(namespace)
    );
  } else {
    Android.addViewToParent(
      rootId, 
      domAll(dom, name, namespace), 
      length - 1, 
      callback, 
      null, 
      getIdFromNamespace(namespace)
      );
  }
}

exports.storeMachine = function (dom, name, namespace) {
  console.log("HYPER 1",  state)
  state.scopedState[namespace].MACHINE_MAP[name] = dom;
  console.log("HYPER 2",  state)
}

exports.getLatestMachine = function (name, namespace) {
  return state.scopedState[namespace].MACHINE_MAP[name];
}

exports.isInStack = function (name, namespace) {
  // Added || false to return false when value is undefined
  try {
    return state.scopedState[namespace].screenStack.indexOf(name) != -1
  } catch (e) {
    console.error( "Call initUI with for namespace :: " + namespace , e );
  }
  return false
}

exports.isCached = function (name, namespace) {
  // Added || false to return false when value is undefined
  try {
    return state.scopedState[namespace].screenCache.indexOf(name) != -1
  } catch (e) {
    console.error( "Call initUI with for namespace :: " + namespace , e );
  }
  return false
}

exports.cancelExistingActions = function (name, namespace) {
  // Added || false to return false when value is undefined
  if(state.scopedState[namespace] && state.scopedState[namespace].cancelers && typeof state.scopedState[namespace].cancelers[name] == "function") {
    state.scopedState[namespace].cancelers[name]();
  }
}

exports.saveCanceller = function (name, namespace, canceller) {
  // Added || false to return false when value is undefined
  if(state.scopedState[namespace] && state.scopedState[namespace].cancelers) {
    state.scopedState[namespace].cancelers[name] = canceller;
  }
}

exports.terminateUIImpl = function (namespace) {
  if(window.__OS == "ANDROID" 
      && Android.runInUI 
      && state.scopedState[namespace] 
      && state.scopedState[namespace].root 
      && state.scopedState[namespace].root.__ref
      && state.scopedState[namespace].root.__ref.__id
      ) {
    Android.runInUI(";set_v=ctx->findViewById:i_" + state.scopedState[namespace].root.__ref.__id + ";set_p=get_v->getParent;get_p->removeView:get_v;", null);
  } else if ( JOS 
      && JOS.parent 
      && JOS.parent != "java" 
      && state.scopedState[namespace] 
      && state.scopedState[namespace].root 
      && state.scopedState[namespace].root.__ref
      && state.scopedState[namespace].root.__ref.__id
      ) {
      Android.removeView(state.scopedState[namespace].root.__ref.__id, getIdFromNamespace(namespace));
  } else {
    Android.runInUI(["removeAllUI"], getIdFromNamespace(namespace));
  }
  delete state.scopedState[namespace] 
}

exports.setToTopOfStack = function (namespace, screenName) {
  try {
    if(state.scopedState[namespace].screenStack.indexOf(screenName) != -1) {
      var index = state.scopedState[namespace].screenStack.indexOf(screenName)
      var removedScreens = state.scopedState[namespace].screenStack.splice(index + 1)
      state.scopedState[namespace].removeList = state.scopedState[namespace].removeList.concat(removedScreens)
    } else {
      state.scopedState[namespace].screenStack.push(screenName)
    }

  } catch (e) {
    console.error("Call Init UI for namespace :: ", namespace, e)
  }
}

exports.makeScreenVisible = function (namespace, name) {
  try {
    var cb = state.scopedState[namespace].screenShowCallbacks[name];
    if(typeof cb == "function") {
      cb()
    }
  } catch(e) {
    console.log("Call InitUI first for namespace ", namespace, e)
  }
}

exports.addToCachedList = function (namespace, screenName) {
  try {
    if(!state.scopedState[namespace].screenCache.indexOf(screenName)!= -1) {
      state.scopedState[namespace].screenCache.push(screenName);
    }
  } catch (e) {
    console.log("Call InitUI first for namespace ", namespace, e)
  }
}

exports.addChild = function (namespace) {
  return function (child, parent, index) {
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
        null,
        getIdFromNamespace(namespace)
      );
    } else
      Android.addViewToParent(
        parent.__ref.__id,
        domAll(child),
        index,
        null,
        null,
        getIdFromNamespace(namespace)
      );
  }
}

exports.addProperty = function (namespace) {
  return function (key, val, obj) {
    addAttribute(obj, {value0: key, value1: val}, namespace)
  }
};

function addAttribute(element, attribute, namespace) {
  // console.log("add attr :", attribute);
  element.props[attribute.value0] = attribute.value1;
  applyProp(element, attribute, true, namespace);
}

function applyProp(element, attribute, set, namespace) {
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
      Android.updateProperties(JSON.stringify(cmd),  getIdFromNamespace(namespace));
    } else {
      Android.runInUI(cmd.runInUI, null);
    }
  } else if (window.__OS == "IOS") {
    Android.runInUI(prop,  getIdFromNamespace(namespace));
  } else {
    Android.runInUI(webParseParams("linearLayout", prop, "set"),getIdFromNamespace(namespace));
  }
  // Android.runInUI(parseParams("linearLayout", prop, "set"));
}

exports.replaceView = function (namespace) {
  return function (element, removedProps) {
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
      Android.replaceView(
          JSON.stringify(rep)
        , element.__ref.__id
        , getIdFromNamespace(namespace)
        );
    } else {
      Android.replaceView(rep, element.__ref.__id, getIdFromNamespace(namespace));
    }
    if (removedProps != null && removedProps.length >0 && removedProps.indexOf("handler/afterRender") != -1){
      if (window["afterRender"] && window["afterRender"][window.__dui_screen]) {
        delete window["afterRender"][window.__dui_screen][element.__ref.__id];
      }
    }
  }
} 

exports.cancelBehavior = function (ty) {
  var canceler = window.__CANCELER[ty];
  canceler();
}

exports.createPrestoElement = createPrestoElement;

exports.moveChild = function(namespace) {
  return function (child, parent, index) {
    Android.moveView(child.__ref.__id, index, getIdFromNamespace(namespace));
  }
}

exports.removeChild = function(namespace) {
  return function removeChild(child, parent, index) {
    Android.removeView(child.__ref.__id,  getIdFromNamespace(namespace));
  }
}

exports.updateProperty = function (namespace) {
  return function (key, val, element) {
    // console.log("update attr :", attribute);
    attribute = {value0: key, value1: val}
    element.props[attribute.value0] = attribute.value1;
    applyProp(element, attribute, false, namespace);
  }
};

exports.setManualEvents = function (namespace) {
  return function(screen) {
    return function(eventName) {
      return function(callbackFunction) {
        var screenName = screen;
        // function was getting cleared when placed outside
        var isDefined = function(val){
          return (typeof val !== "undefined");
        }
        try {
          state.scopedState[namespace].registeredEvents[eventName] = 
            isDefined(state.scopedState[namespace].registeredEvents[eventName]) 
              ? state.scopedState[namespace].registeredEvents[eventName] 
              : {};
          state.scopedState[namespace].registeredEvents[eventName][screenName] = callbackFunction;
        } catch (e) {
          console.log("Call init UI first", e)
        }
      }
    }
  }
}

exports.fireManualEvent = function (eventName) {
  return function (payload) {
    return function() {
      for (var key in state.scopedState) {
        if(state.scopedState[key].registeredEvents && state.scopedState[key].registeredEvents.hasOwnProperty(eventName)) {
          var screenName = state.scopedState[key].activeScreen
          var isNotAnimating = state.scopedState[key].activateScreen
          if(isNotAnimating && screenName && typeof state.scopedState[key].registeredEvents[eventName][screenName] == "function")
            state.scopedState[key].registeredEvents[eventName][screenName](payload);
        }
      }
    }
  }
};

exports.makeCacheRootVisible = function(namespace) {
  state.scopedState[namespace].shouldHideCacheRoot = false;
  showViewInNameSpace(state.scopedState[namespace].cacheRoot, namespace)();
}

exports.hideCacheRootOnAnimationEnd = function(namespace) {
  state.scopedState[namespace].shouldHideCacheRoot = true;
}