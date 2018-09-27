"use strict";

exports.stringifyGradient = function (type, angle, values) {
  var obj = {};
  obj["type"] = type;
  obj["angle"] = angle;
  obj["values"] = values;
  return JSON.stringify(obj);
}
