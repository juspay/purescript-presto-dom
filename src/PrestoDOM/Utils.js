export const concatPropsArrayImpl = function (xs) {
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

export const storeToWindow_ = function (key, value){
  window[key] = value;
}

export const getFromWindow_ = function (key){
  return function (just){
    return function (nothing){
      if (Object.prototype.hasOwnProperty.call(window,key)){
        return just(window[key]);
      } else {
        return nothing;
      }
    }
  }
}

export const debounce = function (logger){
  return function (key) {
    return function (value) {
      return function (json){
        return function(){
          var last = window.lastLog || {key : "", value : ""};
          if(key === last.key){
            // key == last, if previous log is not already logged it will be cancelled, this one will be logged
            clearTimeout(window.loggerTimeout); 
            window.loggerTimeout = setTimeout(loggerFunction,2000,logger,key,value,json);
          } else {
            if(window.loggerTimeout){
              // key != last, timer running, log current and last log 
              clearTimeout(window.loggerTimeout);
              loggerFunction(logger,key,value,json);
              loggerFunction(logger,last.key,last.value,json);
            }else{
              // key != last, timer not running, log current log only 
              loggerFunction(logger,key,value,json);
            }
          }
          window.lastLog = {key : key, value : value};
        }
      }
    }
  }
}

export const addTime2 = function(key){
  return function(){
    var x = Date.now();
    window.timeCheck = window.timeCheck || {}
    window.timeCheck[key] = x;
    performance.mark(key);
  }
}

export const performanceMeasure = function(key){
  return function(start){
    return function(end){
      return function(){
        try {
          performance.measure(key, start, end);
        } catch(e) {
          
        }
      }
    }
  }
}

function loggerFunction(logger, key, value, json){
  logger(key)(value)(json)();
  window.loggerTimeout =  null;
}

export const getTime = Date.now

export const isGenerateVdom = function(){
  return window.parent.generateVdom
}
