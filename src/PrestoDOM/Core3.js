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
  return state.scopedState.hasOwnProperty(namespace)
    ? state.scopedState[namespace][activityID] ||
        state.scopedState[namespace]["default"]
    : undefined;
};

const setFragmentIdInScopedState = function (namespace, activityID, id) {
  state.scopedState.hasOwnProperty(namespace)
    ? (state.scopedState.namespace[activityID] =
        state.scopedState.namespace[activityID] || {})
    : (state.scopedState = { [namespace]: { [activityID]: {} } });
  getScopedState(namespace, activityId).id = id;
};

const getConstState = function (namespace) {
  return state.constState[namespace];
};

exports.setUpBaseState = function (namespace) {
  return function (id) {
    return function (activityId) {
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
        } else if (
          typeof getScopedState(namespace, activityId) != "undefined"
        ) {
          getScopedState(namespace, activityId).id = id;
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
        setFragmentIdInScopedState(namespace, activityID, id);
        state.fragments[id || "null"] = namespace; // TODO: ask George about this
        var elemRef = createPrestoElement();
        var stackRef = createPrestoElement();
        var cacheRef = createPrestoElement();
        getScopedState(namespace, activityId).root = {
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
        getScopedState(namespace, activityId).MACHINE_MAP = {};
        getScopedState(namespace, activityId).screenStack = [];
        getScopedState(namespace, activityId).hideList = [];
        getScopedState(namespace, activityId).removeList = [];
        getScopedState(namespace, activityId).screenCache = [];
        getScopedState(namespace, activityId).cancelers = {};
        getScopedState(namespace, activityId).rootId = elemRef.__id;
        getScopedState(namespace, activityId).stackRoot = stackRef.__id;
        getScopedState(namespace, activityId).cacheRoot = cacheRef.__id;
        getScopedState(namespace, activityId).shouldHideCacheRoot = false;
        getScopedState(namespace, activityId).eventIOs = {};
        getScopedState(namespace, activityId).queuedEvents = {};
        getScopedState(namespace, activityId).pushActive = {};
        getScopedState(namespace, activityId).rootVisible = false;

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
        getScopedState(namespace, activityId).afterRenderFunctions =
          prestoUI.prestoClone(
            getConstState(namespace).afterRenderFunctions || {}
          );

        // rethink Logic
        getScopedState(namespace, activityId).mappQueue = [];
        getScopedState(namespace, activityId).fragmentCallbacks = {};
        getScopedState(namespace, activityId).shouldReplayCallbacks = {};
      };
    };
  };
};

exports.render = function (namespace) {
  //TODO: ask George about this whole function
  getConstState(namespace).hasRender = true;
  var id = getScopedState(namespace, activityId).id;
  if (window.__OS == "ANDROID") {
    if (typeof AndroidWrapper.getNewID == "function") {
      // TODO change this to mystique version check.
      // TODO add mystique reject / alternate handling, when required version is not present
      AndroidWrapper.render(
        JSON.stringify(
          domAll(getScopedState(namespace, activityId).root, "base", namespace)
        ),
        null,
        "false",
        id ? id : null
      );
    } else {
      AndroidWrapper.render(
        JSON.stringify(
          domAll(getScopedState(namespace, activityId).root),
          "base",
          namespace
        ),
        null
      );
    }
  } else if (window.__OS == "WEB") {
    AndroidWrapper.Render(
      domAll(getScopedState(namespace, activityId).root, "base", namespace),
      null,
      getIdFromNamespace(namespace)
    ); // Add support for Web
  } else {
    AndroidWrapper.render(
      domAll(getScopedState(namespace, activityId).root, "base", namespace),
      null,
      id ? id : undefined
    ); // Add support for iOS
  }

  try {
    //Code is in try catch to avoid any errors with accessing top
    if (window.__OS == "IOS" && !getScopedState(namespace, activityId).id) {
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
