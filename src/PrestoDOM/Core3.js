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

const getScopedState = function (namespace, activityID) {
  const activityIDToUse = activityID || state.currentActivity;
  return state.scopedState.hasOwnProperty(namespace)
    ? state.scopedState[namespace][activityIDToUse] ||
        state.scopedState[namespace]["default"]
    : undefined;
};

const setFragmentIdInScopedState = function (namespace, id, activityID) {
  const activityIDToUse = activityID || state.currentActivity;
  state.scopedState.hasOwnProperty(namespace)
    ? (state.scopedState.namespace[activityIDToUse] =
        state.scopedState.namespace[activityIDToUse] || {})
    : (state.scopedState = { [namespace]: { [activityIDToUse]: {} } });
  getScopedState(namespace).id = id;
};

const getConstState = function (namespace) {
  return state.constState[namespace];
};

exports.setUpBaseState = function (namespace) {
  return function (id) {
    return function () {
      console.log(
        "SETUP BASE STATE IN NEW CORE :: ",
        namespace,
        activityId,
        id
      );
      if (
        typeof getScopedState(namespace, activityId) != "undefined" &&
        getConstState(namespace).hasRender
      ) {
        terminateUIImpl()(namespace); //TODO: ask George about this
      } else if (typeof getScopedState(namespace, activityId) != "undefined") {
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
      state.fragments[id || "null"] = namespace; // TODO: ask George about this
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
  //TODO: ask George about this whole function
  getConstState(namespace).hasRender = true;
  var id = getScopedState(namespace).id;
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
      getIdFromNamespace(namespace)
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
