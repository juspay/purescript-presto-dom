const isPreRenderSupported = function(){
  var isSupported = false;
  try{
    var preRenderVersion = JBridge.getResourceByName("pre_render_version");
    var clientId = window.__payload.payload.clientId;
    var sdkConfigFile = JSON.parse(JBridge.getPreRenderConfig() || "");
    isSupported = preRenderVersion >= (sdkConfigFile[clientId] || sdkConfigFile.common)
  } catch(e) {
    console.log(e, "error in pre-render support check");
  }
  window.isPreRenderSupported = isSupported
  return isSupported
}

exports.isPreRenderSupported = window.isPreRenderSupported || isPreRenderSupported()