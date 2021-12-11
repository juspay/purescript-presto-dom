

const state = {
  scopedState : {}
, fragments : {}
, fragmentIdMap : {}
, listViewKeys : {}
, listViewAnimationKeys : {}
, counter: 0
, bitMap: {}
, activityNamespaces: {}
, currentActivity: 'default'
, cachedMachine : {}
    , constState : {}
}

const getScopedState = function (namespace, activityID) {
    return state.scopedState[getNamespace(namespace, activityID)];
}
  
const getNamespace = function (namespace, activityID) {
    var id = activityID || state.currentActivity
    if (namespace && namespace.indexOf(id) == -1) {
        namespace = namespace + id;
    }
    return namespace
}