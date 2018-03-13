function attachAttributeList(element, attrList) {
  var key, value;

  for (var i = 0; i < attrList.length; i++) {
    key = attrList[i].value0;
    value = attrList[i].value1;
    if (typeof value == "function") {
      attachListener(element, key, value);
    } else {
      element.props[key] = value;
    }
  }

  return null;
}

function attachListener(element, eventType, value) {
  if (!element.props.name) {
    throw Error("Define name on a node with an event");
  }
  element.props[eventType] = function(e) {
    value(e)();
  }
}

exports.applyAttributes = function(element) {
  return function(attrList) {
    return function() {
      attachAttributeList(element, attrList);
      return attrList;
    }
  }
}

exports.patchAttributes = function(element) {
  return function(oldAttrList) {
    return function(newAttrList) {
      return function() {
        var attrFound = 0;

        for (var i=0; i<oldAttrList.length; i++) {
          attrFound = 0;
          for (var j=0; j<newAttrList.length; j++) {
            if (oldAttrList[i].value0 == newAttrList[j].value0) {
              attrFound = 1;

              if (oldAttrList[i].value1 !== newAttrList[j].value1) {
                oldAttrList[i].value1 = newAttrList[j].value1;
                updateAttribute(element, newAttrList[j]);
              }
            }
          }

          if (!attrFound) {
            oldAttrList[i].splice(i, 0);
            removeAttribute(element, oldAttrList[i]);
          }
        }

        for (var i=0; i<newAttrList.length; i++) {
          attrFound = 0;
          for (var j=0; j<oldAttrList.length; j++) {

            if (oldAttrList[j].value0 == newAttrList[i].value0) {
              attrFound = 1;
            }
          }

          if (!attrFound) {
            oldAttrList.push(newAttrList[i]);
            addAttribute(element, newAttrList[i]);
          }
        }

        return oldAttrList;
      }
    }
  }
}

exports.cleanupAttributes = function(element) {
  return function(attrList) {
    return function() {
      // console.log(element);
      // console.log(attrList);
    }
  }
}

exports.done = function() {
  console.log("done");
  return;
}

exports.logNode = function(node) {
  return function() {
    console.log(node);
  }
}

exports.storeMachine = function(machine) {
  return function() {
    window.MACHINE = machine;
  }
}

exports.getLatestMachine = function() {
  return window.MACHINE;
}

exports.getRootNode = function() {
  return {type: "linearLayout", props: {root: "true"}, children: []};
}

exports.insertDom = window.insertDom;

