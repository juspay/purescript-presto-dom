const isPreRenderSupported = function(){
  var isSupported = false;
  try{
    var preRenderVersion = JBridge.getResourceByName("pre_render_version");
    var clientId = window.__payload.payload.clientId.split("_")[0];
    var sdkConfigFile = JSON.parse(JBridge.loadFileInDUI("sdk_config.json") || "");
    isSupported = preRenderVersion >= (sdkConfigFile.preRenderConfig[clientId] || sdkConfigFile.preRenderConfig.common)
  } catch(e) {
    console.log(e, "error in pre-render support check");
  }
  window.isPreRenderSupported = isSupported
  return isSupported
}

exports.isPreRenderSupported = window.isPreRenderSupported || isPreRenderSupported()