"use strict";

exports.concatPropsArrayImpl = function (xs) {
  return function (ys) {
    var xsLen = xs.length;
    var ysLen = ys.length;

    if (xsLen === 0) return ys;
    if (ysLen === 0) return xs;

    var res = [];
    var indexOfKey = function (attr1, arr) {
      return !arr.some(function(attr2) {
        return attr1.value0 == attr2.value0;
      });
    }

    res = xs.filter(function(x) {
      return indexOfKey(x,ys);
    });

    return res.concat(ys);

  };
};