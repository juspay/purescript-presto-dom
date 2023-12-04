import * as prestoUI from "presto-ui";
const prestoDayum = prestoUI.doms;
const callbackMapper = prestoUI.callbackMapper;
var webParseParams, iOSParseParams, androidParseParams, lastScreen = [], screenTransition = {}, last = "";

if (window.__OS === "WEB") {
  webParseParams = prestoUI.helpers.web.parseParams;
} else if (window.__OS == "IOS") {
  iOSParseParams = prestoUI.helpers.ios.parseParams;
} else {
  androidParseParams = prestoUI.helpers.android.parseParams;
}

export const addTime3 = addTime

function addTime(_screen){
  return function(){
    try{
      var lastIndex = _screen.lastIndexOf("_")
      var x = [_screen.slice(0,lastIndex), _screen.slice(lastIndex + 1)]
      screenTransition = screenTransition || {}
      screenTransition[_screen] = Date.now()
      if(lastScreen.length > 0){
        if(x[x.length-1].toLowerCase() === "rendered"){
          window.latency = window.latency || {}
          window.latency[x[0]] = screenTransition[_screen] - screenTransition[last + "_Exited"]
          tracker._trackAction("system")("info")("screenLatency")({"currentScreen" : x[0], "lastScreen" : last, "latency" : window.latency[x[0]]})()
          lastScreen.push(x[0])
        }else if(x[x.length-1].toLowerCase() === "exited"){
          last = lastScreen.length > 1 ? lastScreen.pop() : lastScreen[lastScreen.length - 1]
        }
      }else{
        lastScreen.push(x[0])
      }
    }catch(e){
      tracker._trackAction("system")("info")("screenLatency")({"exception" : e})()
    }
  }
}
function isImagePresent(imageName){
  if(window.juspayAssetConfig
    && window.juspayAssetConfig.images
    && (window.juspayAssetConfig.images[imageName]
      ||window.juspayAssetConfig.images["jp_"+imageName])
  ) return true;
  return false;
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
      return window.Android.removeView(id);
    }
    android.updateProperties = function (cmd, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return window.Android.updateProperties(cmd);
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
          return s4() + s4() + "-" + s4() + "-" + s4() + "-" +
                  s4() + "-" + s4() + s4() + s4();
        }
        top.addToContainerList = function(id_, namespace_) {
          // Namespace not needed, for cases where we do not have merchant fragment
          var uuid = generateUUID()
          top.fragments[uuid] = id_;
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
      if(nsps === null || nsps == undefined || typeof top.fragments[nsps] != "number") {
        return window.Android.render(domString, snd, trd)
      }
      var rootId = top.fragments[nsps] + "";
      return window.Android.addViewToParent(rootId, domString, 0, null, null)
    }
    android.addViewToParent = function(rootId, domString, position, callback, fth, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return window.Android.addViewToParent(rootId, domString, position, callback, fth)
    }
    android.replaceView = function(domString, id, ns) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return window.Android.replaceView(domString, id);
    }
    android.moveView = function(id, index, ns) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return window.Android.moveView(id, index);
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
  , pixels : window.__OS == "ANDROID" ? window.JBridge.getPixels() : 1.0
  , generator : false
}

export const setGenerator = function(value) {
  return function() {
    state.generator = value
  }
}

const loopedFunction = function(){
  return loopedFunction
}

const getTracker = function () {
  var trackerJson = window.JOS.tracker || {};
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
      const preRenderVersion = window.JBridge.getResourceByName("pre_render_version");
      const rawClientId = window.__payload
        && window.__payload.payload
        ? window.__payload.payload.clientId || window.__payload.payload.client_id || "common"
        : "common";
      const clientId = rawClientId.split("_")[0];
      const sdkConfigFile = JSON.parse(window.JBridge.loadFileInDUI("sdk_config.json") || "");
      if(sdkConfigFile.preRenderConfig && typeof sdkConfigFile.preRenderConfig == "object") {
        const versionFromConfig = (sdkConfigFile.preRenderConfig[clientId] || sdkConfigFile.preRenderConfig.common || "");
        if(versionFromConfig !== "") {
          isSupported = preRenderVersion.localeCompare(versionFromConfig, undefined, { numeric: true, sensitivity: "base" }) >= 0;
        }
      }

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
    return Object.prototype.hasOwnProperty.call(state.scopedState,namespace)
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
export const getNamespace = function (namespace, activityID) {
  var id = activityID || state.currentActivity
  if (namespace && namespace.indexOf(id) == -1) {
    namespace = namespace + id;
  }
  return namespace
}

const deleteScopedState = function (namespace, activityID) {
  var id = activityID || state.currentActivity;
  if(getScopedState(namespace) && getScopedState(namespace).childNamespaces && getScopedState(namespace).childNamespaces.length > 0){
    for(var i = 0; i < getScopedState(namespace).childNamespaces.length; i++){
      deleteScopedState(getScopedState(namespace).childNamespaces[i])
    }
  }
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
    // eslint-disable-next-line no-undef
    return getIdFromNamespace(id)
  }
};

export const isAndroid = function () {
  return window.__OS == "ANDROID";
}


function getPrestoID() {
  if (window.__OS === "WEB") {
    return 1;
  }

  return top.__PRESTO_ID ? ++top.__PRESTO_ID : 1;
}


export function createPrestoElement() {
  if (
    typeof window.__ui_id_sequence != "undefined" &&
    window.__ui_id_sequence !== null
  ) {
    return {
      __id: ++window.__ui_id_sequence
    };
  } else {
    // dividing id by 10 if ssr is generating the id’s, so that we don’t get duplicate id’s at client Side
    var factor = 1000000;
    factor = window.parent.generateVdom ? factor/10 : factor;
    window.__ui_id_sequence =
      typeof window.Android.getNewID == "function"
        ? (parseInt(window.Android.getNewID()) * factor) % 100000000
        : (window.__PRESTO_ID || getPrestoID() * factor) % 100000000;
    return {
      __id: ++window.__ui_id_sequence
    };
  }
}

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
  var elemType = obj.elemType;
  var keyId = obj.keyId;

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

  if(window.__OS == "WEB"){
    return prestoDayum(type, props, children, elemType, keyId);
  }
  return prestoDayum(type, props, children);
}

export const parseProps = parsePropsImpl;

function isRecyclerViewSupported(){
  var isSupported = false;
  if(window.__OS == "ANDROID"){
    try{
      const prestoListVersion = window.JBridge.getResourceByName("presto_list_version");
      const prestoUIVersion = window.presto_ui_version;
      isSupported = prestoListVersion >= 1.0 && prestoUIVersion >= 1.0;
    } catch(e) {
      // trackExceptionWrapper("recycler_view_support", "error in getting presto list version for recycler view", e);
    }
  }
  return isSupported;
}


const addItToQuee = (namespace,screenName,rootId,patch) => {
  if (getConstState(namespace).prerenderScreens.indexOf(screenName) != -1) {
    getConstState(namespace).waitingIcons[screenName][rootId] = getConstState(namespace).waitingIcons[screenName][rootId] || [];
    getConstState(namespace).waitingIcons[screenName][rootId].push(patch)
  }
  getScopedState(namespace).waitingIcons[screenName][rootId] = getScopedState(namespace).waitingIcons[screenName][rootId] || [];
  getScopedState(namespace).waitingIcons[screenName][rootId].push(patch);
}
export const patchDownloadedImages =
  namespace => screenName => rootId =>
    patch => {
      if(isViewRootAttached(namespace,screenName,rootId)) {
        patch();
      } else {
        addItToQuee(namespace,screenName,rootId,patch);
      }

    }
const isViewRootAttached = (namespace,screenName,rootId) => {
  const rootAttached = getAttachedRoots(namespace,screenName);
  return rootAttached[rootId];
}


function getAttachedRoots(namespace,screenName) {
  getScopedState(namespace).rootAttached = getScopedState(namespace).rootAttached || {};
  getScopedState(namespace).rootAttached[screenName] = getScopedState(namespace).rootAttached[screenName] || {};
  return getScopedState(namespace).rootAttached[screenName];
}
function patchAwaitingImages(namespace,screenName,rootId) {
  if (getConstState(namespace).prerenderScreens.indexOf(screenName) != -1) {
    getConstState(namespace).waitingIcons[screenName][rootId] = [];
  }
  getAttachedRoots(namespace,screenName)[rootId] = true;
  getScopedState(namespace).waitingIcons = getScopedState(namespace).waitingIcons || {};
  getScopedState(namespace).waitingIcons[screenName] = getScopedState(namespace).waitingIcons[screenName] || {}
  let loadingImages = getScopedState(namespace).waitingIcons[screenName][rootId] || [];
  while(loadingImages.length > 0) loadingImages.pop()();
  delete getScopedState(namespace).waitingIcons[screenName][rootId];
}
function parsePropsImpl(elem, screenName, VALIDATE_ID, namespace, parentType, isRoot) {
  if(elem.type == "listView" && isRecyclerViewSupported()){
    elem.type = "recyclerView";
  }
  if (Object.prototype.hasOwnProperty.call(elem.props,"id") && elem.props.id != "" && (elem.props.id).toString().trim() != "") {
    var id = (elem.props.id).toString().trim();
    elem.__ref = {__id: id };
    if (Object.prototype.hasOwnProperty.call(VALIDATE_ID,id)){
      console.warn("Found duplicate ID! ID: "+ id +
        " maybe caused because of overriding `id` prop. This may produce unwanted behavior. Please fix..");
    } else {
      VALIDATE_ID[id] = "used";
    }
  } else if(!elem.__ref) {
    elem.__ref = createPrestoElement()
  }
  let elemId = elem.__ref.__id;
  var type = prestoUI.prestoClone(elem.type);
  var props = prestoUI.prestoClone(elem.props);
  if(isRoot) {
    let newAfterRender = () => {};
    if (getConstState(namespace).prerenderScreens.indexOf(screenName) != -1) {
      getConstState(namespace).waitingIcons = getConstState(namespace).waitingIcons || {};
      getConstState(namespace).waitingIcons[screenName] = getConstState(namespace).waitingIcons[screenName] || {}
      getConstState(namespace).waitingIcons[screenName][elemId] = [];
    }
    getScopedState(namespace).waitingIcons =  getScopedState(namespace).waitingIcons || {}
    getScopedState(namespace).waitingIcons[screenName] = getScopedState(namespace).waitingIcons[screenName] || {}
    getScopedState(namespace).waitingIcons[screenName][elemId] = [];
    if(props.afterRender) {
      newAfterRender = props.afterRender;
    }
    props.afterRender = () => {
      patchAwaitingImages(namespace,screenName,elemId);
      newAfterRender();
    }
  }

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
      , elemId
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
      setUpBaseState(props.namespace)(null)();
      // Mark that this is not pre-render
      getConstState(props.namespace).hasRender = true
      var newElem = getScopedState(props.namespace).root
      newElem.props = props;
      newElem.props.afterRender = markRootReady(props.namespace);
      getScopedState(namespace).childNamespaces = getScopedState(namespace).childNamespaces || [];
      getScopedState(namespace).childNamespaces.push(props.namespace);
      return parsePropsImpl(newElem, screenName, VALIDATE_ID, namespace)
    }
  }
  if(Object.prototype.hasOwnProperty.call(props,"afterRender")) {
    if (getConstState(namespace).prerenderScreens.indexOf(screenName) != -1) {
      getConstState(namespace).afterRenderFunctions[screenName] = getConstState(namespace).afterRenderFunctions[screenName] || []
      getConstState(namespace).afterRenderFunctions[screenName].push(props.afterRender)
    }
    getScopedState(namespace).afterRenderFunctions[screenName] = getScopedState(namespace).afterRenderFunctions[screenName] || []
    getScopedState(namespace).afterRenderFunctions[screenName].push(props.afterRender)
    delete props.afterRender
  }
  if (Object.prototype.hasOwnProperty.call(elem,"chunkedLayout") && elem.chunkedLayout) {
    elem.children.forEach(function(e, i) {
      getScopedState(namespace).actualLayouts.push({"layout": elem.layouts[i], "shimmerId": e.__ref.__id, "parent": elem, "index": i});
    });
  }
  if (
    props.entryAnimation ||
    props.entryAnimationF ||
    props.entryAnimationB
  ) {
    if (props.onAnimationEnd) {
      var callbackFunction = props.onAnimationEnd;
      var updatedCallback = function(_event) {
        getScopedState(namespace).activateScreen = true;
        hideOldScreenNow(namespace, screenName);
        callbackFunction(_event);
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
    if (window.__OS == "ANDROID") {
      // Incase of pre-render we need to get default values for entry animation, so that we can reset the same
      var x = JSON.parse(props.entryAnimationF)
      var y = {id : elem.__ref.__id}
      for (var i = 0; i < x.length; ++i) {
        // for pre-render cases
        y.alpha = y.alpha  || x[i].fromAlpha
        y.translationX = y.translationX  || x[i].fromX && (x[i].fromX * state.pixels)
        y.translationY = y.translationY  || x[i].fromY && (x[i].fromY * state.pixels)
        y.scaleX = y.scaleX  || x[i].fromScaleX
        y.scaleY = y.scaleY  || x[i].fromScaleY
        y.rotation = y.rotation  || x[i].fromRotation
        y.rotationX = y.rotationX  || x[i].fromRotationX
        y.rotationY = y.rotationY  || x[i].fromRotationY
      }
      getConstState(namespace).animations.entryF[screenName].command = getConstState(namespace).animations.entryF[screenName].command || "";
      getConstState(namespace).animations.entryF[screenName].command += cmdForAndroid(y, true, type).runInUI
    }
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
  if (window.__OS == "WEB" && props.onResize) {
    window.__resizeEvent = props.onResize;
  }
  props.id = elem.__ref.__id;
  // Both elemType and keyId are empty strings, so setting it to undefined when elem.elemType is empty string
  var elemType = elem.elemType ? elem.elemType : undefined;
  var keyId = elem.keyId ? elem.keyId : undefined;
  return {elemId,dom : { type : type, props:props, children:elem.children, parentType : elem.parentType || parentType, __ref : elem.__ref, elemType : elemType, keyId : keyId} , ids : VALIDATE_ID}
}

function hideOldScreenNow(namespace, screenName) {
  var sn = screenName;
  while(getScopedState(namespace).hideList.length > 0) {
    let screenName_ = getScopedState(namespace).hideList.pop();
    let cb = getConstState(namespace).screenHideCallbacks[screenName_];
    if(typeof cb == "function") {
      cb();
    }
  }
  while(getScopedState(namespace).removeList.length > 0) {
    let screenName_ = getScopedState(namespace).removeList.pop();
    let cb = getConstState(namespace).screenRemoveCallbacks[screenName_]
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
      let obj = parseParams(type, config, "set");
      let cmd = obj.runInUI
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
  let cmd = "set_view=ctx->findViewById:i_" + id + ";";
  config.__id = config.id
  delete config.id;
  config.root = "true";
  let obj = parseParams(type, config, "get");
  obj.runInUI = cmd + obj.runInUI + ";";
  obj.id = id;
  return obj;
}

export const callAnimation = callAnimation__

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
        // Pop the stack to the current screen
        getConstState(namespace).animations.animationStack = getConstState(namespace).animations.animationStack.slice(0, getConstState(namespace).animations.animationStack.indexOf(screenName) + 1);
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
      if(state.isPreRenderEnabled) {
        if (getConstState(namespace).cachedMachine && Object.prototype.hasOwnProperty.call(getConstState(namespace).cachedMachine,screenName)){
          getConstState(namespace).animations.prerendered.push(screenName)
        }
      } else {
        var namespace_ = getNamespace(namespace);
        if (Object.prototype.hasOwnProperty.call(state.cachedMachine,namespace_) && Object.prototype.hasOwnProperty.call(state.cachedMachine[namespace_],screenName)){
          getConstState(namespace).animations.prerendered.push(screenName)
        }
      }
      var previousScreen = getConstState(namespace).animations.animationStack[getConstState(namespace).animations.animationStack.length - 1]
      animationArray.push({ screenName : previousScreen, tag : "exitF"})
      if (getConstState(namespace).animations.prerendered.indexOf(screenName) != -1){
        animationArray.push({ screenName : screenName, tag : "entryF", resetAnimation : true})
      }
      getScopedState(namespace).hideList.push(previousScreen);
      getConstState(namespace).animations.animationStack.push(screenName);
    }
  }
  callAnimation_(namespace, animationArray, screenName)
  getConstState(namespace).animations.lastAnimatedScreen = screenName;
}

function callAnimation_ (namespace, screenArray, screenName) {
  window.enableBackpress = false;
  var hasAnimation = false;
  screenArray.forEach(
    function (animationJsonTemp) {
      if (getConstState(namespace).animations[animationJsonTemp.tag] && getConstState(namespace).animations[animationJsonTemp.tag][animationJsonTemp.screenName]) {
        var animationJson = getConstState(namespace).animations[animationJsonTemp.tag][animationJsonTemp.screenName]
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
          // Reset animation is passed so that native code treats this as a new animation every time.
          // Animations are skipped if there are no changes from the last run animation
          if (animationJsonTemp.resetAnimation) {
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

      if(window.__payload && typeof window.__payload == "object" && typeof window.__payload.requestId == "string") {
        var service = window.JOS && typeof window.JOS.self == "string" ? window.JOS.self : null;
        x["lifeCycleId"] = typeof window.__payload.lifeCycleId == "string" ?
          window.__payload.lifeCycleId :
          (typeof window.JBridge.getSessionId == "function" ?
            ("sdk:" + window.JBridge.getSessionId()) : "")
        if(service) {
          var splitedService = service.split(".");
          service = splitedService[splitedService.length - 1];
          x["lifeCycleId"] += "/" + service + ":" + window.__payload.requestId;
        }
      }

      if (cachedObject.useStartApp) {
        window.JOS.startApp(cachedObject.service)(x)(cb)()
      } else if(window.JOS && typeof window.JOS.isMAppPresent == "function" &&  typeof window.JOS.isMAppPresent(cachedObject.service) == "function" && window.JOS.isMAppPresent(cachedObject.service)()) {
        window.JOS.emitEvent(cachedObject.service)("onMerchantEvent")(["process", JSON.stringify(x)])(cb)();
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

// This function is called just after patching is done, all addEventListeners stored are fired at once, and also vdomCached has an array of screen Names for which vdom is generated by server (currently only PP)
export const postAccess = function(nam, namespace, cache){
  AndroidWrapper.addEventListeners(getConstState(namespace).addEventListeners[nam]);
  executePostProcess(nam, namespace, cache)()
  getConstState(namespace).addEventListeners[nam] = []
  getConstState(namespace).vdomCached = []
}

function storeEndlatency () {
  let endTime = Date.now();
  window.timeCheck["Render_runScreen_End"] = endTime;
  window.timeCheck["Render_renderOrPatch_End"] = endTime;
  window.timeCheck["Render_addViewToParent_End"] = endTime;
}

function executePostProcess(nam, namespace, cache) {
  return function(a) {
    if(a != undefined && typeof a == "string" && a.toLowerCase() == "failure"){
      tracker._trackAction("system")("error")("execute_post_process")({"namespace":namespace, "name":nam, "callbackWithParam": a})();
    } else {
      tracker._trackAction("system")("info")("execute_post_process")({"namespace":namespace, "name":nam, "callbackWithParam": a})();
    }
    storeEndlatency();
    callAnimation__(nam, namespace, cache);
    processMapps(namespace, nam, 75);
    triggerAfterRender(namespace, nam);
    triggerChunkCascade(namespace, nam);
    addTime(nam + "_Rendered")();
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

export const checkAndDeleteFromHideAndRemoveStacks = function (namespace, screenName) {
  try {
    let index = getScopedState(namespace).hideList.indexOf(screenName)
    if(index != -1) {
      delete getScopedState(namespace).hideList[index];
    }
    index = getScopedState(namespace).removeList.indexOf(screenName)
    if(index != -1) {
      delete getScopedState(namespace).removeList[index];
    }
  } catch(e) {
    // Ignored this will happen ever first time for each screen
  }
}

export function setUpBaseState (namespace) {
  return function (id) {
    return function () {
      window.parent.serverSideKeys = window.parent.serverSideKeys || {};
      tracker._trackAction("system")("info")("setup_base_state")({"namespace":namespace, "id":id, "isMultiActivityPreRenderSupported": state.isPreRenderEnabled})();
      if(typeof getScopedState(namespace) != "undefined" && getScopedState(namespace).root && typeof getConstState(namespace) !== "undefined" && getConstState(namespace).hasRender) {
        terminateUIImpl()(namespace);
      }else if(typeof getScopedState(namespace) != "undefined" && getScopedState(namespace).root){
        getScopedState(namespace).id = id
        return;
      }
      if(!state.isPreRenderEnabled) namespace = getNamespace(namespace)
      if (state.currentActivity !== "") {
        var ns = namespace;
        if(!state.isPreRenderEnabled) ns = namespace.substr(0, namespace.length - state.currentActivity.length);
        state.activityNamespaces[state.currentActivity] = state.activityNamespaces[state.currentActivity] || [];
        state.activityNamespaces[state.currentActivity].push(ns);
      }
      // var _namespace = "";
      setFragmentIdInScopedState(namespace, id);
      state.fragments[id || "null"] = namespace;

      var elemRef, stackRef, cacheRef;

      var idCache = window.parent.serverSideKeys.idCache && window.parent.serverSideKeys.idCache[window.JOS.self];

      // Using cached id’s at client Side when SSR has already generated them
      // Client side patching over server side rendered html
      if(window.parent.generateVdom === false && idCache){
        elemRef = idCache.elemRef;
        stackRef = idCache.stackRef;
        cacheRef = idCache.cacheRef;
      } else {
        // Server side rendering
        // or
        // Client side rendering without any existing SSR content
        elemRef = createPrestoElement();
        stackRef = createPrestoElement();
        cacheRef = createPrestoElement();

        // Server side rendering, to store ids in window variable for injecting into SSR generated html
        if(window.parent.generateVdom){
          window.parent.serverSideKeys.idCache = window.parent.serverSideKeys.idCache ? window.parent.serverSideKeys.idCache : {};
          window.parent.serverSideKeys.idCache[window.JOS.self] = { elemRef : elemRef, stackRef : stackRef, cacheRef : cacheRef };
        }
      }

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

      if (!Object.prototype.hasOwnProperty.call(state.constState,namespace)){
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
        getConstState(namespace).vdomCached = []
        getConstState(namespace).addEventListeners = {}
      }
      // https://juspay.atlassian.net/browse/PICAF-6628
      getScopedState(namespace).afterRenderFunctions = prestoUI.prestoClone( getConstState(namespace).afterRenderFunctions || {});
      getScopedState(namespace).waitingIcons = prestoUI.prestoClone(getConstState(namespace).waitingIcons || {});
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
    let state_ = getScopedState(namespace)
    if(state_) {
      state_.rootReady = true
      while(state_.awaitRootReady.length > 0) {
        var cb = state_.awaitRootReady.pop()
        if(typeof cb == "function") {
          cb();
        }
      }
    }
  }
}

export const awaitRootReady = function(namespace) {
  return function (cb) {
    return function() {
      let state_ = getScopedState(namespace)
      if((state_ && state_.rootReady)|| state.generator) {
        cb()();
      } else if (state_) {
        state_.awaitRootReady.push(cb());
      } else {
        console.error("Call initUI for Namespace :: ", namespace)
      }
    }
  }
}

export const render = function (namespace) {
  getConstState(namespace).hasRender = true
  var id = getIdFromNamespace(namespace);
  var cb = callbackMapper.map(markRootReady(namespace));
  if(window.__OS == "ANDROID") {
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
    var useStoredDiv = (window.parent.serverSideKeys && window.parent.serverSideKeys.vdom && window.parent.serverSideKeys.vdom["dom"]) ? true : false; // Need to take Screen Name too, have to be fixed when ssr is moved to initiate
    AndroidWrapper.Render(domAll(getScopedState(namespace).root, "base", namespace), cb, getIdFromNamespace(namespace), useStoredDiv); // Add support for Web
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
      top.setAddRootScreen(window.JOS.self + "::" + namespace);
    }
  } catch (e) {

  }
}

export const insertDom = function(namespace, _name, dom, cache) {
  if(!getScopedState(namespace)) {
    console.error("Call initUI for namespace :: " + namespace + "before triggering run/show screen")
    return;
  }
  if(!getScopedState(namespace).rootVisible) {
    makeRootVisible(namespace);
  }

  getConstState(namespace).animations.entry[_name] = {}
  getConstState(namespace).animations.exit[_name] = {}
  getConstState(namespace).animations.entryF[_name] = {}
  getConstState(namespace).animations.exitF[_name] = {}
  getConstState(namespace).animations.entryB[_name] = {}
  getConstState(namespace).animations.exitB[_name] = {}
  getScopedState(namespace).root.children.push(dom);
  if (dom.props && Object.prototype.hasOwnProperty.call(dom.props,"id") && (dom.props.id).toString().trim()) {
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  } else {
    dom.__ref = createPrestoElement();
  }
  if(dom.props) {
    dom.props.root = true
  }
  var rootId = cache ? getScopedState(namespace).cacheRoot : getScopedState(namespace).stackRoot
  var len = cache ? getScopedState(namespace).screenCache.length : getScopedState(namespace).screenStack.length
  // TODO implement cache limit later
  getConstState(namespace).screenHideCallbacks[_name] = hideViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenShowCallbacks[_name] = showViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenRemoveCallbacks[_name] = removeViewFromNameSpace(namespace, dom.__ref.__id)
  var callback = callbackMapper.map(executePostProcess(_name, namespace, cache))
  return {
    rootId : window.__OS == "ANDROID" ? rootId + "" : rootId
    , dom : dom
    //, name, namespace
    , length : len -1
    , callback : callback
    , id : getIdFromNamespace(namespace)
  }
}

export const addViewToParent = function (insertObject) {
  var dom = insertObject.dom
  // Storing the vdom, inside window.parent.serverSideKeys.vdom
  if (window.parent.generateVdom) {
    window.parent.serverSideKeys = window.parent.serverSideKeys || {};
    window.parent.serverSideKeys.vdom = JSON.stringify(insertObject);
  }
  AndroidWrapper.addViewToParent(
    insertObject.rootId,
    window.__OS == "ANDROID" ? JSON.stringify(dom) : dom,
    insertObject.length,
    insertObject.callback,
    null,
    insertObject.id
  );
}

export const prepareAndStoreView = function (callback, dom, key, namespace, screenName){
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
  window.Android.prepareAndStoreView(
    key,
    window.__OS == "ANDROID" ? JSON.stringify(dom) : dom,
    callB
  );
}

export const attachScreen = function(namespace, _name, dom){
  if(!namespace) {
    console.error("Call initUI for namespace :: " + namespace + "before triggering run/show screen")
    return;
  }
  if (window.__OS == "ANDROID") {
    var rootId = getScopedState(namespace).stackRoot;
    var len = getScopedState(namespace).screenStack.length;
    var screenName = namespace + _name

    var cmds = getScrollViewResetCmds(dom);
    // Add commands which set default value for screen position
    cmds += getConstState(namespace).animations.entryF[_name].command
    window.Android.addStoredViewToParent(
      rootId + "",
      screenName,
      len - 1,
      null,
      null,
      cmds
    );
  }else{
    console.warn("Implementation of addScreen function missing for "+ window.__OS );
  }
}

export const storeMachine = function (dom, _name, namespace) {
  if(state.isPreRenderEnabled) {
    getScopedState(namespace).MACHINE_MAP[_name] = dom;
    if (getConstState(namespace).cachedMachine &&
        Object.prototype.hasOwnProperty.call(getConstState(namespace).cachedMachine,_name)){
      getConstState(namespace).cachedMachine[_name] = dom;
    }
  } else {
    let namespace_ = getNamespace(namespace);
    state.scopedState[namespace_].MACHINE_MAP[_name] = dom;
    if (Object.prototype.hasOwnProperty.call(state.cachedMachine,namespace_) &&
         Object.prototype.hasOwnProperty.call(state.cachedMachine[namespace_],_name)){
      state.cachedMachine[namespace_][_name] = dom;
    }
  }

}

export const getLatestMachine = function (_name, namespace) {
  return getScopedState(namespace).MACHINE_MAP[_name];
}

export const cacheMachine = function(machine, screenName, namespace) {
  if(state.isPreRenderEnabled) {
    if (!getConstState(namespace).cachedMachine){
      getConstState(namespace).cachedMachine = {}
    }
    getConstState(namespace).cachedMachine[screenName] = machine;
  }
  else {
    var curNamespace = getNamespace(namespace);
    if (!Object.prototype.hasOwnProperty.call(state.cachedMachine,curNamespace)){
      state.cachedMachine[curNamespace] = {}
    }
    state.cachedMachine[curNamespace][screenName] = machine;
  }
};

export const isInStack = function (_name, namespace) {
  // Added || false to return false when value is undefined
  try {
    return getScopedState(namespace).screenStack.indexOf(_name) != -1
  } catch (e) {
    console.error( "Call initUI with for namespace :: " + namespace , e );
  }
  return false
}

export const isCached = function (_name, namespace) {
  // Added || false to return false when value is undefined
  try {
    return getScopedState(namespace).screenCache.indexOf(_name) != -1
  } catch (e) {
    console.error( "Call initUI with for namespace :: " + namespace , e );
  }
  return false
}

export const cancelExistingActions = function (_name, namespace) {
  // Added || false to return false when value is undefined
  delete getScopedState(namespace).pushActive[_name]
  try{
    if(getScopedState(namespace) && getScopedState(namespace).cancelers && typeof getScopedState(namespace).cancelers[_name] == "function") {
      getScopedState(namespace).cancelers[_name]();
    }
  }catch(e){
    console.error("cancelExistingActions:",e);
  }
}

export const saveCanceller = function (_name, namespace, canceller) {
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
    getScopedState(namespace).cancelers[_name] = canceller;
  }
  return namespace
}

export const terminateUIImplWithOutCallback = terminateUIImpl()
export const terminateUIImplWithCallback = terminateUIImpl;
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
    } else if ( window.JOS
      && window.JOS.parent
      && window.JOS.parent != "java"
      && getScopedState(namespace)
      && getScopedState(namespace).root
      && getScopedState(namespace).root.__ref
      && getScopedState(namespace).root.__ref.__id
    ) {
      AndroidWrapper.removeView(getScopedState(namespace).root.__ref.__id, getIdFromNamespace(namespace));
    } else {
      if ( window.JOS
        && window.JOS.parent
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
        var x = (top.removeRootScreen.bind(window))(window.JOS.self + "::" + namespace);
      }
    } catch (e) {
      // incase of exception from using top
    }
    deleteScopedState(namespace)
    if (window.__OS != "ANDROID") {
      deleteConstState(namespace)
    } else if (getConstState(namespace) && getConstState(namespace).animations) {
      getConstState(namespace).animations.animationStack = []
      getConstState(namespace).animations.animationCache = []
      getConstState(namespace).animations.lastAnimatedScreen = ""
    }
  }
}

export const setToTopOfStack = function (namespace, screenName) {
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

export const makeScreenVisible = function (namespace, _name) {
  try {
    var cb = getConstState(namespace).screenShowCallbacks[_name];
    if(typeof cb == "function") {
      cb()
    }
  } catch(e) {
    trackExceptionWrapper("make_screen_visible", {"namespace":namespace, "name":_name, "description": "Call InitUI first for the namespace"}, e);
  }
}

export const addToCachedList = function (namespace, screenName) {
  try {
    if(!(getScopedState(namespace).screenCache.indexOf(screenName)!= -1)) {
      getScopedState(namespace).screenCache.push(screenName);
    }
  } catch (e) {
    trackExceptionWrapper("add_to_cached_list", {"namespace":namespace, "name":screenName, "description": "Call InitUI first for the namespace"}, e);
  }
}

export const addChildImpl = function (namespace) {
  return function(screenName) {
    return function (child, _parent, index) {
      if (child.type === null) {
        console.warn("child null");
      }
      var cb = callbackMapper.map(function(){
        if (window.__OS ===  "WEB"){
          setTimeout(function(){
            processMapps(namespace, screenName, 75)
            triggerAfterRender(namespace, screenName)
          },500)
        } else {
          processMapps(namespace, screenName, 75)
          triggerAfterRender(namespace, screenName)
        }
      }
      )
      // console.log("Add child :", child.__ref.__id, child.type);
      child.parentType = _parent.type;
      if(child.props && (!child.props.id) && child.__ref) {
        child.props.id = child.__ref.__id
      }
      return { rootId : window.__OS == "ANDROID" ? _parent.__ref.__id + "" : _parent.__ref.__id
        , dom : child
        , length : index
        , callback : cb
        , id :  getIdFromNamespace(namespace)
      }
    }
  }
}

export const addProperty = function (namespace) {
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
    Object.prototype.hasOwnProperty.call(prop,"focus") &&
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

export const replaceView = function (namespace) {
  return function(screenName){
    return function (element, _event, removedProps) {
      // console.log("REPLACE VIEW", element.__ref.__id, element.props);
      if(window.parent.generateVdom){
        return
      }
      var props = prestoUI.prestoClone(element.props);
      // Sending children to prestoDayum in case of web, as for android it will crash for json.stringify
      var children = window.__OS == "WEB" ? prestoUI.prestoClone(element.children) : [];
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
        rep = prestoDayum(element.type, props, children);
      } else if (window.__OS == "ANDROID") {
        rep = prestoDayum(
          {
            elemType: element.type,
            parentType: element.parentNode.type
          },
          props,
          children
        );
      } else {
        rep = prestoDayum(element.type, props, children);
      }
      if (window.__OS == "ANDROID") {
        AndroidWrapper.replaceView(
          JSON.stringify(rep)
          , element.__ref.__id
          , getIdFromNamespace(namespace)
        );
      } else if(getConstState(namespace).vdomCached.indexOf(screenName) != -1 && _event != ""){
        // When vdomCached, all addEventListeners are stored in the array and fired together
        parsePropsImpl(element, screenName, {}, namespace)
        var el = {view : rep, id : element.__ref.__id, event : _event}
        getConstState(namespace).addEventListeners[screenName] = getConstState(namespace).addEventListeners[screenName] || []
        getConstState(namespace).addEventListeners[screenName].push(el)
      } else{
        AndroidWrapper.replaceView(rep, element.__ref.__id, getIdFromNamespace(namespace));
      }
      if (removedProps !== null && removedProps.length >0 && removedProps.indexOf("handler/afterRender") != -1){
        if (window["afterRender"] && window["afterRender"][window.__dui_screen]) {
          delete window["afterRender"][window.__dui_screen][element.__ref.__id];
        }
      }
    }
  }
}

export const cancelBehavior = function (ty) {
  var canceler = window.__CANCELER[ty];
  canceler();
}



export const moveChild = function(namespace) {
  return function (child, _parent, index) {
    AndroidWrapper.moveView(child.__ref.__id, index, getIdFromNamespace(namespace));
  }
}

export const removeChild = function(namespace) {
  return function(child, _parent, index) {
    AndroidWrapper.removeView(child.__ref.__id,  getIdFromNamespace(namespace));
  }
}
export const updatePropertiesImpl = function (namespace) {
  return function(screenName){
    return function (props, el) {
      if(window.parent.generateVdom){
        return
      }
      for(var key in props) {
        el.props[key] = props[key];
      }
      if(getConstState(namespace).vdomCached.indexOf(screenName) != -1){
        parsePropsImpl(el,screenName,{},namespace);
      }
      // TODO evaluate all the set = true / false logic
      // Looks wrong
      applyProps(el, props, false, namespace)
    }
  }
}


export function setManualEvents (namespace) {
  return function(_screen) {
    return function(eventName) {
      return function(callbackFunction) {
        return function() {
          var screenName = _screen;
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

export const fireManualEventWithOutNameSpace = fireManualEvent()

export const fireEventToScreen = function (namespace) {
  return function (screenName) {
    return fireManualEvent(namespace, screenName)
  }
}

function fireManualEvent (namespace, nam) {
  return function (eventName) {
    return function (payload) {
      return function() {
        let screenName = (getScopedState(namespace) || {}).activeScreen
        if(namespace && (nam == screenName || !nam)) {
          try {
            if(getConstState(namespace) && getConstState(namespace).registeredEvents && Object.prototype.hasOwnProperty.call(getConstState(namespace).registeredEvents,eventName)) {
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
            if(getScopedState(key) && getConstState(key) && getConstState(key).registeredEvents && Object.prototype.hasOwnProperty.call(getConstState(key).registeredEvents,eventName)) {
              let screenName_ = getScopedState(key).activeScreen
              var isNotAnimating = getScopedState(key).activateScreen
              if(isNotAnimating && screenName_ && typeof getConstState(key).registeredEvents[eventName][screenName_] == "function")
                getConstState(key).registeredEvents[eventName][screenName_](payload);
            }
          }catch(e){
            console.warn("Failed at fireManualEvent", e);
          }
        }
      }
    }
  };
}

export const makeCacheRootVisible = function(namespace) {
  getScopedState(namespace).shouldHideCacheRoot = false;
  showViewInNameSpace(getScopedState(namespace).cacheRoot, namespace)();
}

const makeRootVisible = function(namespace) {
  getScopedState(namespace).rootVisible = true;
  showViewInNameSpace(getScopedState(namespace).rootId, namespace)();
}

export const hideCacheRootOnAnimationEnd = function(namespace) {
  getScopedState(namespace).shouldHideCacheRoot = true;
}

export const setControllerStates = function(namespace) {
  return function (screenName) {
    return function () {
      if(!getScopedState(namespace) || !getScopedState(namespace).root) {
        setUpBaseState(namespace)()();
      }
      getScopedState(namespace).activeScreen = screenName;
      getScopedState(namespace).activateScreen = true;
    }
  }
}

export const setUseHintColor = function (useHintColor) {
  return function(){
    if(window.__OS == "WEB" && typeof window.Android.setUseHintColor == "function") {
      window.Android.setUseHintColor(useHintColor);
    }
  }
}
export const replayFragmentCallbacksImpl = function (namespace) {
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
export const getAndSetEventFromState = function(namespace, screenName, def) {
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

export const processEventWithId = function (fragmentId) {
  var ns = state.fragments[fragmentId];
  if(ns)
    return fireManualEvent(ns)("update");
  else
    return function() { return function() {}}
}

export const updateMicroAppPayloadImpl = function (payload, element, isPatch) {
  element.props.payload = payload;
  if(isPatch) {
    let parsedPayload = JSON.parse( payload || {})
    parsedPayload.fragmentViewGroups = {}
    parsedPayload.fragmentViewGroups[element.props.viewGroupTag || "main"] = state.fragmentIdMap[element.requestId]
    var x = element.props.unNestPayload ? parsedPayload : {
      service : element.service
      , requestId : element.requestId
      , payload : parsedPayload
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
      if(window.JOS && typeof window.JOS.isMAppPresent == "function" &&  typeof window.JOS.isMAppPresent(element.service) == "function" && window.JOS.isMAppPresent(element.service)()) {
        let action = "update";
        if(element.props && element.props.useProcessForUpdate){
          action = "process";
        }
        window.JOS.emitEvent(element.service)("onMerchantEvent")([action, JSON.stringify(x)])(cb)();
      } else {
        cb(0)("error")()
      }
    }, 32);
  }
}

export const incrementPatchCounter = function(namespace) {
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

export const decrementPatchCounter = function(namespace) {
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
    let nextPatch = (getScopedState(namespace).patchState[screenName].queue || []).shift();
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

export const addToPatchQueue = function(namespace) {
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

export const setPatchToActive = function(namespace) {
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

export const parseParams = function (a,b, c) {
  // ADD OS CHECK
  if (window.__OS === "WEB") {
    return webParseParams(a,b,c);
  } else if (window.__OS == "IOS") {
    return iOSParseParams(a,b,c);
  } else {
    return androidParseParams(a,b,c);
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

const isURL = function (str) {
  try{
    const url = new URL(str);
    return true;
  } catch (err) {
    return false;
  }
}

export const getListDataCommands = function (listData, element) {
  var x = ["background", "imageUrl", "visibility", "fontStyle", "textSize", "packageIcon", "alpha", "text", "color", "onClick", "onInspectClick", "cornerRadius"]
  if(window.__OS == "IOS" ){
    x.push("testID");
    x.push("textFromHtml");
  }
  var y = [];
  var keyPropMap = state.listViewKeys[element.__ref.__id]
  var animPropMap = state.listViewAnimationKeys[element.__ref.__id]
  var final = [];
  for(var j = 0; j < listData.length; ++j) {
    let item = {};
    for(let id in keyPropMap) {
      var ps = {}
      var backMap = {runInUI : "runInUI" + id}
      for(let prop in keyPropMap[id]) {
        if(x.indexOf(keyPropMap[id][prop]) != -1 || window.__OS == "WEB") {
          if(keyPropMap[id][prop] == "imageUrl" && window.__OS != "WEB") {
            if(isURL(listData[j][prop])){
              listData[j][prop] = "url->" + listData[j][prop] + ","
            }
            else{
              var images = listData[j][prop].split(",");
              var imageUrl = "";
              if (images.length>2){
                let preferLocal = (images[2] === "true");
                let isLocal = isImagePresent(images[0]);
                let isUrl = isURL(images[1]);
                if(isLocal&&(preferLocal||!isUrl)){
                  imageUrl = makeImageName(images[0]);
                }
                else{
                  imageUrl = "url->"+images[1] +",";
                  imageUrl = imageUrl + makeImageName(images[0]);
                }
              }
              else if(images.length>1){
                imageUrl = images[0] +",";
                imageUrl = imageUrl + makeImageName(images[1]);
              }else{
                imageUrl = makeImageName(images[0]);
              }
              listData[j][prop] = imageUrl;
            }
          }
          item[prop] = listData[j][prop];
          if(keyPropMap[id][prop] == "imageUrl" && window.__OS == "WEB")
          {
            let arr = listData[j][prop].split(",");
            if(arr.length > 1)
              item[prop] = arr[1];
          }
          continue
        }
        ps[keyPropMap[id][prop]] = listData[j][prop];
        backMap[keyPropMap[id][prop]] = prop;
      }
      if(Object.prototype.hasOwnProperty.call(animPropMap,id)) {
        let animations = []
        for(let anim in animPropMap[id]) {
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
        ps = parseParams("linearLayout", ps, "get")
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

export const updateActivity = function (activityId) {
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
      setUpBaseState(a)()();
      render(a);
    });
  }
}

export const getCurrentActivity = function () {
  return state.currentActivity;
}

export const cachePushEvents = function(namespace) {
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

export const isScreenPushActive = function(namespace) {
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

export const setScreenPushActive = function(namespace) {
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
export const canPreRender = function (){
  if (window.__OS == "ANDROID"){
    if ( typeof window.Android.addStoredViewToParent == "function" &&
      typeof window.Android.prepareAndStoreView == "function"
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

export function prepareDom (dom, _name, namespace){
  if(dom.props && Object.prototype.hasOwnProperty.call(dom.props,"id") && (dom.props.id).toString().trim()){
    dom.__ref = {__id: (dom.props.id).toString().trim()};
  }else{
    dom.__ref = createPrestoElement();
  }

  if(dom.props) {
    dom.props.root = true;
  }
  getConstState(namespace).screenHideCallbacks[_name] = hideViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenShowCallbacks[_name] = showViewInNameSpace(dom.__ref.__id, namespace)
  getConstState(namespace).screenRemoveCallbacks[_name] = removeViewFromNameSpace(namespace, dom.__ref.__id)
  return dom;
}

/**
 * returns Nothing if __CACHED_MACHINE don't have machine
 * This function will make sure that addScreen logic don't get executed
 * if machine not present.
 *
 */
export const getCachedMachineImpl = function(just,nothing,namespace,screenName) {
  if (window.__OS === "ANDROID"){
    var machine;
    if (state.isPreRenderEnabled) {
      machine = getConstState(namespace).cachedMachine ? getConstState(namespace).cachedMachine[screenName] : null;
    } else {
      var curNamespace = getNamespace(namespace);
      machine = Object.prototype.hasOwnProperty.call(state.cachedMachine,curNamespace) ? state.cachedMachine[curNamespace][screenName] : null;
    }
    if (machine !== null && (typeof machine == "object")){
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
export const addScreenWithAnim = function (dom,  screenName, namespace){
  if (window.__OS == "ANDROID") {
  //   var namespace = getNamespace(namespace_);
    if(!state.isPreRenderEnabled) namespace = getNamespace(namespace)
    makeRootVisible(namespace);
    makeScreenVisible(namespace, screenName);
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

export const startedToPrepare = function(namespace, screenName){
  if(getConstState(namespace)){
    getConstState(namespace)[screenName] = getConstState(namespace)[screenName] || {};
    getConstState(namespace)[screenName].prepareStarted = true;
    getConstState(namespace)[screenName].prepareStartedQueue = [];
  }
}

export const awaitPrerenderFinished = function(namespace, screenName, cb){
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
  if (typeof(window.__preRenderIds) === "object" && window.Android.runInUI && window.__OS == "ANDROID"){
    var cmd = ""
    for (var key in window.__preRenderIds) {
      cmd += "set_v=ctx->findViewById:i_" + window.__preRenderIds[key] + ";get_v->removeAllViews;"
    }
    window.Android.runInUI(cmd, null);
  }
}

export const setPreRender = function (screenName) {
  return function (namespace) {
    return function () {
      getConstState(namespace).prerenderScreens.push(screenName);
    }
  }
}

export const setVdomCache = function (screenName) {
  return function (namespace) {
    return function () {
      getConstState(namespace).vdomCached.push(screenName);
    }
  }
}

export const isSSRVdomPresent = function(screenName){
  return function(notInStack){
    return function(){
      try{
        if(notInStack && window.ssrScreen === screenName){
          var insertObject = (window.parent.serverSideKeys || {}).vdom;
          if(insertObject && insertObject["dom"] && (!window.parent.generateVdom)){
            tracker._trackAction("system")("info")("server_side_rendering")({"isServerSideRenderingSupported":true})();
            return true
          }
          tracker._trackAction("system")("info")("server_side_rendering")({"isServerSideRenderingSupported":false})();
        }
      } catch(e){
        // Ignored
      }
      return false
    }
  }
}

export const getTimeInMillis = function(){
  return Date.now();
}

export const setScreenInActive = function (ns) {
  return function (_screen) {
    return function () {
      getScopedState(ns).screenActive[_screen] = false
    }
  }
}
export const setScreenActive = function (ns) {
  return function (_screen) {
    return function () {
      getScopedState(ns).screenActive[_screen] = true
    }
  }
}

export const isScreenActive = function (ns) {
  return function (_screen) {
    return function () {
      return getScopedState(ns).screenActive[_screen]
    }
  }
}

let isStateSame = false;
export const compareState = function (newState) {
  return function (oldState) {
    isStateSame = (oldState === newState)
    return newState
  }
}

export const isOldNewStateSame = function () {
  return isStateSame
}
