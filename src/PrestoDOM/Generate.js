const loopedFunction = function(){
    return loopedFunction;
}
  
const getTracker = function () {
    var trackerJson = JOS.tracker || {};
    if (typeof trackerJson._trackException != "function") {
        trackerJson._trackException = loopedFunction;
    }
    return trackerJson;
};
  
const tracker = getTracker()

const prestoUI = require("presto-ui")
const prestoDayum = prestoUI.doms;
exports.getProps = function(props){
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
                        prop = convertToProp(k)(x[k])
                        res.push(prop)
                    } else{
                        prop = convertToProp("id2")(x[k])
                        res.push(prop)
                    } 
                }
                prestoDayum(dom.type,props,dom.children);
                return res
            }
        }
    }
}

exports.getVdom = function(){
    var insertObject = (window.parent.serverSideKeys || {}).vdom;
    var x = prestoUI.prestoClone(insertObject["dom"])
    return x
}

exports.throwError = function(key){
    return function(err){
        tracker._trackException("lifecycle")("microapp")("presto_exception")(key)(err)();
        throw err;
    }
}