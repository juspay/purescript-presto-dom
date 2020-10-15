"use strict";

exports.stringifyGradient = function (type, angle, values) {
  var obj = {};
  obj["type"] = type;
  obj["angle"] = angle;
  obj["values"] = values;
  return JSON.stringify(obj);
}

exports.__IS_ANDROID = function(){
  if(window.__OS == "ANDROID") return true
  else return false
}

