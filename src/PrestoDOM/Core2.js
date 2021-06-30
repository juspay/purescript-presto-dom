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


function createAndroidWrapper () {
  if(window.__OS == "ANDROID" && window.Android && typeof window.Android.addToContainerList != "function") {
    var android = {}
    for(var i in window.Android) {
      android[i] = window.Android[i].bind(window.Android);
    }
    android.removeView = function(id, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.removeView(id);
    }
    android.updateProperties = function (cmd, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.updateProperties(cmd);
    }
    android.addToContainerList = function(id, namespace){
      // Check if JOS has an id store from another m-app
      // Add id, and get a return string identifier
      // Use the same to decide between render and and addview to parent
      if(typeof top.addToContianerList != "function" ){
        top.fragments = top.fragments || {};
        var generateUUID = function() {
          function s4() {
                  return Math.floor((1 + Math.random()) * 0x10000)
                          .toString(16)
                          .substring(1);
          }
          return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
                  s4() + '-' + s4() + s4() + s4();
        }
        top.addToContainerList = function(id, namespace) {
          // Namespace not needed, for cases where we do not have merchant fragment
          var uuid = generateUUID()
          top.fragments[uuid] = id;
          return uuid;
        }
      }
      return top.addToContainerList(id, namespace);
    }
    android.render = function(domString, snd, trd, nsps) {
      // Query JOS if ns is available.
      // if null call render
      // if not null find namespace and call AddViewToParent
      top.fragments = top.fragments || {}
      if(nsps == null || nsps == undefined || typeof top.fragments[nsps] != "number") {
        return Android.render(domString, snd, trd)
      }
      var rootId = top.fragments[nsps] + "";
      return Android.addViewToParent(rootId, domString, 0, null, null)
    }
    android.addViewToParent = function(rootId, domString, position, callback, fth, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.addViewToParent(rootId, domString, position, callback, fth)
    }
    android.replaceView = function(domString, id, ns) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.replaceView(domString, id);
    }
    android.moveView = function(id, index, ns) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.moveView(id, index);
    }
    return android
  } else {
    return window.Android
  }
}

const AndroidWrapper = createAndroidWrapper()

const state = {
  scopedState : {}
, fragments : {}
, fragmentIdMap : {}
, listViewKeys : {}
, listViewAnimationKeys : {}
, counter: 0
, bitMap: {}
}

var getIdFromNamespace = function(namespace) {
  var ns = state.scopedState[namespace].id ? state.scopedState[namespace].id : undefined
  if(window.__OS == "ANDROID")
    ns = state.scopedState[namespace].id ? state.scopedState[namespace].id : null;
  return ns;
}

exports.getIdFromNamespace = function(namespace) {
  return function() {
    return getIdFromNamespace(id)
  }
};

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
    AndroidWrapper.removeView(id, getIdFromNamespace(namespace))
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
      AndroidWrapper.runInUI(cmd.runInUI, null);
    } else if (window.__OS == "IOS") {
      AndroidWrapper.runInUI(prop, getIdFromNamespace(namespace));
    } else  {
      AndroidWrapper.runInUI(webParseParams("relativeLayout", prop, "set"), getIdFromNamespace(namespace));
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
      AndroidWrapper.runInUI(cmd.runInUI, null);
    } else if (window.__OS == "IOS") {
      AndroidWrapper.runInUI(prop, getIdFromNamespace(namespace));
    } else {
      AndroidWrapper.runInUI(webParseParams("relativeLayout", prop, "set"), getIdFromNamespace(namespace));
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
  var obj = parsePropsImpl(elem, screenName, VALIDATE_ID, namespace);
  obj = obj.dom;
  var type = obj.type;
  var props = obj.props;
  var children = [];

  for (var i = 0; i < elem.children.length; i++) {
    children.push(domAllImpl(elem.children[i], screenName, VALIDATE_ID, namespace));
  }

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

exports.parseProps = parsePropsImpl;

function parsePropsImpl(elem, screenName, VALIDATE_ID, namespace) {
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

  if(typeof props.listItem == "object") {
    state.listViewKeys[elem.__ref.__id] = props.listItem.keyPropMap
    state.listViewAnimationKeys[elem.__ref.__id] = props.listItem.animationIdMap
    console.log("keyPropMap", state.listViewKeys[elem.__ref.__id], props.listItem, props.listData)
    props.listItem = JSON.stringify({itemView : props.listItem.itemView, holderViews : props.listItem.holderViews})
  }

  if(type == "microapp") {
    // Add to queue of m-app ui to be triggered.
    // Queue to be fired on callback of AddViewToParent
    var mappBootData = {
      payload : props.payload
    , viewGroupTag : props.viewGroupTag || "main"
    , requestId : elem.requestId
    , service : elem.service
    , elemId : elem.__ref.__id
    , callback : props.onMicroappResponse
    }
    if (state.scopedState[namespace] && state.scopedState[namespace].mappQueue) {
      state.scopedState[namespace].mappQueue.push(mappBootData);
    }
    else {
      console.warn("Namespace", namespace);
      console.warn("state.scopedState", state.scopedState);
    }
    type = "relativeLayout"
  }
  if (window.__OS !== "WEB") {
    if(props.hasOwnProperty("afterRender")) {
      state.scopedState[namespace].afterRenderFunctions[screenName] = state.scopedState[namespace].afterRenderFunctions[screenName] || []
      state.scopedState[namespace].afterRenderFunctions[screenName].push(props.afterRender)
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
          hideOldScreenNow(namespace, screenName);
          callbackFunction(event);
        };
        props.onAnimationEnd = updatedCallback;
      } else {
        props.onAnimationEnd = function() {
            state.scopedState[namespace].activateScreen = true;
            hideOldScreenNow(namespace, screenName);
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
  if (__OS == "WEB" && props.onResize) {
    window.__resizeEvent = props.onResize;
  }
  props.id = elem.__ref.__id;
  return {dom : { type : type, props:props, children:elem.children, parentType : elem.parentType, __ref : elem.__ref}, ids : VALIDATE_ID}
}

function hideOldScreenNow(namespace, screenName) {
  var sn = screenName;
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
  if(state.scopedState[namespace].shouldReplayCallbacks[sn]) {
    state.scopedState[namespace].shouldReplayCallbacks[sn] = false;
    var cbs = state.scopedState[namespace].fragmentCallbacks[sn] || []
    cbs.forEach (function(x) {
      x.callback(x.payload)
    })
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
  if (screenName == state.scopedState[namespace].animations.lastAnimatedScreen) {
    state.scopedState[namespace].activateScreen = true;
    return;
  }
  var isRunScreen = state.scopedState[namespace].animations.animationStack.indexOf(screenName) != -1;
  var isShowScreen = state.scopedState[namespace].animations.animationCache.indexOf(screenName) != -1;
  var isLastAnimatedCache = state.scopedState[namespace].animations.animationCache.indexOf(state.scopedState[namespace].animations.lastAnimatedScreen) != -1;
  var topOfStack = state.scopedState[namespace].animations.animationStack[state.scopedState[namespace].animations.animationStack.length - 1];
  var animationArray = []
  if (isLastAnimatedCache) {
    animationArray.push({ screenName : state.scopedState[namespace].animations.lastAnimatedScreen + "", tag : "exit"});
    state.scopedState[namespace].hideList.push(state.scopedState[namespace].animations.lastAnimatedScreen);
  }
  if (isRunScreen || isShowScreen) {
    if(isRunScreen) {
      if(topOfStack != screenName) {
        animationArray.push({ screenName : screenName, tag : "entryB"})
        animationArray.push({ screenName : topOfStack, tag : "exitB"})
        while (state.scopedState[namespace].animations.animationStack[state.scopedState[namespace].animations.animationStack.length - 1] != screenName) {
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
  callAnimation_(namespace, animationArray, false, screenName)
  state.scopedState[namespace].animations.lastAnimatedScreen = screenName;
}

function callAnimation_ (namespace, screenArray, resetAnimation, screenName) {
  window.enableBackpress = false;
  if (window.__OS == "WEB") {
    state.scopedState[namespace].activateScreen = true;
    hideOldScreenNow(namespace, screenName);
    return;
  }
  var hasAnimation = false;
  screenArray.forEach(
    function (animationJson) {
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
            if (AndroidWrapper.updateProperties) {
              AndroidWrapper.updateProperties(JSON.stringify(cmd), getIdFromNamespace(namespace));
            } else {
              AndroidWrapper.runInUI(cmd.runInUI, null);
            }
          } else if (window.__OS == "IOS") {
            AndroidWrapper.runInUI(config, getIdFromNamespace(namespace));
          } else {
            AndroidWrapper.runInUI(webParseParams("linearLayout", config, "set"), getIdFromNamespace(namespace));
          }
        }
      }
    }
  );
  if (!hasAnimation){
    state.scopedState[namespace].activateScreen = true;
    hideOldScreenNow(namespace, screenName)
  }
}

function processMapps(namespace, nam) {
  setTimeout(function () {
    var cachedObject = (state.scopedState[namespace].mappQueue || []).pop();
    while (cachedObject) {
      var fragId = AndroidWrapper.addToContainerList(parseInt(cachedObject.elemId), getIdFromNamespace(namespace));
      cachedObject.fragId = fragId;
      var cb = function (code) {
        return function (message) {
          return function () {
            var test = JSON.parse(message)
            if(!test.stopAtDom) {
              state.scopedState[namespace].fragmentCallbacks[nam] = state.scopedState[namespace].fragmentCallbacks[nam] || [];
              state.scopedState[namespace].fragmentCallbacks[nam].push({
                payload: {
                  code: code,
                  message: message,
                },
                callback: this.object.callback
              });
              if (typeof this.object.callback == "function")
                  this.object.callback({
                  code: code,
                  message: message,
                  elemId : this.object.fragId
                });
              else
                console.log("Mapp response", code, message)
            } else {
                try {
                  var plds = state.scopedState[namespace].fragmentCallbacks[nam] || [];
                  state.scopedState[namespace].fragmentCallbacks[nam] = plds.filter(function(x) {
                    return !(test.id == x.payload.elemId)
                  })
                } catch (e) {
                  console.log("flushFragmentCallbacks Error => ", e)
                }
            }
          }.bind({
            object: this.object
          });
        }.bind({
          object: this.object
        });
      }.bind({
        object: cachedObject
      });

      var p = JSON.parse(cachedObject.payload);
      p.fragmentViewGroups = p.fragmentViewGroups || {};
      p.fragmentViewGroups[cachedObject.viewGroupTag] = fragId;
      state.fragmentIdMap[cachedObject.requestId] = p.fragmentViewGroups[cachedObject.viewGroupTag];
      var x = {
        service: cachedObject.service,
        requestId: cachedObject.requestId,
        payload: p
      };
      JOS.emitEvent(x.service)("onMerchantEvent")(["process", JSON.stringify(x)])(cb)();
      cachedObject = state.scopedState[namespace].mappQueue.pop();
    }
  }, 32);
}

function triggerAfterRender(namespace, screenName) {
  while(state.scopedState[namespace].afterRenderFunctions[screenName] && typeof state.scopedState[namespace].afterRenderFunctions[screenName][0] == "function") {
    state.scopedState[namespace].afterRenderFunctions[screenName].pop()();
  }
}

function executePostProcess(nam, namespace, cache) {
  return function() {
    callAnimation__(nam, namespace, cache);
    processMapps(namespace, nam);
    triggerAfterRender(namespace, nam);
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
      console.log("InitUI called for ", namespace, id)
      if(typeof state.scopedState[namespace] != "undefined") {
        terminateUIImpl()(namespace);
      }
      state.scopedState[namespace] = state.scopedState[namespace] || {}
      state.scopedState[namespace].id = id
      state.fragments[id || "null"] = namespace;
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
                height: "match_parent",
                width: "match_parent"
              }
            , __ref : stackRef
            , children: []
            },
            { type: "relativeLayout"
            , props: {
                id : cacheRef.__id,
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
      state.scopedState[namespace].fragmentCallbacks = {}
      state.scopedState[namespace].shouldReplayCallbacks = {}
      state.scopedState[namespace].eventIOs = {}
      state.scopedState[namespace].afterRenderFunctions = {}
      
      if (window.__OS == "ANDROID") {
        if (typeof AndroidWrapper.getNewID == "function") { 
          // TODO change this to mystique version check.
          // TODO add mystique reject / alternate handling, when required version is not present
          AndroidWrapper.render(JSON.stringify(domAll(state.scopedState[namespace].root, "base", namespace)), null, "false", (id ? id : null));
        } else {
          AndroidWrapper.render(JSON.stringify(domAll(state.scopedState[namespace].root), "base", namespace), null);
        }
      } else if (window.__OS == "WEB") {
        AndroidWrapper.Render(domAll(state.scopedState[namespace].root, "base", namespace), null, getIdFromNamespace(namespace)); // Add support for Web
      } else {
        AndroidWrapper.render(domAll(state.scopedState[namespace].root, "base", namespace), null, (id ? id : undefined)); // Add support for iOS
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
  return {
      rootId : window.__OS == "ANDROID" ? rootId + "" : rootId
    , dom : dom
    //, name, namespace
    , length : length -1
    , callback : callback
    , id : getIdFromNamespace(namespace)
    }
}

exports.addViewToParent = function (insertObject) {
  var dom = insertObject.dom
  AndroidWrapper.addViewToParent(
    insertObject.rootId,
    window.__OS == "ANDROID" ? JSON.stringify(dom) : dom,
    insertObject.length,
    insertObject.callback,
    null,
    insertObject.id
  );
}

exports.storeMachine = function (dom, name, namespace) {
  state.scopedState[namespace].MACHINE_MAP[name] = dom;
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
  state.scopedState[namespace] = state.scopedState[namespace] || {} 
  state.scopedState[namespace].cancelers = state.scopedState[namespace].cancelers || {}
  if(state.scopedState[namespace] && state.scopedState[namespace].cancelers) {
    state.scopedState[namespace].cancelers[name] = canceller;
  }
}
exports.terminateUIImpl = terminateUIImpl();
exports.terminateUIImplWithCallback = terminateUIImpl;
function terminateUIImpl (callback) {
  return function(namespace) {
    if(callback) {
      callback(-1)(JSON.stringify({
        stopAtDom : true,
        id : state.scopedState[namespace].id
      }))()
    }
    window.__usedIDS = undefined;
    if(window.__OS == "ANDROID" 
    && AndroidWrapper.runInUI 
    && state.scopedState[namespace] 
    && state.scopedState[namespace].root 
    && state.scopedState[namespace].root.__ref
    && state.scopedState[namespace].root.__ref.__id
    ) {
      AndroidWrapper.runInUI(";set_v=ctx->findViewById:i_" + state.scopedState[namespace].root.__ref.__id + ";set_p=get_v->getParent;get_p->removeView:get_v;", null);
    } else if ( JOS 
      && JOS.parent 
      && JOS.parent != "java" 
      && state.scopedState[namespace] 
      && state.scopedState[namespace].root 
      && state.scopedState[namespace].root.__ref
      && state.scopedState[namespace].root.__ref.__id
      ) {
        AndroidWrapper.removeView(state.scopedState[namespace].root.__ref.__id, getIdFromNamespace(namespace));
      } else {
        AndroidWrapper.runInUI(["removeAllUI"], getIdFromNamespace(namespace));
      }
      delete state.scopedState[namespace] 
    }
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
    if(!(state.scopedState[namespace].screenCache.indexOf(screenName)!= -1)) {
      state.scopedState[namespace].screenCache.push(screenName);
    }
  } catch (e) {
    console.log("Call InitUI first for namespace ", namespace, e)
  }
}

exports.addChildImpl = function (namespace) {
  return function(screenName) {
    return function (child, parent, index) {
      if (child.type == null) {
        console.warn("child null");
      }
      var cb = callbackMapper.map(function(){
            if (window.__OS ===  "WEB"){
              setTimeout(function(){ processMapps(namespace, screenName)},500)
            } else {
              processMapps(namespace, screenName)
            }
          }
         )
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
      }
      if(child.props && (!child.props.id) && child.__ref) {
        child.props.id = child.__ref.__id
      }
      return { rootId : window.__OS == "ANDROID" ? parent.__ref.__id + "" : parent.__ref.__id
      , dom : child
      , length : index
      , callback : cb
      , id :  getIdFromNamespace(namespace)
      }
    }
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
  var prop = {};
  prop[attribute.value0] = attribute.value1;
  applyProps(element, prop, set, namespace)
}

function applyProps(element, prop, set, namespace) {
  prop.id =element.__ref.__id
  if (
    prop.hasOwnProperty("focus") &&
    prop.focus === false &&
    window.__OS == "ANDROID"
  ) {
    delete prop.focus;
  }

  if (window.__OS == "ANDROID") {
    var cmd = cmdForAndroid(prop, set, element.type);
    if (AndroidWrapper.updateProperties) {
      AndroidWrapper.updateProperties(JSON.stringify(cmd),  getIdFromNamespace(namespace));
    } else {
      AndroidWrapper.runInUI(cmd.runInUI, null);
    }
  } else if (window.__OS == "IOS") {
    AndroidWrapper.runInUI(prop, getIdFromNamespace(namespace));
  } else {
    AndroidWrapper.runInUI(webParseParams("linearLayout", prop, "set"),getIdFromNamespace(namespace));
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
      AndroidWrapper.replaceView(
          JSON.stringify(rep)
        , element.__ref.__id
        , getIdFromNamespace(namespace)
        );
    } else {
      AndroidWrapper.replaceView(rep, element.__ref.__id, getIdFromNamespace(namespace));
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
    AndroidWrapper.moveView(child.__ref.__id, index, getIdFromNamespace(namespace));
  }
}

exports.removeChild = function(namespace) {
  return function removeChild(child, parent, index) {
    AndroidWrapper.removeView(child.__ref.__id,  getIdFromNamespace(namespace));
  }
}
exports.updatePropertiesImpl = function (namespace) {
  return function (props, el) {
    for(var key in props) {
      el.props[key] = props[key];
    }
    // TODO evaluate all the set = true / false logic
    // Looks wrong
    applyProps(el, props, false, namespace)
  }
}

exports.setManualEvents = setManualEvents;

function setManualEvents (namespace) {
  return function(screen) {
    return function(eventName) {
      return function(callbackFunction) {
        return function() {
          var screenName = screen;
          // function was getting cleared when placed outside
          var isDefined = function(val){
            return (typeof val !== "undefined");
          }
          try {
            state.scopedState[namespace] = state.scopedState[namespace] || {}
            state.scopedState[namespace].registeredEvents = state.scopedState[namespace].registeredEvents || {}
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
}

exports.fireManualEvent = fireManualEvent()

function fireManualEvent (namespace, nam) {
  return function (eventName) {
    return function (payload) {
      return function() {
        var screenName = (state.scopedState[namespace] || {}).activeScreen
        if(namespace && (nam == screenName || !nam)) {
          if(state.scopedState[namespace].registeredEvents && state.scopedState[namespace].registeredEvents.hasOwnProperty(eventName)) {
            if(screenName && typeof state.scopedState[namespace].registeredEvents[eventName][screenName] == "function")
              state.scopedState[namespace].registeredEvents[eventName][screenName](payload);
          }
          return;
        }
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
}

exports.makeCacheRootVisible = function(namespace) {
  state.scopedState[namespace].shouldHideCacheRoot = false;
  showViewInNameSpace(state.scopedState[namespace].cacheRoot, namespace)();
}

exports.hideCacheRootOnAnimationEnd = function(namespace) {
  state.scopedState[namespace].shouldHideCacheRoot = true;
}

exports.setControllerStates = function(namespace) {
  return function (screenName) {
    return function () {
      state.scopedState[namespace] = state.scopedState[namespace] || {}
      state.scopedState[namespace].activeScreen = screenName;
      state.scopedState[namespace].activateScreen = true;
    }
  }
}

exports["replayFragmentCallbacks'"] = function (namespace) {
  return function (nam) {
    return function (push) {
      return function() {
        try {
          state.scopedState[namespace].shouldReplayCallbacks[nam] = true
          if(window.__OS == "WEB") {
            (state.scopedState[namespace].fragmentCallbacks[nam] || []).forEach (function(x) {
              x.callback(x.payload)
            })
          }
        }
        catch (e) {
          console.log("Replay fragment Error => ", e)
        }
        return function() {
          state.scopedState[namespace].shouldReplayCallbacks[nam] = false
        }
      }
    }
  }
}
exports.getAndSetEventFromState = function(namespace, screenName, def) {
  state.scopedState[namespace] = state.scopedState[namespace] || {}
  state.scopedState[namespace].eventIOs = state.scopedState[namespace].eventIOs || {}
  state.scopedState[namespace].eventIOs[screenName] = state.scopedState[namespace].eventIOs[screenName] || def();
  return state.scopedState[namespace].eventIOs[screenName];
}

exports.processEventWithId = function (fragmentId) {
  var ns = state.fragments[fragmentId];
  if(ns)
    return fireManualEvent(ns)("update");
  else
    return function() { return function() {}}
}

exports.updateMicroAppPayloadImpl = function (payload, element, isPatch) {
  element.props.payload = payload
  if(isPatch) {
    var payload = JSON.parse( payload || {})
    payload.fragmentViewGroups = {}
    payload.fragmentViewGroups[element.props.viewGroupTag || "main"] = state.fragmentIdMap[element.requestId]
    var x = {
      service : element.service
    , requestId : element.requestId
    , payload : payload
    }
    var cb = function(){return function(){ return function(){ /* Ignored */ }}}
    setTimeout( function() {
      JOS.emitEvent(x.service)("onMerchantEvent")(["update", JSON.stringify(x)])(cb)();
      }, 32); 
  }
}

exports.incrementPatchCounter = function(namespace) {
  return function(screenName) {
    return function() {
      window.zzz = state.patchState;
      state.patchState = state.patchState || {}
      state.patchState[namespace] = state.patchState[namespace] || {}
      state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
      state.patchState[namespace][screenName].counter = state.patchState[namespace][screenName].counter || 0
      state.patchState[namespace][screenName].counter++;
    }
  }
}
exports.decrementPatchCounter = function(namespace) {
  return function(screenName) {
    return function () {
      state.patchState = state.patchState || {}
      state.patchState[namespace] = state.patchState[namespace] || {}
      state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
      state.patchState[namespace][screenName].counter = state.patchState[namespace][screenName].counter || 1
      if(state.patchState[namespace][screenName].counter > 0) {
        state.patchState[namespace][screenName].counter--;
      }
      if(state.patchState[namespace][screenName].counter === 0 && state.patchState[namespace][screenName].active) {
        window.abcd = Date.now();
        triggerPatchQueue(namespace, screenName)
      }
    }
  }
}

function triggerPatchQueue(namespace, screenName) {
  state.patchState[namespace][screenName].active = false;
  var nextPatch = state.patchState[namespace][screenName].queue.shift();
  if(typeof nextPatch == "function") {
    window.abc = Date.now();
    nextPatch();
  } else {
    state.patchState[namespace][screenName].started = false;
  }
}

exports.addToPatchQueue = function(namespace) {
  return function(screenName) {
    return function(patchFn) {
      return function () {
        state.patchState = state.patchState || {}
        state.patchState[namespace] = state.patchState[namespace] || {}
        state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
        state.patchState[namespace][screenName].queue = state.patchState[namespace][screenName].queue || []
        state.patchState[namespace][screenName].queue.push(patchFn);
        if(!state.patchState[namespace][screenName].started) {
          state.patchState[namespace][screenName].started = true;
          triggerPatchQueue(namespace, screenName);
        }
      }
    }
  }
} 

exports.setPatchToActive = function(namespace) {
  return function(screenName) {
    return function () {
      state.patchState = state.patchState || {}
      state.patchState[namespace] = state.patchState[namespace] || {}
      state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
      if(state.patchState[namespace][screenName].counter > 0) {
        state.patchState[namespace][screenName].active = true;
      } else {
        window.abcd = Date.now();
        triggerPatchQueue(namespace, screenName)
      }
    }
  }
}

exports.parseParams = function (a,b, c) {
  // ADD OS CHECK
  if (window.__OS === "WEB") {
    return webParseParams(a,b,c);
  } else if (window.__OS == "IOS") {
    return iOSParseParams(a,b,c);
  } else {
    return parseParams(a,b,c);
  }
}

function getBit(propertyName) {
	if (!state.bitMap[propertyName]) {
		const value = (state.counter >= 32) ? propertyName : ++state.counter;
		state.bitMap[propertyName] = 1 << value;
	}
	return state.bitMap[propertyName];
}

function mapName(key, propertyName) {
	const propBitValue = getBit(propertyName);
	if (typeof key === "string" || typeof propBitValue === "string") {
		return "" + key + propBitValue;
	}
	return key | propBitValue;
}

function createAnimationObject(animation) {
	const animObj = {};
	var key = 0;
	for (var i = 0; i < animation.length; i++) {
		const tuple = animation[i];
		key = mapName(key, tuple.value0);
		animObj[tuple.value0] = tuple.value1;
	}
	animObj.name = key;
	return animObj;
}

exports.getListDataCommands = function (listData, element) {
  var x = ["background", "imageUrl", "visibility", "fontStyle", "textSize", "packageIcon", "alpha", "text", "color", "onClick"]
  var y = [];
  var keyPropMap = state.listViewKeys[element.__ref.__id]
  var animPropMap = state.listViewAnimationKeys[element.__ref.__id]
  var final = [];
  for(var j = 0; j < listData.length; ++j) {
  var item = {};
  for(var id in keyPropMap) {
      var ps = {}
      var backMap = {runInUI : "runInUI" + id}
      for(var prop in keyPropMap[id]) {
      if(x.indexOf(keyPropMap[id][prop]) != -1) {
          item[prop] = listData[j][prop]; 
          continue
      }
      ps[keyPropMap[id][prop]] = listData[j][prop];
      backMap[keyPropMap[id][prop]] = prop;
      }
      if(animPropMap.hasOwnProperty(id)) {
        var animations = []
        for(var anim in animPropMap[id]) {
          if(listData[j][anim]) {
            animations = animations.concat(animPropMap[id][anim])
          }
        }
        ps.inlineAnimation = JSON.stringify( animations.map(createAnimationObject))
        y.push(id);
        backMap.inlineAnimation = "inlineAnimation" + id;
      }
      if(window.__OS == "ANDROID") {
        // TODO add cross platform support
        ps = exports.parseParams("linearLayout", ps, "get")
      }
      ps.runInUI = (ps.runInUI || "")
      if(ps.runInUI == "")
          delete ps.runInUI;
      for(var prop in ps) {
          item[backMap[prop]] = ps[prop];
      }
  }
  for(var id in animPropMap) {
    if(y.indexOf(id) == -1) {
      var animations = []
      for(var anim in animPropMap[id]) {
        if(listData[j][anim]) {
          animations = animations.concat(animPropMap[id][anim])
        }
      }
      item["inlineAnimation" + id] = JSON.stringify( animations.map(createAnimationObject))
    }
  }
  final.push(item);
  }
  console.log("final", final);
  return JSON.stringify(final)
}