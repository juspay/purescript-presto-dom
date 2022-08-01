const prestoUI = require("presto-ui");
const prestoDayum = prestoUI.doms;
const callbackMapper = prestoUI.callbackMapper;
var webParseParams, iOSParseParams, parseParams, lastScreen = [], screenTransition = {};

if (window.__OS === "WEB") {
  webParseParams = prestoUI.helpers.web.parseParams;
} else if (window.__OS == "IOS") {
  iOSParseParams = prestoUI.helpers.ios.parseParams;
} else {
  parseParams = prestoUI.helpers.android.parseParams;
}

exports.addTime3 = addTime

function addTime(screen){
  return function(){
    try{
      var lastIndex = screen.lastIndexOf("_")
      var x = [screen.slice(0,lastIndex), screen.slice(lastIndex + 1)]
      screenTransition = screenTransition || {}
      screenTransition[screen] = Date.now()
      if(lastScreen.length > 0){
        if(x[x.length-1].toLowerCase() === "rendered"){
          var last = lastScreen[lastScreen.length - 1]
          window.latency = window.latency || {}
          window.latency[x[0]] = screenTransition[screen] - screenTransition[last + "_Exited"]
          tracker._trackAction("system")("info")("screenLatency")({"currentScreen" : x[0], "lastScreen" : last, "latency" : window.latency[x[0]]})()
          lastScreen.push(x[0])
        }else if(x[x.length-1].toLowerCase() === "exited" && lastScreen.length > 1){
          lastScreen.pop()
        }
      }else{
        lastScreen.push(x[0])
      }
    }catch(e){
      tracker._trackAction("system")("info")("screenLatency")({"exception" : e})()
    }
  }
}

function makeImageName(imageName){
  var jpImage = "jp_"+imageName;
  if(window.juspayAssetConfig
     && window.juspayAssetConfig.images 
     && window.juspayAssetConfig.images[jpImage])
      return jpImage;
  return imageName;

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
, activityNamespaces: {}
, currentActivity: "activity"
, constState : {}
}

const loopedFunction = function(){
  return loopedFunction
}

const getTracker = function () {
  var trackerJson = JOS.tracker || {};
  if (typeof trackerJson._trackContext != "function") {
    trackerJson._trackContext = loopedFunction;
  }
  if (typeof trackerJson._trackAction != "function") {
    trackerJson._trackAction = loopedFunction;
  }
  if (typeof trackerJson._trackException != "function") {
    trackerJson._trackException = loopedFunction;
  }
  if (typeof trackerJson._trackLifeCycle != "function") {
    trackerJson._trackLifeCycle = loopedFunction;
  }
  return trackerJson;
};

const tracker = getTracker()

const trackExceptionWrapper = function(label, message, err){
  tracker._trackException("system")("exception")(label)(message)(err.stack)();
}

const isPreRenderSupported = function(){
  var isSupported = false;
  if(window.__OS == "ANDROID"){
    try{
      const preRenderVersion = JBridge.getResourceByName("pre_render_version");
      const clientId = window.__payload.payload.clientId.split("_")[0];
      const sdkConfigFile = JSON.parse(JBridge.loadFileInDUI("sdk_config.json") || "");
      isSupported = preRenderVersion >= (sdkConfigFile.preRenderConfig[clientId] || sdkConfigFile.preRenderConfig.common)
    } catch(e) {
      trackExceptionWrapper("ma_pre_render_support", "error in multi-activity-pre-render support check", e);
    }
  }
  state.isPreRenderEnabled = isSupported
  return isSupported
}

state.isPreRenderEnabled = state.isPreRenderEnabled || isPreRenderSupported()
window.getState = state

if(!state.isPreRenderEnabled) {
  state.patchState = {}
  state.cachedMachine = {}
}


const getScopedState = function (namespace, activityID) {
  if(state.isPreRenderEnabled) {
    const activityIDToUse = activityID || state.currentActivity;
    return state.scopedState.hasOwnProperty(namespace)
      ? state.scopedState[namespace][activityIDToUse]
      : undefined;
  } else {
    return state.scopedState[getNamespace(namespace, activityID)];
  }

};

const getConstState = function (namespace, activityID) {
  if(state.isPreRenderEnabled) {
    return state.constState[namespace];
  } else {
    var id = activityID || state.currentActivity
    if (namespace && namespace.indexOf(id) == -1) {
      namespace = namespace + id;
    }
    return state.constState[namespace];
  }
};
const getNamespace = function (namespace, activityID) {
  var id = activityID || state.currentActivity
  if (namespace && namespace.indexOf(id) == -1) {
    namespace = namespace + id;
  }
  return namespace
}

const deleteScopedState = function (namespace, activityID) {
  var id = activityID || state.currentActivity;
  if(!state.isPreRenderEnabled) {
    if (state.scopedState[getNamespace(namespace, activityID)]) {
      delete state.scopedState[getNamespace(namespace, activityID)];
    }
  }
  if (state.scopedState[namespace] && state.scopedState[namespace][id]) {
    delete state.scopedState[namespace][id];
  }
};

const deleteConstState = function (namespace) {
  delete state.constState[namespace];
};

var getIdFromNamespace = function(namespace) {
  var ns = getScopedState(namespace).id ? getScopedState(namespace).id : undefined;
  if(window.__OS == "ANDROID")
    ns = getScopedState(namespace).id ? getScopedState(namespace).id : null;
  return ns;
}

window.getIdFromNamespace = function(namespace) {
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
        ? (parseInt(Android.getNewID()) * 1000000) % 100000000
        : (window.__PRESTO_ID || getPrestoID() * 1000000) % 100000000;
    return {
      __id: ++window.__ui_id_sequence
    };
  }
};

window.createPrestoElement = createPrestoElement;

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

function isRecyclerViewSupported(){
  var isSupported = false;
  if(window.__OS == "ANDROID"){
    try{
      const prestoListVersion = JBridge.getResourceByName("presto_list_version");
      const prestoUIVersion = window.presto_ui_version;
      isSupported = prestoListVersion >= 1.0 && prestoUIVersion >= 1.0;
    } catch(e) {
      trackExceptionWrapper("recycler_view_support", "error in getting presto list version for recycler view", e);
    }
  }
  return isSupported;
}

function parsePropsImpl(elem, screenName, VALIDATE_ID, namespace) {
  if(elem.type == "listView" && isRecyclerViewSupported()){ 
    elem.type = "recyclerView";
  }
  if (elem.props.hasOwnProperty('id') && elem.props.id != '' && (elem.props.id).toString().trim() != '') {
    var id = (elem.props.id).toString().trim();
    elem.__ref = {__id: id };
    if (VALIDATE_ID.hasOwnProperty(id)){
      console.warn("Found duplicate ID! ID: "+ id +
        " maybe caused because of overriding `id` prop. This may produce unwanted behavior. Please fix..");
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
    props.listItem = JSON.stringify({itemView : props.listItem.itemView, holderViews : props.listItem.holderViews})
  }

  if(type == "microapp") {
    // Add to queue of m-app ui to be triggered.
    // Queue to be fired on callback of AddViewToParent
    var mappBootData = {
      payload : props.payload
    , viewGroupTag : props.viewGroupTag || "main"
    , useLinearLayout : props.useLinearLayout || false
    , unNestPayload : props.unNestPayload
    , useStartApp : props.useStartApp
    , requestId : elem.requestId
    , service : elem.service
    , elemId : elem.__ref.__id
    , callback : props.onMicroappResponse
    }
    if (getScopedState(namespace) && getScopedState(namespace).mappQueue) {
      getScopedState(namespace).mappQueue[screenName] = getScopedState(namespace).mappQueue[screenName] || []
      getScopedState(namespace).mappQueue[screenName].push(mappBootData);
    }
    else {
      console.warn("Namespace", namespace);
      console.warn("state", state);
    }
    type = mappBootData.useLinearLayout ? "linearLayout" : "relativeLayout"
  } else if (type ==  "fragmentContainerView") {
    type = props.useLinearLayout ? "linearLayout" : "relativeLayout"
    if(props.namespace) {
      // InitUI
      exports.setUpBaseState(props.namespace)(null)();
      // Mark that this is not pre-render
      getConstState(props.namespace).hasRender = true
      var newElem = getScopedState(props.namespace).root
      newElem.props = props;
      newElem.props.afterRender = markRootReady(props.namespace);
      return parsePropsImpl(newElem, screenName, VALIDATE_ID, namespace)
    }
  }
  if(props.hasOwnProperty("afterRender")) {
    if (getConstState(namespace).prerenderScreens.indexOf(screenName) != -1) {
      getConstState(namespace).afterRenderFunctions[screenName] = getConstState(namespace).afterRenderFunctions[screenName] || []
      getConstState(namespace).afterRenderFunctions[screenName].push(props.afterRender)
    }
    getScopedState(namespace).afterRenderFunctions[screenName] = getScopedState(namespace).afterRenderFunctions[screenName] || []
    getScopedState(namespace).afterRenderFunctions[screenName].push(props.afterRender)
    delete props.afterRender
  }
  if (elem.hasOwnProperty("chunkedLayout") && elem.chunkedLayout) {
    elem.children.forEach(function(e, i) {
      getScopedState(namespace).actualLayouts.push({'layout': elem.layouts[i], 'shimmerId': e.__ref.__id, 'parent': elem, 'index': i});
    });
  }
  if (
    props.entryAnimation ||
    props.entryAnimationF ||
    props.entryAnimationB
  ) {
    if (props.onAnimationEnd) {
      var callbackFunction = props.onAnimationEnd;
      var updatedCallback = function(event) {
        getScopedState(namespace).activateScreen = true;
        hideOldScreenNow(namespace, screenName);
        callbackFunction(event);
      };
      props.onAnimationEnd = updatedCallback;
    } else {
      props.onAnimationEnd = function() {
          getScopedState(namespace).activateScreen = true;
          hideOldScreenNow(namespace, screenName);
        }
    }
  }
  if (props.entryAnimation) {
    props.inlineAnimation = props.entryAnimation;
    getConstState(namespace).animations.entry[screenName] = getConstState(namespace).animations.entry[screenName] || {}
    getConstState(namespace).animations.entry[screenName].hasAnimation = true
    getConstState(namespace).animations.entry[screenName][elem.__ref.__id] = {
        visibility: props.visibility ? props.visibility : "visible",
        inlineAnimation: props.entryAnimation,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
  }

  if (props.entryAnimationF) {
    getConstState(namespace).animations.entryF[screenName] = getConstState(namespace).animations.entryF[screenName] || {}
    getConstState(namespace).animations.entryF[screenName].hasAnimation = true
    getConstState(namespace).animations.entryF[screenName][elem.__ref.__id] = {
        visibility: props.visibility ? props.visibility : "visible",
        inlineAnimation: props.entryAnimationF,
        onAnimationEnd: props.onAnimationEnd,
        type: type
      };
    props.inlineAnimation = props.entryAnimationF;
  }

  if (props.entryAnimationB) {
    getConstState(namespace).animations.entryB[screenName] = getConstState(namespace).animations.entryB[screenName] || {}
    getConstState(namespace).animations.entryB[screenName].hasAnimation = true
    getConstState(namespace).animations.entryB[screenName][elem.__ref.__id] = {
      visibility: props.visibility ? props.visibility : "visible",
      inlineAnimation: props.entryAnimationB,
      onAnimationEnd: props.onAnimationEnd,
      type: type
    };
  }

  if (props.exitAnimation) {
    getConstState(namespace).animations.exit[screenName] = getConstState(namespace).animations.exit[screenName] || {}
    getConstState(namespace).animations.exit[screenName].hasAnimation = true
    getConstState(namespace).animations.exit[screenName][elem.__ref.__id] = {
      inlineAnimation: props.exitAnimation,
      onAnimationEnd: props.onAnimationEnd,
      type: type
    };
  }

  if (props.exitAnimationF) {
    getConstState(namespace).animations.exitF[screenName] = getConstState(namespace).animations.exitF[screenName] || {}
    getConstState(namespace).animations.exitF[screenName].hasAnimation = true
    getConstState(namespace).animations.exitF[screenName][elem.__ref.__id] = {
      inlineAnimation: props.exitAnimationF,
      onAnimationEnd: props.onAnimationEnd,
      type: type
    };
  }

  if (props.exitAnimationB) {
    getConstState(namespace).animations.exitB[screenName] = getConstState(namespace).animations.exitB[screenName] || {}
    getConstState(namespace).animations.exitB[screenName].hasAnimation = true
    getConstState(namespace).animations.exitB[screenName][elem.__ref.__id] = {
      inlineAnimation: props.exitAnimationB,
      onAnimationEnd: props.onAnimationEnd,
      type: type
    };
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
  while(getScopedState(namespace).hideList.length > 0) {
    var screenName = getScopedState(namespace).hideList.pop();
    var cb = getConstState(namespace).screenHideCallbacks[screenName];
    if(typeof cb == "function") {
      cb();
    }
  }
  while(getScopedState(namespace).removeList.length > 0) {
    var screenName = getScopedState(namespace).removeList.pop();
    var cb = getConstState(namespace).screenRemoveCallbacks[screenName]
    if(typeof cb == "function") {
      cb();
    }
  }
  if (getScopedState(namespace).shouldHideCacheRoot){
    getScopedState(namespace).shouldHideCacheRoot = false
    hideViewInNameSpace(getScopedState(namespace).cacheRoot, namespace)()
  }
  if(getScopedState(namespace).shouldReplayCallbacks[sn]) {
    getScopedState(namespace).shouldReplayCallbacks[sn] = false;
    var cbs = getScopedState(namespace).fragmentCallbacks[sn] || []
    cbs.forEach (function(x) {
      if (typeof x.callback == "function") { x.callback(x.payload); }
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
  getScopedState(namespace).activateScreen = false;
  getScopedState(namespace).activeScreen = screenName;
  if (screenName == getConstState(namespace).animations.lastAnimatedScreen) {
    getScopedState(namespace).activateScreen = true;
    return;
  }
  var isRunScreen = getConstState(namespace).animations.animationStack.indexOf(screenName) != -1;
  var isShowScreen = getConstState(namespace).animations.animationCache.indexOf(screenName) != -1;
  var isLastAnimatedCache = getConstState(namespace).animations.animationCache.indexOf(getConstState(namespace).animations.lastAnimatedScreen) != -1;
  var topOfStack = getConstState(namespace).animations.animationStack[getConstState(namespace).animations.animationStack.length - 1];
  var animationArray = []
  if (isLastAnimatedCache) {
    animationArray.push({ screenName : getConstState(namespace).animations.lastAnimatedScreen + "", tag : "exit"});
    getScopedState(namespace).hideList.push(getConstState(namespace).animations.lastAnimatedScreen);
  }
  if (isRunScreen || isShowScreen) {
    if(isRunScreen) {
      if(topOfStack != screenName) {
        animationArray.push({ screenName : screenName, tag : "entryB"})
        animationArray.push({ screenName : topOfStack, tag : "exitB"})
        while (getConstState(namespace).animations.animationStack[getConstState(namespace).animations.animationStack.length - 1] != screenName) {
          var page = getConstState(namespace).animations.animationStack.pop();
          if(state.isPreRenderEnabled) {
            if (getConstState(namespace).cachedMachine && getConstState(namespace).cachedMachine.hasOwnProperty(page)){
              getConstState(namespace).animations.prerendered.push(page)
            }
          }
          else {
            var namespace_ = getNamespace(namespace);
            if (state.cachedMachine.hasOwnProperty(namespace_) && state.cachedMachine[namespace_].hasOwnProperty(page)){
              getConstState(namespace).animations.prerendered.push(page)
            }
          }
        }
      }
    } else {
      animationArray.push({ screenName : screenName, tag : "entry"})
    }
  } else {
    // Newscreen case
    if (cache){
      getConstState(namespace).animations.animationCache.push(screenName); // TODO :: Use different data structure. Array does not realy fit the bill.
    } else {
      // new runscreen case call forward exit animation of previous runscreen
      var previousScreen = getConstState(namespace).animations.animationStack[getConstState(namespace).animations.animationStack.length - 1]
      animationArray.push({ screenName : previousScreen, tag : "exitF"})
      if (getConstState(namespace).animations.prerendered.indexOf(screenName) != -1){
        animationArray.push({ screenName : screenName, tag : "entryF"})
      }
      getScopedState(namespace).hideList.push(previousScreen);
      getConstState(namespace).animations.animationStack.push(screenName);
    }
  }
  callAnimation_(namespace, animationArray, false, screenName)
  getConstState(namespace).animations.lastAnimatedScreen = screenName;
}

function callAnimation_ (namespace, screenArray, resetAnimation, screenName) {
  window.enableBackpress = false;
  var hasAnimation = false;
  screenArray.forEach(
    function (animationJson) {
      if (getConstState(namespace).animations[animationJson.tag] && getConstState(namespace).animations[animationJson.tag][animationJson.screenName]) {
        var animationJson = getConstState(namespace).animations[animationJson.tag][animationJson.screenName]
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
    getScopedState(namespace).activateScreen = true;
    hideOldScreenNow(namespace, screenName)
  }
}

function processMapps(namespace, nam, timeout) {
  setTimeout(function () {
    if (!getScopedState(namespace).mappQueue || !(getScopedState(namespace).mappQueue && getScopedState(namespace).mappQueue[nam]))
      return;
    var cachedObject = getScopedState(namespace).mappQueue[nam][0];
    while (cachedObject) {
      var fragId = AndroidWrapper.addToContainerList(parseInt(cachedObject.elemId), getIdFromNamespace(namespace));
      if (fragId == "__failed") {
        if(timeout > 3000){
          getScopedState(namespace).mappQueue[nam].shift();
          processMapps(namespace, nam, 75)
        }else{
          setTimeout( processMapps(namespace, nam, (timeout|| 75)*2), (timeout|| 75))
        }
        return;
      }else{
        getScopedState(namespace).mappQueue[nam].shift();

      }
      cachedObject.fragId = fragId;
      var cb = function (code) {
        return function (message) {
          return function () {
            var test = JSON.parse(message)
            if(!test.stopAtDom) {
              getScopedState(namespace).fragmentCallbacks[nam] = getScopedState(namespace).fragmentCallbacks[nam] || [];
              getScopedState(namespace).fragmentCallbacks[nam].push({
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
                tracker._trackAction("system")("info")("process_mapps_response")({"namespace":namespace, "code":code, "description": message})();
            } else {
                try {
                  var plds = getScopedState(namespace).fragmentCallbacks[nam] || [];
                  getScopedState(namespace).fragmentCallbacks[nam] = plds.filter(function(x) {
                    return !(test.id == x.payload.elemId)
                  })
                } catch (e) {
                  trackExceptionWrapper("process_mapps", {"namespace":namespace, "name":nam, "description": "flushFragmentCallbacks Error"}, e);
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
      var x = cachedObject.unNestPayload ? p : {
        service: cachedObject.service,
        requestId: cachedObject.requestId,
        payload: p
      };

      if (cachedObject.useStartApp) {
        JOS.startApp(cachedObject.service)(x)(cb)()
      } else if(window.JOS && typeof JOS.isMAppPresent == "function" &&  typeof JOS.isMAppPresent(cachedObject.service) == "function" && JOS.isMAppPresent(cachedObject.service)()) {
        JOS.emitEvent(cachedObject.service)("onMerchantEvent")(["process", JSON.stringify(x)])(cb)();
      } else {
        cb(0)("error")()
      }
      cachedObject = getScopedState(namespace).mappQueue[nam][0];
    }
  }, 32);
}

function triggerAfterRender(namespace, screenName) {
  while(getScopedState(namespace).afterRenderFunctions[screenName] && typeof getScopedState(namespace).afterRenderFunctions[screenName][0] == "function") {
      getScopedState(namespace).afterRenderFunctions[screenName].pop()();
  }
}

function executePostProcess(nam, namespace, cache) {
    return function(a) {
      if(a != undefined && typeof a == "string" && a.toLowerCase() == "failure"){
        tracker._trackAction("system")("error")("execute_post_process")({"namespace":namespace, "name":nam, "callbackWithParam": a})();
      } else {
        tracker._trackAction("system")("info")("execute_post_process")({"namespace":namespace, "name":nam, "callbackWithParam": a})();
      }
      callAnimation__(nam, namespace, cache);
      processMapps(namespace, nam, 75);
      triggerAfterRender(namespace, nam);
      triggerChunkCascade(namespace, nam);
      addTime(nam + "_Rendered")()
    };
}

function triggerChunkCascade(namespace, screenName) {
  var chunk = getScopedState(namespace).actualLayouts.shift();
  if (chunk == undefined)
    return;
  if (chunk.layout.props) {
    chunk.layout.props.root = true;
  }
  var dom = domAll(chunk.layout, screenName, namespace);
  chunk.parent.children.splice(chunk.index, 1, chunk.layout);
  var cb = callbackMapper.map(function() {
    triggerChunkCascade(namespace, screenName);
  });
  removeViewFromNameSpace(namespace, chunk.shimmerId)();
  AndroidWrapper.addViewToParent(
    window.__OS == "ANDROID" ? chunk.parent.__ref.__id + "" : chunk.parent.__ref.__id,
    window.__OS == "ANDROID" ? JSON.stringify(dom) : dom,
    chunk.index,
    cb,
    null,
    getIdFromNamespace(namespace)
  );
}

exports.checkAndDeleteFromHideAndRemoveStacks = function (namespace, screenName) {
  try {
    var index = getScopedState(namespace).hideList.indexOf(screenName)
    if(index != -1) {
      delete getScopedState(namespace).hideList[index];
    }
    var index = getScopedState(namespace).removeList.indexOf(screenName)
    if(index != -1) {
      delete getScopedState(namespace).removeList[index];
    }
  } catch(e) {
    // Ignored this will happen ever first time for each screen
  }
}

exports.setUpBaseState = function (namespace) {
  return function (id) {
    return function () {
      tracker._trackAction("system")("info")("setup_base_state")({"namespace":namespace, "id":id, "isMultiActivityPreRenderSupported": state.isPreRenderEnabled})();
      if(typeof getScopedState(namespace) != "undefined" && getScopedState(namespace).root && typeof getConstState(namespace) !== 'undefined' && getConstState(namespace).hasRender) {
        terminateUIImpl()(namespace);
      }else if(typeof getScopedState(namespace) != "undefined" && getScopedState(namespace).root){
        getScopedState(namespace).id = id
        return;
      }
      if(!state.isPreRenderEnabled) namespace = getNamespace(namespace)
      if (state.currentActivity !== '') {
        var ns = namespace;
        if(!state.isPreRenderEnabled) ns = namespace.substr(0, namespace.length - state.currentActivity.length);
        state.activityNamespaces[state.currentActivity] = state.activityNamespaces[state.currentActivity] || [];
        state.activityNamespaces[state.currentActivity].push(ns);
      }
      // var _namespace = "";
      setFragmentIdInScopedState(namespace, id);
      state.fragments[id || "null"] = namespace;
      var elemRef = createPrestoElement();
      var stackRef = createPrestoElement();
      var cacheRef = createPrestoElement();
      getScopedState(namespace).root = {
          type: "relativeLayout",
          props: {
            id : elemRef.__id,
            root: "true",
            height: "match_parent",
            width: "match_parent",
            visibility : "gone"
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
      getScopedState(namespace).MACHINE_MAP = {}
      getScopedState(namespace).screenStack = []
      getScopedState(namespace).hideList = []
      getScopedState(namespace).removeList = []
      getScopedState(namespace).screenCache = []
      getScopedState(namespace).cancelers = {}
      getScopedState(namespace).rootId = elemRef.__id
      getScopedState(namespace).stackRoot = stackRef.__id
      getScopedState(namespace).cacheRoot = cacheRef.__id
      getScopedState(namespace).shouldHideCacheRoot = false
      getScopedState(namespace).eventIOs = {}
      getScopedState(namespace).queuedEvents = {}
      getScopedState(namespace).pushActive = {}
      getScopedState(namespace).rootVisible = false;
      getScopedState(namespace).rootReady = false;
      getScopedState(namespace).awaitRootReady = [];
      getScopedState(namespace).patchState = {}
      getScopedState(namespace).screenActive = {}

      if (!state.constState.hasOwnProperty( namespace )){
        state.constState[namespace] = {}
        getConstState(namespace).animations = {}
        getConstState(namespace).animations.entry = {}
        getConstState(namespace).animations.exit = {}
        getConstState(namespace).animations.entryF = {}
        getConstState(namespace).animations.exitF = {}
        getConstState(namespace).animations.entryB = {}
        getConstState(namespace).animations.exitB = {}
        getConstState(namespace).animations.animationStack = []
        getConstState(namespace).animations.animationCache = []
        getConstState(namespace).animations.lastAnimatedScreen = ""
        getConstState(namespace).animations.prerendered = []

        getConstState(namespace).screenHideCallbacks = {}
        getConstState(namespace).screenShowCallbacks = {}
        getConstState(namespace).screenRemoveCallbacks = {}
        getConstState(namespace).registeredEvents = {}
        getConstState(namespace).afterRenderFunctions = {}
        getConstState(namespace).cachedMachine = {}
        getConstState(namespace).prerenderScreens = []
      }
      // https://juspay.atlassian.net/browse/PICAF-6628
      getScopedState(namespace).afterRenderFunctions = prestoUI.prestoClone( getConstState(namespace).afterRenderFunctions || {});
      getScopedState(namespace).actualLayouts = []

      // rethink Logic
      getScopedState(namespace).mappQueue = {}
      getScopedState(namespace).fragmentCallbacks = {}
      getScopedState(namespace).shouldReplayCallbacks = {}
    }
  }
}

const markRootReady = function(namespace) {
  return function () {
    var state = getScopedState(namespace)
    if(state) {
      state.rootReady = true
      while(state.awaitRootReady.length > 0) {
        var cb = state.awaitRootReady.pop()
        if(typeof cb == "function") {
          cb();
        }
      }
    }
  }
}

exports.awaitRootReady = function(namespace) {
  return function (cb) {
    return function() {
      var state = getScopedState(namespace)
      if(state && state.rootReady) {
        cb()();
      } else if (state) {
        state.awaitRootReady.push(cb());
      } else {
        console.error("Call initUI for Namespace :: ", namespace)
      }
    }
  }
}

exports.render = function (namespace) {
  getConstState(namespace).hasRender = true
  var id = getIdFromNamespace(namespace);
  var cb = callbackMapper.map(markRootReady(namespace));
  if(__OS == "ANDROID") {
    cb = JSON.stringify(cb); 
  }
  if (window.__OS == "ANDROID") {
    if (typeof AndroidWrapper.getNewID == "function") {
      // TODO change this to mystique version check.
      // TODO add mystique reject / alternate handling, when required version is not present
      AndroidWrapper.render(JSON.stringify(domAll(getScopedState(namespace).root, "base", namespace)), cb, "false", (id ? id : null));
    } else {
      AndroidWrapper.render(JSON.stringify(domAll(getScopedState(namespace).root), "base", namespace), cb);
    }
  } else if (window.__OS == "WEB") {
    AndroidWrapper.Render(domAll(getScopedState(namespace).root, "base", namespace), cb, getIdFromNamespace(namespace)); // Add support for Web
  } else {
    AndroidWrapper.render(domAll(getScopedState(namespace).root, "base", namespace), cb, (id ? id : undefined)); // Add support for iOS
  }

  try {
    //Code is in try catch to avoid any errors with accessing top
    if(window.__OS == "IOS" && !getScopedState(namespace).id) {
      top.setAddRootScreen = top.setAddRootScreen || function (screenName) {
          top.PDScreens = top.PDScreens || []
          top.PDScreens.push(screenName)
        }
      top.setAddRootScreen(JOS.self + "::" + namespace);
    }
  } catch (e) {

  }
}

exports.insertDom = function(namespace, name, dom, cache) {
  if(!getScopedState(namespace)) {
    console.error("Call initUI for namespace :: " + namespace + "before triggering run/show screen")
    return;
  }
  if(!getScopedState(namespace).rootVisible) {
    makeRootVisible(namespace);
  }

  getConstState(namespace).animations.entry[name] = {}
  getConstState(namespace).animations.exit[name] = {}
  getConstState(namespace).animations.entryF[name] = {}
  getConstState(namespace).animations.exitF[name] = {}
  getConstState(namespace).animations.entryB[name] = {}
  getConstState(namespace).animations.exitB[name] = {}
  getScopedState(namespace).root.children.push(dom);
  if (dom.props && dom.props.hasOwnProperty('id') && (dom.props.id).toString().trim()) {
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  } else {
    dom.__ref = createPrestoElement();
  }
  if(dom.props) {
    dom.props.root = true
  }
  var rootId = cache ? getScopedState(namespace).cacheRoot : getScopedState(namespace).stackRoot
  var length = cache ? getScopedState(namespace).screenCache.length : getScopedState(namespace).screenStack.length
  // TODO implement cache limit later
  getConstState(namespace).screenHideCallbacks[name] = hideViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenShowCallbacks[name] = showViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenRemoveCallbacks[name] = removeViewFromNameSpace(namespace, dom.__ref.__id)
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

exports.prepareAndStoreView = function (callback, dom, key, namespace, screenName){
  /*
   * Adding callback to make sure that prepareScreen returns controll only
   * after native rendering is completed
   */
  var callB = callbackMapper.map(function(a){
    try{
      if(a != undefined && typeof a == "string" && a.toLowerCase() == "failure"){
        tracker._trackAction("system")("error")("prepare_and_store_view")({"namespace":namespace, "key":key,  "callbackWithParam": a})();
      } else {
        tracker._trackAction("system")("info")("prepare_and_store_view")({"namespace":namespace, "key":key, "callbackWithParam": a})();
      }
      getConstState(namespace)[screenName].prepareStarted = false;
      while(getConstState(namespace)[screenName].prepareStartedQueue[0]){
        var fn = getConstState(namespace)[screenName].prepareStartedQueue.pop();
        fn();
      }
    }catch(err){
      trackExceptionWrapper("prepare_and_store_view_catch", {"namespace":namespace, "key":key}, err);
    }
    callback();
  });
  Android.prepareAndStoreView(
    key,
    window.__OS == "ANDROID" ? JSON.stringify(dom) : dom,
    callB
  );
}

exports.attachScreen = function(namespace, name, dom){
  if(!namespace) {
    console.error("Call initUI for namespace :: " + namespace + "before triggering run/show screen")
    return;
  }
  if (window.__OS == "ANDROID") {
    var rootId = getScopedState(namespace).stackRoot;
    var length = getScopedState(namespace).screenStack.length;
    var screenName = namespace + name

    var cmds = getScrollViewResetCmds(dom);
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

exports.storeMachine = function (dom, name, namespace) {
  if(state.isPreRenderEnabled) {
    getScopedState(namespace).MACHINE_MAP[name] = dom;
    if (getConstState(namespace).cachedMachine &&
        getConstState(namespace).cachedMachine.hasOwnProperty(name)){
          getConstState(namespace).cachedMachine[name] = dom;
    }
  } else {
    var namespace = getNamespace(namespace);
    state.scopedState[namespace].MACHINE_MAP[name] = dom;
    if (state.cachedMachine.hasOwnProperty(namespace) &&
         state.cachedMachine[namespace].hasOwnProperty(name)){
      state.cachedMachine[namespace][name] = dom;
    }
  }

}

exports.getLatestMachine = function (name, namespace) {
    return getScopedState(namespace).MACHINE_MAP[name];
}

exports.cacheMachine = function(machine, screenName, namespace) {
  if(state.isPreRenderEnabled) {
    if (!getConstState(namespace).cachedMachine){
      getConstState(namespace).cachedMachine = {}
    }
    getConstState(namespace).cachedMachine[screenName] = machine;
  }
  else {
    var curNamespace = getNamespace(namespace);
    if (!state.cachedMachine.hasOwnProperty(curNamespace)){
      state.cachedMachine[curNamespace] = {}
    }
    state.cachedMachine[curNamespace][screenName] = machine;
  }
};

exports.isInStack = function (name, namespace) {
  // Added || false to return false when value is undefined
  try {
    return getScopedState(namespace).screenStack.indexOf(name) != -1
  } catch (e) {
    console.error( "Call initUI with for namespace :: " + namespace , e );
  }
  return false
}

exports.isCached = function (name, namespace) {
  // Added || false to return false when value is undefined
  try {
    return getScopedState(namespace).screenCache.indexOf(name) != -1
  } catch (e) {
    console.error( "Call initUI with for namespace :: " + namespace , e );
  }
  return false
}

exports.cancelExistingActions = function (name, namespace) {
  // Added || false to return false when value is undefined
  delete getScopedState(namespace).pushActive[name]
  try{
    if(getScopedState(namespace) && getScopedState(namespace).cancelers && typeof getScopedState(namespace).cancelers[name] == "function") {
      getScopedState(namespace).cancelers[name]();
    }
  }catch(e){
    console.error("cancelExistingActions:",e);
  }
}

exports.saveCanceller = function (name, namespace, canceller) {
  // Added || false to return false when value is undefined
  if(!state.isPreRenderEnabled) {
    namespace = namespace + state.currentActivity;
    // Todo :: Fix setting up of scopedState
    state.scopedState[namespace] = getScopedState(namespace) || {}
  } else {
    var activity = state.currentActivity;
    state.scopedState[namespace][activity] = getScopedState(namespace) || {}
  }
  getScopedState(namespace).cancelers = getScopedState(namespace).cancelers || {}
  if(getScopedState(namespace) && getScopedState(namespace).cancelers) {
    getScopedState(namespace).cancelers[name] = canceller;
  }
  return namespace
}
exports.terminateUIImpl = terminateUIImpl();
exports.terminateUIImplWithCallback = terminateUIImpl;
function terminateUIImpl(callback) {
  return function(namespace) {
    lastScreen = []
    if(callback) {
      callback(-1)(JSON.stringify({
          stopAtDom : true,
          id : getScopedState(namespace).id
        }))()
    }
    window.__usedIDS = undefined;
    if(state.isPreRenderEnabled) clearStoredID();
    if(window.__OS == "ANDROID"
    && AndroidWrapper.runInUI
    && getScopedState(namespace)
    && getScopedState(namespace).root
    && getScopedState(namespace).root.__ref
    && getScopedState(namespace).root.__ref.__id
    ) {
      AndroidWrapper.runInUI(
        ";set_v=ctx->findViewById:i_" +
          getScopedState(namespace).root.__ref.__id +
          ";set_p=get_v->getParent;get_p->removeView:get_v;",
        null
      );
    } else if ( JOS
      && JOS.parent
      && JOS.parent != "java"
      && getScopedState(namespace)
      && getScopedState(namespace).root
      && getScopedState(namespace).root.__ref
      && getScopedState(namespace).root.__ref.__id
    ) {
      AndroidWrapper.removeView(getScopedState(namespace).root.__ref.__id, getIdFromNamespace(namespace));
    } else {
      if ( JOS
        && JOS.parent
        && getScopedState(namespace)
        && getScopedState(namespace).root
        && getScopedState(namespace).root.__ref
        && getScopedState(namespace).root.__ref.__id
      ) {
        AndroidWrapper.removeView(getScopedState(namespace).root.__ref.__id, getIdFromNamespace(namespace));
      }
    }
    try {
      if(window.__OS == "IOS" && !getScopedState(namespace).id) {
        top.removeRootScreen = top.removeRootScreen || function (screenName) {
            var index = this.top.PDScreens.indexOf(screenName);
            if(index == -1) {
              return;
            }
            else {
              this.top.PDScreens.splice(index, 1);
              if (this.top.PDScreens.length == 0) {
                AndroidWrapper.runInUI(["removeAllUI"], this.getIdFromNamespace(this.namespace));
              }
            }
          }
        // Adding var x so that openning paranthesis is not treated as argument
        var x = (top.removeRootScreen.bind(this))(JOS.self + "::" + namespace);
      }
    } catch (e) {
      // incase of exception from using top
    }
    deleteScopedState(namespace)
    if (window.__OS != "ANDROID") {
      deleteConstState(namespace)
    }
  }
}

exports.setToTopOfStack = function (namespace, screenName) {
  try {
    if(getScopedState(namespace).screenStack.indexOf(screenName) != -1) {
      var index = getScopedState(namespace).screenStack.indexOf(screenName)
      var removedScreens = getScopedState(namespace).screenStack.splice(index + 1)
      getScopedState(namespace).removeList = getScopedState(namespace).removeList.concat(removedScreens)
      for (var i = 0; i < removedScreens.length; ++i) {
        var removedScreen = removedScreens[i];
        if(getScopedState(namespace) && getScopedState(namespace).fragmentCallbacks[removedScreen] ){
           delete getScopedState(namespace).fragmentCallbacks[removedScreen];
        }
      }
    } else {
      getScopedState(namespace).screenStack.push(screenName)
    }

  } catch (e) {
    console.error("Call Init UI for namespace :: ", namespace, e)
  }
}

exports.makeScreenVisible = function (namespace, name) {
  try {
    var cb = getConstState(namespace).screenShowCallbacks[name];
    if(typeof cb == "function") {
      cb()
    }
  } catch(e) {
    trackExceptionWrapper("make_screen_visible", {"namespace":namespace, "name":name, "description": "Call InitUI first for the namespace"}, e);
  }
}

exports.addToCachedList = function (namespace, screenName) {
  try {
    if(!(getScopedState(namespace).screenCache.indexOf(screenName)!= -1)) {
      getScopedState(namespace).screenCache.push(screenName);
    }
  } catch (e) {
    trackExceptionWrapper("add_to_cached_list", {"namespace":namespace, "name":screenName, "description": "Call InitUI first for the namespace"}, e);
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
              setTimeout(function(){ processMapps(namespace, screenName, 75)},500)
            } else {
              processMapps(namespace, screenName, 75)
              triggerAfterRender(namespace, screenName)
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
            getConstState(namespace).registeredEvents = getConstState(namespace).registeredEvents || {}
            getConstState(namespace).registeredEvents[eventName] =
              isDefined(getConstState(namespace).registeredEvents[eventName])
                ? getConstState(namespace).registeredEvents[eventName]
                : {};
            getConstState(namespace).registeredEvents[eventName][screenName] = callbackFunction;
          } catch (e) {
            trackExceptionWrapper("set_manual_events", {"namespace":namespace, "name":screenName, "eventname": eventName, "description": "Call init UI first"}, e);
          }
        }
      }
    }
  }
}

exports.fireManualEvent = fireManualEvent()

exports.fireEventToScreen = function (namespace) {
  return function (screenName) {
    return fireManualEvent(namespace, screenName)
  }
}

function fireManualEvent (namespace, nam) {
  return function (eventName) {
    return function (payload) {
      return function() {
        var screenName = (getScopedState(namespace) || {}).activeScreen
        if(namespace && (nam == screenName || !nam)) {
          try {
            if(getConstState(namespace) && getConstState(namespace).registeredEvents && getConstState(namespace).registeredEvents.hasOwnProperty(eventName)) {
              if(screenName && typeof getConstState(namespace).registeredEvents[eventName][screenName] == "function")
                getConstState(namespace).registeredEvents[eventName][screenName](payload);
            }
          }catch(e){
            console.warn("Failed at fireManualEvent", e);
          }
          return;
        }
        for (var key in state.scopedState) {
          try {
            if(getConstState(key) && getConstState(key).registeredEvents && getConstState(key).registeredEvents.hasOwnProperty(eventName)) {
              var screenName = getScopedState(key).activeScreen
              var isNotAnimating = getScopedState(key).activateScreen
              if(isNotAnimating && screenName && typeof getConstState(key).registeredEvents[eventName][screenName] == "function")
                getConstState(key).registeredEvents[eventName][screenName](payload);
            }
          }catch(e){
            console.warn("Failed at fireManualEvent", e);
          }
        }
      }
    }
  };
}

exports.makeCacheRootVisible = function(namespace) {
  getScopedState(namespace).shouldHideCacheRoot = false;
  showViewInNameSpace(getScopedState(namespace).cacheRoot, namespace)();
}

const makeRootVisible = function(namespace) {
  getScopedState(namespace).rootVisible = true;
  showViewInNameSpace(getScopedState(namespace).rootId, namespace)();
}

exports.hideCacheRootOnAnimationEnd = function(namespace) {
  getScopedState(namespace).shouldHideCacheRoot = true;
}

exports.setControllerStates = function(namespace) {
  return function (screenName) {
    return function () {
      if(!getScopedState(namespace) || !getScopedState(namespace).root) {
        exports.setUpBaseState(namespace)()();
      }
      getScopedState(namespace).activeScreen = screenName;
      getScopedState(namespace).activateScreen = true;
    }
  }
}

exports["setUseHintColor"] = function (useHintColor) {
  return function(){
    if(window.__OS == "WEB" && typeof Android.setUseHintColor == "function") {
      Android.setUseHintColor(useHintColor);
    }
  }
}
exports["replayFragmentCallbacks'"] = function (namespace) {
  return function (nam) {
    return function (push) {
      return function() {
        try {
          if(!state.isPreRenderEnabled) namespace = getNamespace(namespace)
          getScopedState(namespace).shouldReplayCallbacks[nam] = true
          if(window.__OS == "WEB") {
            (getScopedState(namespace).fragmentCallbacks[nam] || []).forEach (function(x) {
              x.callback(x.payload)
            })
          }
        }
        catch (e) {
          trackExceptionWrapper("replay_fragment_callbacks", {"namespace":namespace, "name":nam, "description": "Replay fragment Error"}, e);
        }
        return function() {
          try {
            if(!state.isPreRenderEnabled) namespace = getNamespace(namespace)
            getScopedState(namespace).shouldReplayCallbacks[nam] = false
          } catch (err) {
            console.warn("TODO:: Fix this", err);
          }
        }
      }
    }
  }
}
exports.getAndSetEventFromState = function(namespace, screenName, def) {
  if(state.isPreRenderEnabled) {
    // Todo :: Fix setting up of scopedState
    state.scopedState[namespace][state.currentActivity] = getScopedState(namespace) || {}
  }
  else {
    if (namespace && namespace.indexOf(state.currentActivity) == -1) {
      namespace = namespace + state.currentActivity;
    }
    // Todo :: Fix setting up of scopedState
    state.scopedState[namespace] = getScopedState(namespace) || {}
  }
  getScopedState(namespace).eventIOs = getScopedState(namespace).eventIOs || {}
  getScopedState(namespace).eventIOs[screenName] = getScopedState(namespace).eventIOs[screenName] || def();
  return getScopedState(namespace).eventIOs[screenName];
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
    var x = element.props.unNestPayload ? payload : {
        service : element.service
    , requestId : element.requestId
    , payload : payload
    }
    var cb = function(code){return function(message){ return function(){
        if (typeof element.props.onMicroappResponse == "function"){
        element.props.onMicroappResponse({
            code: code,
            message: message,
        })
        }
    }}}
    setTimeout( function() {
        if(window.JOS && typeof JOS.isMAppPresent == "function" &&  typeof JOS.isMAppPresent(element.service) == "function" && JOS.isMAppPresent(element.service)()) {
        JOS.emitEvent(element.service)("onMerchantEvent")(["update", JSON.stringify(x)])(cb)();
        } else {
        cb(0)("error")()
        }
    }, 32);
  }
}

exports.incrementPatchCounter = function(namespace) {
  return function(screenName) {
    return function() {
      if(state.isPreRenderEnabled) {
        getScopedState(namespace).patchState[screenName] = getScopedState(namespace).patchState[screenName] || {}
        getScopedState(namespace).patchState[screenName].counter = getScopedState(namespace).patchState[screenName].counter || 0
        getScopedState(namespace).patchState[screenName].counter++;
      } else {
        state.patchState = state.patchState || {}
        state.patchState[namespace] = state.patchState[namespace] || {}
        state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
        state.patchState[namespace][screenName].counter = state.patchState[namespace][screenName].counter || 0
        state.patchState[namespace][screenName].counter++;
      }
    }
  }
}

exports.decrementPatchCounter = function(namespace) {
  return function(screenName) {
    return function () {
      if(state.isPreRenderEnabled) {
          getScopedState(namespace).patchState[screenName] = getScopedState(namespace).patchState[screenName] || {}
          getScopedState(namespace).patchState[screenName].counter = getScopedState(namespace).patchState[screenName].counter || 1
          if(getScopedState(namespace).patchState[screenName].counter > 0) {
            getScopedState(namespace).patchState[screenName].counter--;
          }
          if(getScopedState(namespace).patchState[screenName].counter === 0 && getScopedState(namespace).patchState[screenName].active) {
            triggerPatchQueue(namespace, screenName)
          }
      } else {
        state.patchState = state.patchState || {}
        state.patchState[namespace] = state.patchState[namespace] || {}
        state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
        state.patchState[namespace][screenName].counter = state.patchState[namespace][screenName].counter || 1
        if(state.patchState[namespace][screenName].counter > 0) {
          state.patchState[namespace][screenName].counter--;
        }
        if(state.patchState[namespace][screenName].counter === 0 && state.patchState[namespace][screenName].active) {
          triggerPatchQueue(namespace, screenName)
        }
      }
    }
  }
}

function triggerPatchQueue(namespace, screenName) {
  if(state.isPreRenderEnabled) {
    getScopedState(namespace).patchState[screenName].active = false;
    var nextPatch = (getScopedState(namespace).patchState[screenName].queue || []).shift();
    if(typeof nextPatch == "function") {
      nextPatch();
    } else {
      getScopedState(namespace).patchState[screenName].started = false;
    }
  } else {
    state.patchState[namespace][screenName].active = false;
    var nextPatch = (state.patchState[namespace][screenName].queue || []).shift();
    if(typeof nextPatch == "function") {
      nextPatch();
    } else {
      state.patchState[namespace][screenName].started = false;
    }
  }
}

exports.addToPatchQueue = function(namespace) {
  return function(screenName) {
    return function(patchFn) {
      return function () {
        if(state.isPreRenderEnabled) {
          getScopedState(namespace).patchState = getScopedState(namespace).patchState || {}
          getScopedState(namespace).patchState[screenName] = getScopedState(namespace).patchState[screenName] || {}
          getScopedState(namespace).patchState[screenName].queue = getScopedState(namespace).patchState[screenName].queue || []
          getScopedState(namespace).patchState[screenName].queue.push(patchFn);
          if(!getScopedState(namespace).patchState[screenName].started) {
            getScopedState(namespace).patchState[screenName].started = true;
            triggerPatchQueue(namespace, screenName);
          }
        } else {
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
}

exports.setPatchToActive = function(namespace) {
  return function(screenName) {
    return function () {
      if(state.isPreRenderEnabled) {
        getScopedState(namespace).patchState = getScopedState(namespace).patchState || {}
        getScopedState(namespace).patchState[screenName] = getScopedState(namespace).patchState[screenName] || {}
        if(getScopedState(namespace).patchState[screenName].counter > 0) {
            getScopedState(namespace).patchState[screenName].active = true;
        } else {
          triggerPatchQueue(namespace, screenName)
        }
      } else {
        state.patchState = state.patchState || {}
        state.patchState[namespace] = state.patchState[namespace] || {}
        state.patchState[namespace][screenName] = state.patchState[namespace][screenName] || {}
        if(state.patchState[namespace][screenName].counter > 0) {
          state.patchState[namespace][screenName].active = true;
        } else {
          triggerPatchQueue(namespace, screenName)
        }
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
  if(window.__OS == "IOS" ){
    x.push("testID");
  }
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
      if(x.indexOf(keyPropMap[id][prop]) != -1 || window.__OS == "WEB") {
        if(keyPropMap[id][prop] == "imageUrl" && window.__OS != "WEB") {
          try {
            new URL(listData[j][prop])
            listData[j][prop] = "url->" + listData[j][prop] + ","
          } catch (e) {
            var images = listData[j][prop].split(",");
            var imageUrl = "";
            if(images.length>1){
              imageUrl = images[0] +",";
              imageUrl = imageUrl + makeImageName(images[1]);
            }else{
              imageUrl = makeImageName(images[0]);
            }
            listData[j][prop] = imageUrl;
          }
        }
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
      if(window.__OS == "ANDROID" || window.__OS == "IOS" ) {
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
  return JSON.stringify(final)
}

exports.updateActivity = function (activityId) {
  return function () {
    var oldActivity = state.currentActivity;
    state.currentActivity = activityId;
    state.activityNamespaces[oldActivity] = state.activityNamespaces[oldActivity] || [];
    state.activityNamespaces[oldActivity].map(function(a) {
      tracker._trackAction("system")("info")("update_activity")({"activityId": activityId, "namespace": a})();
      if (typeof getScopedState(a) != "undefined") {
        return;
      }
      deleteScopedState(a, oldActivity);
      exports.setUpBaseState(a)()();
      exports.render(a);
    });
  }
}

exports.getCurrentActivity = function () {
  return state.currentActivity;
}

exports.cachePushEvents = function(namespace) {
  return function(screenName) {
    return function(efn) {
      return function(activityID){
        return function () {
          getScopedState(namespace, activityID).queuedEvents = getScopedState(namespace, activityID).queuedEvents || {}
          getScopedState(namespace, activityID).queuedEvents[screenName] = getScopedState(namespace, activityID).queuedEvents[screenName] || []
          getScopedState(namespace, activityID).queuedEvents[screenName].push(efn)
        }
      }
    }
  }
}

exports.isScreenPushActive = function(namespace) {
  return function(screenName) {
      return function(activityID){
        return function () {
            if(state.isPreRenderEnabled) {
              // Todo :: Fix setting up of scopedState
              state.scopedState[namespace][activityID] = getScopedState(namespace, activityID) || {}
            } else {
              namespace = getNamespace(namespace, activityID);
              // Todo :: Fix setting up of scopedState
              state.scopedState[namespace] = getScopedState(namespace, activityID) || {}
            }
            // Todo :: Repetition of line 1803
            state.scopedState[namespace][activityID] = getScopedState(namespace, activityID) || {}
            getScopedState(namespace, activityID).pushActive = getScopedState(namespace, activityID).pushActive || {}
            return getScopedState(namespace, activityID).pushActive[screenName] || false;
        }
      }
  }
}

exports.setScreenPushActive = function(namespace) {
  return function(screenName) {
    return function(activityID){
      return function () {
        getScopedState(namespace, activityID).pushActive = getScopedState(namespace, activityID).pushActive || {}
        getScopedState(namespace, activityID).queuedEvents = getScopedState(namespace, activityID).queuedEvents || {}
        getScopedState(namespace, activityID).pushActive[screenName] = true
        while(getScopedState(namespace, activityID).queuedEvents[screenName] && getScopedState(namespace, activityID).queuedEvents[screenName][0]) {
          getScopedState(namespace, activityID).queuedEvents[screenName].shift()();
        }
      }
    }
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
function prepareDom (dom, name, namespace){
  if(dom.props && dom.props.hasOwnProperty('id') && (dom.props.id).toString().trim()){
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  }else{
    dom.__ref = window.createPrestoElement();
  }

  if(dom.props) {
    dom.props.root = true;
  }
  getConstState(namespace).screenHideCallbacks[name] = hideViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenShowCallbacks[name] = showViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenRemoveCallbacks[name] = removeViewFromNameSpace(namespace, dom.__ref.__id)
  return dom;
}

/**
 * returns Nothing if __CACHED_MACHINE don't have machine
 * This function will make sure that addScreen logic don't get executed
 * if machine not present.
 *
 */
exports.getCachedMachineImpl = function(just,nothing,namespace,screenName) {
  if (window.__OS === "ANDROID"){
    var machine;
    if (state.isPreRenderEnabled) {
      machine = getConstState(namespace).cachedMachine ? getConstState(namespace).cachedMachine[screenName] : null;
    } else {
      var curNamespace = getNamespace(namespace);
      machine = state.cachedMachine.hasOwnProperty(curNamespace) ? state.cachedMachine[curNamespace][screenName] : null;
    }
    if (machine != null && (typeof machine == "object")){
      return just(machine);
    } else {
      return nothing;
    }
  } else {
    return nothing;
  }
}

/**
 * Will be called after patch on screen is complete. It'll set visiblity to visible
 * again, and then start animation on atttached screen.
 * @param {object} dom - dom object to get ID
 * @param {String} screenName - to start animation
 * @return {void}
 */
exports.addScreenWithAnim = function (dom,  screenName, namespace){
  if (window.__OS == "ANDROID") {
  //   var namespace = getNamespace(namespace_);
    if(!state.isPreRenderEnabled) namespace = getNamespace(namespace)
    makeRootVisible(namespace);
    exports.makeScreenVisible(namespace, screenName);
    executePostProcess(screenName, namespace, false)();
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
   */
  for(var i =0; i< scrollViewIDs.length; i++){
    cmdScrollViewReset += "set_view=ctx->findViewById:i_"+ scrollViewIDs[i] +";get_view->scrollTo:i_0,i_0;";
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

exports.startedToPrepare = function(namespace, screenName){
  if(getConstState(namespace)){
    getConstState(namespace)[screenName] = getConstState(namespace)[screenName] || {};
    getConstState(namespace)[screenName].prepareStarted = true;
    getConstState(namespace)[screenName].prepareStartedQueue = [];
  }
}

exports.awaitPrerenderFinished = function(namespace, screenName, cb){
  if(getConstState(namespace) && getConstState(namespace)[screenName] && getConstState(namespace)[screenName].prepareStarted){
    getConstState(namespace)[screenName].prepareStartedQueue = getConstState(namespace)[screenName].prepareStartedQueue || [];
    getConstState(namespace)[screenName].prepareStartedQueue.push(cb);
  }else{
    cb();
  }
}

const ensureScopeStateExists = function(namespace) {
  const activityIDToUse = state.currentActivity;
  state.scopedState[namespace] = state.scopedState[namespace] || {}
  state.scopedState[namespace][activityIDToUse] = state.scopedState[namespace][activityIDToUse] || {}
}

const setFragmentIdInScopedState = function (namespace, id) {
  ensureScopeStateExists(namespace);
  getScopedState(namespace).id = id;
};

function clearStoredID () {
  if (typeof(window.__preRenderIds) === "object" && Android.runInUI && window.__OS == "ANDROID"){
    var cmd = ""
    for (var key in window.__preRenderIds) {
      cmd += "set_v=ctx->findViewById:i_" + window.__preRenderIds[key] + ";get_v->removeAllViews;"
    }
    Android.runInUI(cmd, null);
  }
}

exports.setPreRender = function (screenName) {
  return function (namespace) {
    return function () {
      getConstState(namespace).prerenderScreens.push(screenName);
    }
  }
}

exports.getTimeInMillis = function(){
    return Date.now();
}

exports.setScreenInActive = function (ns) {
  return function (screen) {
    return function () {
      getScopedState(ns).screenActive[screen] = false
    }
  }
}
exports.setScreenActive = function (ns) {
  return function (screen) {
    return function () {
      getScopedState(ns).screenActive[screen] = true
    }
  }
}

exports.isScreenActive = function (ns) {
  return function (screen) {
    return function () {
      return getScopedState(ns).screenActive[screen]
    }
  }
}
