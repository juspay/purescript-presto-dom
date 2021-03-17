"use strict";
const prestoDayum = require("presto-ui").doms;
const parseParams = require("presto-ui").helpers.web.parseParams;
const R = require("presto-ui");


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
  // if (!element.props.name) {
  //   throw Error("Define name on a node with an event");
  // }
  if (eventType == "onBackPressed") {
    element.props["onClick"] = function(e) {
      window.onBackPressed();
    }
  }
  else {
    element.props[eventType] = function(e) {
      value(e)();
    }
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
  return {type: "relativeLayout", props: {root: "true"}, children: [{type: "relativeLayout", props: {}, children: []}]};
}

exports.insertDom = insertDom;

window.__PRESTO_ID = 1;

function domAll(elem) {
  if (!elem.__ref) {
    elem.__ref = window.createPrestoElement();
  }

  if (elem.props.id) {
    elem.__ref.__id = elem.props.id;
  }

  const type = R.prestoClone(elem.type);
  const props = R.prestoClone(elem.props);
  const children = [];

  for (var i = 0; i < elem.children.length; i++) {
    children.push(domAll(elem.children[i]));
  }
  props.id = elem.__ref.__id;
  return prestoDayum(type, props, children);
}

function applyProp(element, attribute) {
  var prop = {
    id: element.__ref.__id
  }
  prop[attribute.value0] = attribute.value1;
  if (window.__OS == "ANDROID") {
    Android.runInUI(parseParams("linearLayout", prop, "set"), null);
  } else {
    Android.runInUI(parseParams("linearLayout", prop, "set"));
  }
  // Android.runInUI(parseParams("linearLayout", prop, "set"));
}

window.removeChild = removeChild;
window.addChild = addChild;
window.addAttribute = addAttribute;
window.removeAttribute = removeAttribute;
window.updateAttribute = updateAttribute;
window.addAttribute = addAttribute;
window.insertDom = insertDom;
window.createPrestoElement = function () {
  return {
    __id: window.__PRESTO_ID++
  };
}
window.__screenSubs = {};

function removeChild(child, parent, index) {
  Android.removeView(child.__ref.__id);
}

function addChild(child, parent, index) {
  Android.addViewToParent(parent.__ref.__id, domAll(child), index);
}

function addAttribute(element, attribute) {
  applyProp(element, attribute);
}

function removeAttribute(element, attribute) {

}

function updateAttribute(element, attribute) {
  applyProp(element, attribute);
}

// exports.click = function () { }
// exports.getId = function () {
//   console.log("hererer");
//   return window.__PRESTO_ID++;
// }

function insertDom(root) {
  return function (dom) {
    return function () {
      root.props.height = "match_parent";
      root.props.width = "match_parent";
      root.props.id = window.__PRESTO_ID++;
      root.type = "relativeLayout";
      var holder = root.children[0];
      root.__ref = window.createPrestoElement();
      console.log("Root :", root);
      console.log("holder :", holder);
      holder.props.height = "match_parent";
      holder.props.width = "match_parent";
      holder.props.id = window.__PRESTO_ID++;
      holder.type = "relativeLayout";
      holder.__ref = window.createPrestoElement();

      holder.children.push(dom);
      dom.parentNode = holder;
      window.N = holder;

      if(window.__OS == "ANDROID"){
        Android.render(JSON.stringify(domAll(root)), null);
      } else if(window.__OS == "WEB"){
        Android.render(domAll(root), null);
      } else{
        Android.render(JSON.stringify(domAll(root)), null);
      }
      // Android.Render(domAll(root));
    }
  }
}
