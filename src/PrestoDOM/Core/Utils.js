const state = {
  mappCallbacks : {}
  , pendingRequests :[]
  , oldRequestIds : []
  , replayCallbacks : {}
  , cacheImage : {}
}


export const saveRefToStateImpl = function (key) {
  return function(ref) {
    return function() {
      state[key] = ref
    }
  }
}

export const loadRefFromStateImpl = function (key) {
  return function (nothing) {
    return function (just) {
      return function () {
        return state[key] ? just (state[key]) : nothing;
      }
    }
  }
}

function getPrestoID() {
  if (window.__OS === "WEB") {
    return 1;
  }

  return top.__PRESTO_ID ? ++top.__PRESTO_ID : 1;
}

export const createPrestoElement = function () {
  if (
    typeof window.__ui_id_sequence != "undefined" &&
      window.__ui_id_sequence !== null
  ) {
    return {
      __id: ++window.__ui_id_sequence
    };
  } else {
    window.__ui_id_sequence =
        typeof window.Android.getNewID == "function" ?
          (parseInt(window.Android.getNewID()) * 1000000) % 100000000 :
          (window.__PRESTO_ID || getPrestoID() * 1000000) % 100000000;
    return {
      __id: ++window.__ui_id_sequence
    };
  }
};

export const os = window.__OS

import * as prestoUI from "presto-ui";
const prestoDayum = prestoUI.doms;

const generateUUID = function() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + "-" + s4() + "-" + s4() + "-" +
          s4() + "-" + s4() + s4() + s4();
}

export const callbackMapper = prestoUI.callbackMapper.map;

export const generateCommands = function (elem) {
  var type = elem.type;
  var props = elem.props;
  var elemType = elem.elemType;
  var keyId = elem.keyId;
  if (elem.parentType && window.__OS == "ANDROID") {
    return prestoDayum({
      elemType: type,
      parentType: elem.parentType
    },
    props,
    elem.children
    );
  }
  if(window.__OS == "WEB"){
    return prestoDayum(type, props, elem.children, elemType, keyId);
  }
  return prestoDayum(type, props, elem.children);
}

export const callMicroAppListItem = function (service) {
  return function (a) {
    return function (callback) {
      return function () {
        // GENERATE requestId
        // Add a callback
        var success = function (code) {
          return function (response) {
            return function () {
              try {
                var t = JSON.parse(response).payload.fragment
                if(Object.prototype.hasOwnProperty.call(t,"holderViews") && Object.prototype.hasOwnProperty.call(t,"keyPropMap")) {
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
        if(window.__OS == "WEB" || (window.JOS && typeof window.JOS.isMAppPresent == "function" &&  typeof window.JOS.isMAppPresent(service) == "function" && window.JOS.isMAppPresent(service)())) {
          return window.JOS.emitEvent(service)("onMerchantEvent")(["process", JSON.stringify(request)])(success)()
        } else {
          success(0)("failure")()
          return function() {}
        }
      }
    }
  }
}

export const callMicroApp = function (service) {
  return function (id) {
    return function (a) {
      return function (callback) {
        return function (mappCallback) {
          return function (namespace){
            return function (screenName){
              return function () {
                state.requestIds = state.requestIds || {}
                state.requestIds[id] = state.requestIds[id] || {}
                var action = state.requestIds[id][service] ? "update" :  "process"
                state.requestIds[id][service] = state.requestIds[id][service] || {}
                state.requestIds[id][service].requestId = generateUUID();
                let requestId = state.requestIds[id][service].requestId;
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
                  return function (resp) {
                    return function () {
                      try {
                        var response = JSON.parse(resp)
                        if( !Object.prototype.hasOwnProperty.call(response,"error") || response.error || (response.payload && response.payload.stopAtDom)) {
                          if(Object.prototype.hasOwnProperty.call(response,"payload") && Object.prototype.hasOwnProperty.call(response.payload,"state")) {
                            state.requestIds[id][service].response = response.payload.state;
                          }
                          if(typeof state.mappCallbacks[service][response.requestId] == "function") {
                            state.mappCallbacks[service][response.requestId](response.payload.state)()
                            delete state.mappCallbacks[service][response.requestId];
                            state.oldRequestIds.push(response.requestId)
                          }
                        } else if (state.oldRequestIds.indexOf(response.requestId) == -1) {
                          throw Error("Invalid requestId fallback")
                        }
                        if ((response.payload && !response.payload.stopAtDom) && typeof mappCallback == "function") {
                          mappCallback({code : code , message : JSON.stringify(response.payload)});
                          state.replayCallbacks[namespace] = state.replayCallbacks[namespace] || {};
                          state.replayCallbacks[namespace][screenName] = {code : code , message : JSON.stringify(response.payload)};
                        }
                      } catch (e) {
                        // respond to all pending callbacks
                        while(state.pendingRequests[0]) {
                          var reqId = state.pendingRequests.pop()
                          if(typeof state.mappCallbacks[service][reqId] == "function") {
                            state.mappCallbacks[service][reqId]("error")();
                          }
                          state.oldRequestIds.push(reqId);
                        }
                      }
                    }
                  }
                }
                if(window.__OS == "WEB" || (window.JOS && typeof window.JOS.isMAppPresent == "function" &&  typeof window.JOS.isMAppPresent(service) == "function" && window.JOS.isMAppPresent(service)())) {
                  return window.JOS.emitEvent(service)("onMerchantEvent")([action, JSON.stringify(request)])(success)()
                } else {
                  success(0)("failure")();
                  return function() {}
                }
              }
            }
          }
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

export const checkFontisPresent = function (fontName) {
  return function (callback) {
    return function () {
      if (window.__OS != "ANDROID" || isUrl(fontName)) {
        callback(true)();
        return;
      }
      if(window.juspayAssetConfig && window.juspayAssetConfig.fonts){
        if(window.juspayAssetConfig.fonts[fontName] || window.juspayAssetConfig.fonts["jp_"+fontName])
          callback(true)();
        else
          callback(false)();
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
      window.Android.runInUI("set_a=ctx->getResources;set_a=get_a->getAssets;get_a->open:s_fonts/"+fontName+".ttf;",JSON.stringify(cb));
    }
  }
}

export const checkImageisPresent = function (imageName, _name, prp, callback) {
  if (window.__OS != "ANDROID" || isUrl(imageName)) {
    if (window.__OS === "ANDROID" && prp && prp.value0 && prp.value0.__id){
      state.cacheImage[_name] = state.cacheImage[_name] || {};
      state.cacheImage[_name][imageName] = state.cacheImage[_name][imageName] || [];
      state.cacheImage[_name][imageName].push(prp.value0.__id)
    }
    callback(true)();
    return;
  }
  if(window.juspayAssetConfig && window.juspayAssetConfig.images){
    if(window.juspayAssetConfig.images[imageName] || window.juspayAssetConfig.images["jp_"+imageName])
      callback(true)();
    else
      callback(false)();
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
  window.Android.runInUI( "set_342372=ctx->getPackageName;set_res=ctx->getResources;set_368248=get_res->getIdentifier:s_" + imageName + ",s_drawable,get_342372;set_res=ctx->getResources;set_482380=get_res->getDrawable:get_368248;",JSON.stringify(cb))
}

export const attachUrlImages = function (_name){
  if (window.__OS === "ANDROID" && Object.prototype.hasOwnProperty.call(state.cacheImage,_name)){
    var urlSetCommands = "set_directory=ctx->getDir:s_juspay,i_0;" ;
    for ( var imgUrl in state.cacheImage[_name]){
      var image = imgUrl.substr(imgUrl.lastIndexOf("/") + 1);
      var ids = state.cacheImage[_name][imgUrl];
      for (var i=0;i<ids.length;i++){
        urlSetCommands = urlSetCommands + "set_resolvedFile=java.io.File->new:get_directory,s_" + window.JBridge.getFilePath(image)  + ";" +
                        "set_resolvedPath=get_resolvedFile->toString;" +
                        "set_dimage=android.graphics.drawable.Drawable->createFromPath:get_resolvedPath;" +
                        "set_imgV=ctx->findViewById:i_" + ids[i] + ";" +
                        "get_imgV->setImageDrawable:get_dimage;";

      }
    }
    delete state.cacheImage[_name];
    window.Android.runInUI(urlSetCommands ,null);
  }
}

export const generateAndCheckRequestId = function (id) {
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

export const getLatestListData = function (id) {
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

export const setDebounceToCallback = function (cbstr) {
  window.__THROTTELED_ACTIONS = window.__THROTTELED_ACTIONS || []
  window.__THROTTELED_ACTIONS.push(cbstr);
  return cbstr;
}

export const replayListFragmentCallbacksImpl = function (namespace) {
  return function (nam) {
    return function (push) {
      return function(){
        if (state.replayCallbacks[namespace] && state.replayCallbacks[namespace][nam]){
          push(state.replayCallbacks[namespace][nam])();
        }
        return function(){};
      };
    }
  }
}