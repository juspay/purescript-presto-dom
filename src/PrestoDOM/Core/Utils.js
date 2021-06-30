const state = {
      mappCallbacks : {}
    , pendingRequests :[]
    , oldRequestIds : []
    }

exports.saveRefToStateImpl = function (key) {
    return function(ref) {
        return function() {
            state[key] = ref
        }
    }
}

exports.loadRefFromStateImpl = function (key) {
    return function (nothing) {
        return function (just) {
            return function () {
                return state[key] ? just (state[key]) : nothing;
            }
        }
    }
}

exports.createPrestoElement = function () {
    if (
        typeof window.__ui_id_sequence != "undefined" &&
        window.__ui_id_sequence != null
    ) {
        return {
            __id: ++window.__ui_id_sequence
        };
    } else {
        window.__ui_id_sequence =
            typeof Android.getNewID == "function" ?
            parseInt(Android.getNewID()) * 1000000 :
            window.__PRESTO_ID || getPrestoID() * 1000000;
        return {
            __id: ++window.__ui_id_sequence
        };
    }
};

exports.os = window.__OS

const prestoUI = require("presto-ui")
const prestoDayum = prestoUI.doms;

const generateUUID = function() {
    function s4() {
            return Math.floor((1 + Math.random()) * 0x10000)
                    .toString(16)
                    .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
            s4() + '-' + s4() + s4() + s4();
  }

exports.callbackMapper = prestoUI.callbackMapper.map;

exports.generateCommands = function (elem) {
    var type = elem.type;
    var props = elem.props;
    if (elem.parentType && window.__OS == "ANDROID") {
      return prestoDayum({
          elemType: type,
          parentType: elem.parentType
        },
        props,
        elem.children
      );
    }
    return prestoDayum(type, props, elem.children);;
  }

exports.callMicroAppListItem = function (service) {
    return function (a) {
        return function (callback) {
            return function () {
                // GENERATE requestId
                // Add a callback
                var success = function (code) {
                    return function (status) {
                        return function () {
                            console.log("listItem response", status)
                            try {
                                var t = JSON.parse(status).payload.fragment
                                if(t.hasOwnProperty("holderViews") && t.hasOwnProperty("keyPropMap")) {
                                    callback(t)()
                                    return;
                                }
                            } catch (e) {
                            }
                            var ret = { }
                            callback(ret)()
                        }
                    }
                }
                var request = {
                    requestId : generateUUID(),
                    payload : JSON.parse(a.payload),
                    service : service
                }
                return JOS.emitEvent(service)("onMerchantEvent")(["process", JSON.stringify(request)])(success)()
            }
        }
    }
}

exports.callMicroApp = function (service) {
    return function (id) {
        return function (a) {
            return function (callback) {
                return function () {
                    state.requestIds = state.requestIds || {}
                    state.requestIds[id] = state.requestIds[id] || {}
                    var action = state.requestIds[id][service] ? "update" :  "process"
                    state.requestIds[id][service] = state.requestIds[id][service] || {}
                    state.requestIds[id][service].requestId = generateUUID();
                    requestId = state.requestIds[id][service].requestId;
                    var request = {
                        requestId : requestId,
                        payload : a,
                        service : service
                    }

                    // GENERATE requestId
                    // Add a callback
                    state.mappCallbacks = state.mappCallbacks || {}
                    state.mappCallbacks[service] = state.mappCallbacks[service] || {}
                    state.mappCallbacks[service][requestId] = callback
                    state.pendingRequests.push(requestId)
                    
                    var success = function (code) {
                        return function (status) {
                            return function () {
                                console.log(status, code);
                                try {
                                    var response = JSON.parse(status)
                                    state.requestIds[id][service].response = JSON.parse(status).payload.state;
                                    if(typeof state.mappCallbacks[service][response.requestId] == "function") {
                                        state.mappCallbacks[service][response.requestId](response.payload.state)()
                                        delete state.mappCallbacks[service][response.requestId];
                                        state.oldRequestIds.push(response.requestId)
                                    } else if (state.oldRequestIds.indexOf(response.requestId) == -1) {
                                        throw Error("Invalid requestId fallback")
                                    }
                                } catch (e) {
                                    // respond to all pending callbacks
                                    while(state.pendingRequests[0]) {
                                        var reqId = state.pendingRequests.pop()
                                        state.mappCallbacks[service][reqId]("error")();
                                        state.oldRequestIds.push(reqId);
                                    }
                                }
                            }
                        }
                    }
                    return JOS.emitEvent(service)("onMerchantEvent")([action, JSON.stringify(request)])(success)()
                }
            }
        }
    }
}

function isUrl (value) {
    try {
        var url = new URL(value)
        return true;
    } catch (e) {
        /** Ignored **/
    }
    return false
}

exports.checkFontisPresent = function (fontName) {
    return function (callback) {
        return function () {
            if (window.__OS != "ANDROID" || isUrl(fontName)) {
                callback(true)();
                return;
            }
            state.fonts = state.fonts || {};
            state.fonts[fontName] = state.fonts[fontName] || {
                started : true
            }
            if(typeof state.fonts[fontName].status === "boolean") {
                callback(state.fonts[fontName].status)();
                return;
            }
            var cb = prestoUI.callbackMapper.map( function (success) {
                state.fonts[fontName].status = (success == "success")
                callback(success == "success")()
            })
            Android.runInUI("set_a=ctx->getResources;set_a=get_a->getAssets;get_a->open:s_fonts/"+fontName+".ttf;",JSON.stringify(cb));
        }
    }
}

exports.checkImageisPresent = function (imageName) {
    return function (callback) {
        return function () {
            if (window.__OS != "ANDROID" || isUrl(imageName)) {
                callback(true)();
                return;
            }
            state.images = state.images || {};
            state.images[imageName] = state.images[imageName] || {
                started : true
            }
            if(typeof state.images[imageName].status === "boolean") {
                callback(state.images[imageName].status)();
                return;
            }
            var cb = prestoUI.callbackMapper.map( function (success) {
                state.images[imageName].status = (success == "success")
                callback(success == "success")()
            })
            Android.runInUI( "set_342372=ctx->getPackageName;set_res=ctx->getResources;set_368248=get_res->getIdentifier:s_" + imageName + ",s_drawable,get_342372;set_res=ctx->getResources;set_482380=get_res->getDrawable:get_368248;",JSON.stringify(cb))
        }
    }
}

exports.generateAndCheckRequestId = function (id) {
    return function (payloads) {
        return function () {
            state.requestIds = state.requestIds || {};
            state.requestIds[id] = state.requestIds[id] || {}
            for(var service in payloads) {
                state.requestIds[id][service] = state.requestIds[id][service] || generateUUID()
            }
        }
    }
}

exports.getLatestListData = function (id) {
    return function () {
        var temp = [];
        try {
            for (var service in state.requestIds[id]) {
                if( state.requestIds[id][service].response instanceof Array ) {
                    temp.push(state.requestIds[id][service].response);
                }
            }
            return temp;
        } catch (e) {
            return [];
        }
    }
}

exports.setDebounceToCallback = function (cbstr) {
    window.__THROTTELED_ACTIONS = window.__THROTTELED_ACTIONS || []
    window.__THROTTELED_ACTIONS.push(cbstr);
    return cbstr;
}