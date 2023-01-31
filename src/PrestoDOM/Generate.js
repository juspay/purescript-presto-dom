const loopedFunction = function(){
  return loopedFunction;
}
  
const getTracker = function () {
  var trackerJson = window.JOS.tracker || {};
  if (typeof trackerJson._trackException != "function") {
    trackerJson._trackException = loopedFunction;
  }
  return trackerJson;
};
  
const tracker = getTracker()

import * as prestoUI from "presto-ui";
const prestoDayum = prestoUI.doms;
export const getProps = function(props){
  return function(convertToProp){
    return function(dom){
      return function(){
        var x = props;
        var res = [];
        for(var k in x){
          if(k=="inlineAnimation" || k=="root"){
            continue
          }
          else if(k!= "id"){
            let prop = convertToProp(k)(x[k])
            res.push(prop)
          } else{
            let prop = convertToProp("id2")(x[k])
            res.push(prop)
          } 
        }
        prestoDayum(dom.type,props,dom.children);
        return res
      }
    }
  }
}

export const getVdom = function(){
  var insertObject = (window.parent.serverSideKeys || {}).vdom;
  var x = prestoUI.prestoClone(insertObject["dom"])
  return x
}

export const throwError = function(key){
  return function(err){
    tracker._trackException("lifecycle")("microapp")("presto_exception")(key)(err)();
    throw err;
  }
}