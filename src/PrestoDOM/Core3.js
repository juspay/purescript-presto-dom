const prestoUI = require("presto-ui")
const prestoDayum = prestoUI.doms;
const state = {
  scopedState: {},
  fragments: {},
  fragmentIdMap: {},
  listViewKeys: {},
  listViewAnimationKeys: {},
  counter: 0,
  bitMap: {},
  activityNamespaces: {},
  currentActivity: "default",
  cachedMachine: {},
  constState: {},
};

exports.updateActivity = function (activityId) {
  return function () {
    var oldActivity = state.currentActivity;
    state.currentActivity = activityId;
    state.activityNamespaces[oldActivity] = state.activityNamespaces[oldActivity] || [];
    state.activityNamespaces[oldActivity].map(function(a) {
      console.log("updateActivity called for ", activityId, a);
      if (typeof getScopedState(a) != "undefined") {
        return;
      }
      deleteScopedState(a, oldActivity);
      exports.setUpBaseState(a)()();
    });
  }
}

function createPrestoElement() {
  if (
    typeof window.__ui_id_sequence != "undefined" &&
    window.__ui_id_sequence != null
  ) {
    return {
      __id: ++window.__ui_id_sequence,
    };
  } else {
    window.__ui_id_sequence =
      typeof Android.getNewID == "function"
        ? (parseInt(Android.getNewID()) * 1000000) % 100000000
        : (window.__PRESTO_ID || getPrestoID() * 1000000) % 100000000;
    return {
      __id: ++window.__ui_id_sequence,
    };
  }
}

const deleteScopedState = function (namespace, activityID) {
  var id = activityID || state.currentActivity;
  if (state.scopedState[namespace] && state.scopedState[namespace][id]) {
    delete state.scopedState[namespace][id];
  }
};

const deleteConstState = function (namespace, activityID) {
  var id = activityID || state.currentActivity;
  if (namespace && namespace.indexOf(id) == -1) {
    namespace = namespace + id;
  }
  delete state.constState[namespace];
};

const getScopedState = function (namespace, activityID) {
  const activityIDToUse = activityID || state.currentActivity;
  return state.scopedState.hasOwnProperty(namespace)
    ? state.scopedState[namespace][activityIDToUse] ||
        state.scopedState[namespace]["default"]
    : undefined;
};

const ensureScopeStateExists = function() {
  const activityIDToUse = activityID || state.currentActivity;
  state.scopedState.hasOwnProperty(namespace)
    ? (state.scopedState.namespace[activityIDToUse] =
        state.scopedState.namespace[activityIDToUse] || {})
    : (state.scopedState = { [namespace]: { [activityIDToUse]: {} } });
}

const setFragmentIdInScopedState = function (namespace, id, activityID) {
  ensureScopeStateExists()
  getScopedState(namespace).id = id;
};

const getConstState = function (namespace) {
  return state.constState[namespace];
};

var getIdFromNamespace = function (namespace) {
  var ns = getScopedState(namespace).id
    ? getScopedState(namespace).id
    : undefined;
  if (window.__OS == "ANDROID")
    ns = getScopedState(namespace).id ? getScopedState(namespace).id : null;
  return ns;
};

window.getIdFromNamespace = function (namespace) {
  return function () {
    return getIdFromNamespace(id);
  };
};

exports.setUpBaseState = function (namespace) {
  return function (id) {
    return function () {
      console.log("SETUP BASE STATE IN NEW CORE :: ", namespace, id);
      if (
        typeof getScopedState(namespace) != "undefined" &&
        getConstState(namespace).hasRender
      ) {
        terminateUIImpl()(namespace); 
      } else if (typeof getScopedState(namespace) != "undefined") {
        getScopedState(namespace).id = id;
        return;
      }
      if (namespace.indexOf(state.currentActivity) == -1) {
        namespace = namespace + state.currentActivity;
      }
      if (state.currentActivity !== "") {
        var ns = namespace.substr(
          0,
          namespace.length - state.currentActivity.length
        );
        state.activityNamespaces[state.currentActivity] =
          state.activityNamespaces[state.currentActivity] || [];
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
          id: elemRef.__id,
          root: "true",
          height: "match_parent",
          width: "match_parent",
          visibility: "gone",
        },
        __ref: elemRef,
        children: [
          {
            type: "relativeLayout",
            props: {
              id: stackRef.__id,
              height: "match_parent",
              width: "match_parent",
            },
            __ref: stackRef,
            children: [],
          },
          {
            type: "relativeLayout",
            props: {
              id: cacheRef.__id,
              height: "match_parent",
              width: "match_parent",
              visibility: "gone",
            },
            __ref: cacheRef,
            children: [],
          },
        ],
      };
      getScopedState(namespace).MACHINE_MAP = {};
      getScopedState(namespace).screenStack = [];
      getScopedState(namespace).hideList = [];
      getScopedState(namespace).removeList = [];
      getScopedState(namespace).screenCache = [];
      getScopedState(namespace).cancelers = {};
      getScopedState(namespace).rootId = elemRef.__id;
      getScopedState(namespace).stackRoot = stackRef.__id;
      getScopedState(namespace).cacheRoot = cacheRef.__id;
      getScopedState(namespace).shouldHideCacheRoot = false;
      getScopedState(namespace).eventIOs = {};
      getScopedState(namespace).queuedEvents = {};
      getScopedState(namespace).pushActive = {};
      getScopedState(namespace).rootVisible = false;

      if (!state.constState.hasOwnProperty(namespace)) {
        state.constState[namespace] = {};
        getConstState(namespace).animations = {};
        getConstState(namespace).animations.entry = {};
        getConstState(namespace).animations.exit = {};
        getConstState(namespace).animations.entryF = {};
        getConstState(namespace).animations.exitF = {};
        getConstState(namespace).animations.entryB = {};
        getConstState(namespace).animations.exitB = {};
        getConstState(namespace).animations.animationStack = [];
        getConstState(namespace).animations.animationCache = [];
        getConstState(namespace).animations.lastAnimatedScreen = "";
        getConstState(namespace).animations.prerendered = [];

        getConstState(namespace).screenHideCallbacks = {};
        getConstState(namespace).screenShowCallbacks = {};
        getConstState(namespace).screenRemoveCallbacks = {};
        getConstState(namespace).registeredEvents = {};
        getConstState(namespace).afterRenderFunctions = {};
      }
      // https://juspay.atlassian.net/browse/PICAF-6628
      getScopedState(namespace).afterRenderFunctions = prestoUI.prestoClone(
        getConstState(namespace).afterRenderFunctions || {}
      );

      // rethink Logic
      getScopedState(namespace).mappQueue = [];
      getScopedState(namespace).fragmentCallbacks = {};
      getScopedState(namespace).shouldReplayCallbacks = {};
    };
  };
};

exports.render = function (namespace) {
  getConstState(namespace).hasRender = true;
  var id = getIdFromNamespace(namespace);
  if (window.__OS == "ANDROID") {
    if (typeof AndroidWrapper.getNewID == "function") {
      // TODO change this to mystique version check.
      // TODO add mystique reject / alternate handling, when required version is not present
      AndroidWrapper.render(
        JSON.stringify(
          domAll(getScopedState(namespace).root, "base", namespace)
        ),
        null,
        "false",
        id ? id : null
      );
    } else {
      AndroidWrapper.render(
        JSON.stringify(
          domAll(getScopedState(namespace).root),
          "base",
          namespace
        ),
        null
      );
    }
  } else if (window.__OS == "WEB") {
    AndroidWrapper.Render(
      domAll(getScopedState(namespace).root, "base", namespace),
      null,
      id
    ); // Add support for Web
  } else {
    AndroidWrapper.render(
      domAll(getScopedState(namespace).root, "base", namespace),
      null,
      id ? id : undefined
    ); // Add support for iOS
  }

  try {
    //Code is in try catch to avoid any errors with accessing top
    if (window.__OS == "IOS" && !getScopedState(namespace).id) {
      top.setAddRootScreen =
        top.setAddRootScreen ||
        function (screenName) {
          top.PDScreens = top.PDScreens || [];
          top.PDScreens.push(screenName);
        };
      top.setAddRootScreen(JOS.self + "::" + namespace);
    }
  } catch (e) {}
};

exports.getCurrentActivity = function () {
  return state.currentActivity;
};

exports.cancelExistingActions = function (name, namespace, activitiId) {
  // Added || false to return false when value is undefined
  try {
    if (
      getScopedState(namespace, activitiId) &&
      getScopedState(namespace, activitiId).cancelers &&
      typeof getScopedState(namespace, activitiId).cancelers[name] == "function"
    ) {
      getScopedState(namespace).cancelers[name]();
    }
  } catch (e) {
    console.error("cancelExistingActions:", e);
  }
};

exports.setScreenPushActive = function (namespace) {
  return function (screenName) {
    return function (activityID) {
      return function () {
        getScopedState(namespace, activityID).pushActive =
          getScopedState(namespace, activityID).pushActive || {};
        getScopedState(namespace, activityID).queuedEvents =
          getScopedState(namespace, activityID).queuedEvents || {};
        getScopedState(namespace, activityID).pushActive[screenName] = true;
        while (
          getScopedState(namespace, activityID).queuedEvents[screenName] &&
          getScopedState(namespace, activityID).queuedEvents[screenName][0]
        ) {
          getScopedState(namespace, activityID).queuedEvents[
            screenName
          ].shift()();
        }
      };
    };
  };
};

exports.saveCanceller = function (name, namespace, activityId, canceller) {
  // Added || false to return false when value is undefined
  if (namespace && namespace.indexOf(state.currentActivity) == -1) {
    namespace = namespace + state.currentActivity;
  }
  state.scopedState[namespace] = getScopedState(namespace) || {};
  getScopedState(namespace, activityId).cancelers =
    getScopedState(namespace, activityId).cancelers || {};
  if (
    getScopedState(namespace, activityId) &&
    getScopedState(namespace, activityId).cancelers
  ) {
    getScopedState(namespace, activityId).cancelers[name] = canceller;
  }
};

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

function createAndroidWrapper() {
  if (
    window.__OS == "ANDROID" &&
    window.Android &&
    typeof window.Android.addToContainerList != "function"
  ) {
    var android = {};
    for (var i in window.Android) {
      android[i] = window.Android[i].bind(window.Android);
    }
    android.removeView = function (id, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.removeView(id);
    };
    android.updateProperties = function (cmd, namespace) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.updateProperties(cmd);
    };
    android.addToContainerList = function (id, namespace) {
      // Check if JOS has an id store from another m-app
      // Add id, and get a return string identifier
      // Use the same to decide between render and addview to parent
      if (typeof top.addToContianerList != "function") {
        top.fragments = top.fragments || {};
        var generateUUID = function () {
          function s4() {
            return Math.floor((1 + Math.random()) * 0x10000)
              .toString(16)
              .substring(1);
          }
          return (
            s4() +
            s4() +
            "-" +
            s4() +
            "-" +
            s4() +
            "-" +
            s4() +
            "-" +
            s4() +
            s4() +
            s4()
          );
        };
        top.addToContainerList = function (id, namespace) {
          // Namespace not needed, for cases where we do not have merchant fragment
          var uuid = generateUUID();
          top.fragments[uuid] = id;
          return uuid;
        };
      }
      return top.addToContainerList(id, namespace);
    };
    android.render = function (domString, snd, trd, nsps) {
      // Query JOS if ns is available.
      // if null call render
      // if not null find namespace and call AddViewToParent
      top.fragments = top.fragments || {};
      if (
        nsps == null ||
        nsps == undefined ||
        typeof top.fragments[nsps] != "number"
      ) {
        return Android.render(domString, snd, trd);
      }
      var rootId = top.fragments[nsps] + "";
      return Android.addViewToParent(rootId, domString, 0, null, null);
    };
    android.addViewToParent = function (
      rootId,
      domString,
      position,
      callback,
      fth,
      namespace
    ) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.addViewToParent(
        rootId,
        domString,
        position,
        callback,
        fth
      );
    };
    android.replaceView = function (domString, id, ns) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.replaceView(domString, id);
    };
    android.moveView = function (id, index, ns) {
      // Namespace not needed, for cases where we do not have merchant fragment
      return Android.moveView(id, index);
    };
    return android;
  } else {
    return window.Android;
  }
}

const AndroidWrapper = createAndroidWrapper();

exports.terminateUIImpl = terminateUIImpl();
exports.terminateUIImplWithCallback = terminateUIImpl;
function terminateUIImpl(callback) {
  return function (namespace) {
    if (callback) {
      callback(-1)(
        JSON.stringify({
          stopAtDom: true,
          id: getScopedState(namespace).id,
        })
      )();
    }
    window.__usedIDS = undefined;
    if (
      window.__OS == "ANDROID" &&
      AndroidWrapper.runInUI &&
      getScopedState(namespace) &&
      getScopedState(namespace).root &&
      getScopedState(namespace).root.__ref &&
      getScopedState(namespace).root.__ref.__id
    ) {
      AndroidWrapper.runInUI(
        ";set_v=ctx->findViewById:i_" +
          getScopedState(namespace).root.__ref.__id +
          ";set_p=get_v->getParent;get_p->removeView:get_v;",
        null
      );
    } else if (
      JOS &&
      JOS.parent &&
      JOS.parent != "java" &&
      getScopedState(namespace) &&
      getScopedState(namespace).root &&
      getScopedState(namespace).root.__ref &&
      getScopedState(namespace).root.__ref.__id
    ) {
      AndroidWrapper.removeView(
        getScopedState(namespace).root.__ref.__id,
        getIdFromNamespace(namespace)
      );
    } else {
      if (
        JOS &&
        JOS.parent &&
        getScopedState(namespace) &&
        getScopedState(namespace).root &&
        getScopedState(namespace).root.__ref &&
        getScopedState(namespace).root.__ref.__id
      ) {
        AndroidWrapper.removeView(
          getScopedState(namespace).root.__ref.__id,
          getIdFromNamespace(namespace)
        );
      }
    }
    try {
      if (window.__OS == "IOS" && !getScopedState(namespace).id) {
        top.removeRootScreen =
          top.removeRootScreen ||
          function (screenName) {
            var index = this.top.PDScreens.indexOf(screenName);
            if (index == -1) {
              return;
            } else {
              this.top.PDScreens.splice(index, 1);
              if (this.top.PDScreens.length == 0) {
                AndroidWrapper.runInUI(
                  ["removeAllUI"],
                  this.getIdFromNamespace(this.namespace)
                );
              }
            }
          };
        // Adding var x so that openning paranthesis is not treated as argument
        var x = top.removeRootScreen.bind(this)(JOS.self + "::" + namespace);
      }
    } catch (e) {
      // incase of exception from using top
    }
    deleteScopedState(namespace);
    if (window.__OS != "ANDROID") {
      deleteConstState(namespace);
    }
  };
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

exports.saveCanceller = function (name, namespace, canceller) {
  // Added || false to return false when value is undefined
  let activity = state.currentActivity;
  state.scopedState[namespace][activity] = getScopedState(namespace) || {}
  getScopedState(namespace).cancelers = getScopedState(namespace).cancelers || {}
  if(getScopedState(namespace) && getScopedState(namespace).cancelers) {
    getScopedState(namespace).cancelers[name] = canceller;
  }
  return namespace
}

exports.startedToPrepare = function(namespace, screenName){
  if(getConstState(namespace)){
    getConstState(namespace)[screenName] = getConstState(namespace)[screenName] || {};
    getConstState(namespace)[screenName].prepareStarted = true;
    getConstState(namespace)[screenName].prepareStartedQueue = [];
  }
}

exports.getAndSetEventFromState = function(namespace, screenName, def) {
  state.scopedState[namespace][state.currentActivity] = getScopedState(namespace) || {}
  getScopedState(namespace).eventIOs = getScopedState(namespace).eventIOs || {}
  getScopedState(namespace).eventIOs[screenName] = getScopedState(namespace).eventIOs[screenName] || def();
  return getScopedState(namespace).eventIOs[screenName];
}

exports.isScreenPushActive = function(namespace) {
  return function(screenName) {
      return function(activityID){
          return function () {
              state.scopedState[namespace][activityID] = getScopedState(namespace, activityID) || {}
              getScopedState(namespace, activityID).pushActive = getScopedState(namespace, activityID).pushActive || {}
              return getScopedState(namespace, activityID).pushActive[screenName] || false;
          }
      }
  }
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

exports.parseProps = parsePropsImpl;

function parsePropsImpl(elem, screenName, VALIDATE_ID, namespace) {
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
    , unNestPayload : props.unNestPayload
    , useStartApp : props.useStartApp
    , requestId : elem.requestId
    , service : elem.service
    , elemId : elem.__ref.__id
    , callback : props.onMicroappResponse
    }
    if (getScopedState(namespace) && getScopedState(namespace).mappQueue) {
      getScopedState(namespace).mappQueue.push(mappBootData);
    }
    else {
      console.warn("Namespace", namespace);
      console.warn("state", state);
    }
    type = "relativeLayout"
  }
  if(props.hasOwnProperty("afterRender")) {
    getConstState(namespace).afterRenderFunctions[screenName] = getConstState(namespace).afterRenderFunctions[screenName] || []
    getConstState(namespace).afterRenderFunctions[screenName].push(props.afterRender)
    getScopedState(namespace).afterRenderFunctions[screenName] = getScopedState(namespace).afterRenderFunctions[screenName] || []
    getScopedState(namespace).afterRenderFunctions[screenName].push(props.afterRender)
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

exports.setControllerStates = function(namespace) {
  return function (screenName) {
    return function () {
      ensureScopeStateExists()
      getScopedState(namespace).activeScreen = screenName;
      getScopedState(namespace).activateScreen = true;
    }
  }
}