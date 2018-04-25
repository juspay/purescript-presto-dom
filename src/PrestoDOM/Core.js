"use strict";
const prestoDayum = require("presto-ui").doms;
const webParseParams = require("presto-ui").helpers.web.parseParams;
const iOSParseParams = require("presto-ui").helpers.ios.parseParams;
const parseParams = require("presto-ui").helpers.android.parseParams;
const R = require("ramda");

window.__pDom = prestoDayum;

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

          if (oldAttrList[i] != null) {
            attrFound = 0;
            for (var j=0; j<newAttrList.length; j++) {
              if (oldAttrList[i].value0 == newAttrList[j].value0) {
                attrFound = 1;

                if (oldAttrList[i].value1 !== newAttrList[j].value1) {
                  element.props[oldAttrList[i].value0] = newAttrList[j].value1;
                  oldAttrList[i].value1 = newAttrList[j].value1;
                  updateAttribute(element, newAttrList[j]);
                }
              }
            }

            if (!attrFound) {
              attrFound = true;
              delete element.props[oldAttrList[i].value0];
              removeAttribute(element, oldAttrList[i]);
              oldAttrList[i] = null;
            }
          }
        }

        // oldAttrList = oldAttrList.filter(function (a) {return a;})

        for (var i=0; i<newAttrList.length; i++) {
          attrFound = 0;
          for (var j=0; j<oldAttrList.length; j++) {

            if (oldAttrList[j] != null && (oldAttrList[j].value0 == newAttrList[i].value0)) {
              attrFound = 1;
            }
          }

          if (!attrFound) {
            element.props[newAttrList[i].value0] = newAttrList[i].value1;
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

// exports.done = function() {
//   console.log("done");
//   return;
// }


exports.storeMachine = function(machine) {
  return function() {
    window.MACHINE = machine;
  }
}

exports.getLatestMachine = function() {
  return window.MACHINE;
}

exports.insertDom = insertDom;

window.__PRESTO_ID =  typeof Android.getNewID == "function" ?  parseInt(Android.getNewID()) : 1;

function domAll(elem) {
  if (!elem.__ref) {
    elem.__ref = window.createPrestoElement();
  }

  if (elem.props.id) {
    elem.__ref.__id = elem.props.id;
  }

  const type = R.clone(elem.type);
  const props = R.clone(elem.props);
  const children = [];

  for (var i = 0; i < elem.children.length; i++) {
    children.push(domAll(elem.children[i]));
  }
  props.id = elem.__ref.__id;
  if(elem.parentType && window.__OS == "ANDROID")
    return prestoDayum({elemType: type, parentType: elem.parentType}, props, children);

  return prestoDayum(type, props, children);
}

function cmdForAndroid(config, set) {
  if (set) {
    var cmd = parseParams("linearLayout", config, "set").runInUI.replace("this->setId", "set_view=ctx->findViewById").replace(/this->/g, "get_view->");
    cmd = cmd.replace(/PARAM_CTR_HOLDER.*;/g, "get_view->getLayoutParams;");

    return cmd;
  }

  var cmd = "set_view=ctx->findViewById:i_" + config.id + ";";
  var runInUI;
  delete config.id;
  config.root = "true";
  runInUI = parseParams("linearLayout", config, "get").runInUI;
  cmd += runInUI + ';';
  return cmd;
}

function applyProp(element, attribute, set) {
  if (typeof attribute.value1 == "function") {
    // replaceView(element, attribute, false);
    return;
  }
  var prop = {
    id: element.__ref.__id
  }
  prop[attribute.value0] = attribute.value1;
  if (window.__OS == "ANDROID") {
      var cmd = cmdForAndroid(prop, set);
      Android.runInUI(cmd, null);
  } else if (window.__OS == "IOS"){
    Android.runInUI(prop);
  } else {
    Android.runInUI(webParseParams("linearLayout", prop, "set"));
  }
  // Android.runInUI(parseParams("linearLayout", prop, "set"));
}

function replaceView(element, attribute, removeProp) {
  const props = R.clone(element.props);
  props.id = element.__ref.__id;
  var rep;
  const viewGroups = ["linearLayout", "relativeLayout", "scrollView", "frameLayout", "horizontalScrollView"];

  // if (removeProp) {
  //   delete props[attribute.value0];
  // } else {
  //    props[attribute.value0] = attribute.value1;
  // }
  if (viewGroups.indexOf(element.type) != -1){
      props.root = true;
      rep = prestoDayum(element.type, props, []);
    } else {
      rep = prestoDayum({elemType: element.type, parentType: element.parentNode.type}, props, []);
    }

  Android.replaceView(JSON.stringify(rep), element.__ref.__id);
}

window.removeChild = removeChild;
window.addChild = addChild;
window.addAttribute = addAttribute;
// window.removeAttribute = removeAttribute;
window.updateAttribute = updateAttribute;
window.addAttribute = addAttribute;
window.insertDom = insertDom;
window.createPrestoElement = function () {
  return {
    __id: typeof Android.getNewID == "function" ?  parseInt(Android.getNewID()) : window.__PRESTO_ID++
  };
}
window.__screenSubs = {};

function removeChild(child, parent, index) {
  // console.log("Remove child :", child.type);
  Android.removeView(child.__ref.__id);
}

function addChild(child, parent, index) {
  if(child.type == null) {
    console.log("child null");
  }
  // console.log("Add child :", child.type);
  const viewGroups = ["linearLayout", "relativeLayout", "scrollView", "frameLayout", "horizontalScrollView"];
  if (window.__OS == "ANDROID") {
    if (viewGroups.indexOf(child.type) != -1){
      child.props.root = true;
    } else {
      child.parentType = parent.type;
    }
    Android.addViewToParent(parent.__ref.__id, JSON.stringify(domAll(child)), index, null, null);
  }
  else
    Android.addViewToParent(parent.__ref.__id, domAll(child), index, null, null);
}

function addAttribute(element, attribute) {
  // console.log("add attr :", attribute);
  // if (typeof attribute.value1 === "function") {
  //   return;
  //   const fn = attribute.value1;
  //   attribute.value1 = function (e) {
  //     fn(e)();
  //   };
  // }
  // element.props[attribute.value0] = attribute.value1;
  applyProp(element, attribute, true);
}

function removeAttribute(element, attribute) {
  if (window.__OS == "ANDROID") {
    replaceView(element, attribute, true);

    return;
  }
    attribute.value1 = "";

  applyProp(element, attribute);
}

function updateAttribute(element, attribute) {
  // console.log("update attr :", attribute);

  applyProp(element, attribute, false);
}


exports.setRootNode = function() {
  var root = {type: "relativeLayout", props: {root: "true"}, children: []};

  root.props.height = "match_parent";
  root.props.width = "match_parent";
  root.props.id = typeof Android.getNewID == "function" ?  parseInt(Android.getNewID()) : window.__PRESTO_ID++;
  root.type = "relativeLayout";
  root.__ref = window.createPrestoElement();

  window.N = root;
  window.__ROOTSCREEN = {
    idSet: {
      root: root.props.id,
			child: []
    }
  };

  if(window.__OS == "ANDROID"){
    if(typeof Android.getNewID == "function") {
      Android.Render(JSON.stringify(domAll(root)), null, "false");
    } else {
      Android.Render(JSON.stringify(domAll(root)), null);
    }
  } else if (window.__OS == "WEB"){
    Android.Render(domAll(root), null);
  } else {
    Android.Render(domAll(root), null);
  }

	return root;

}

exports.getRootNode = function() {
  // return {type: "relativeLayout", props: {root: "true"}, children: []};
  return window.N;
}

function insertDom(root) {
  return function (dom) {
    return function () {

      root.children.push(dom);
      dom.parentNode = root;
      dom.__ref = window.createPrestoElement();
      window.N = root;

      var rootId = window.__ROOTSCREEN.idSet.root;


      dom.props.root = true;

      var index = window.__ROOTSCREEN.idSet.child.push(dom.__ref.__id);


      var prop = {
        id: window.__ROOTSCREEN.idSet.child[index - 2],
        visibility: "gone"
      }

      if (window.__OS == "ANDROID") {
        var cmd = cmdForAndroid(prop, true);
        Android.runInUI(cmd, null);
      } else if (window.__OS == "IOS"){
        Android.runInUI(prop);
      } else {
        Android.runInUI(webParseParams("relativeLayout", prop, "set"));
      }

      if (window.__OS == "ANDROID") {
        Android.addViewToParent(rootId, JSON.stringify(domAll(dom)), index - 1, null, null);
      }
      else {
        Android.addViewToParent(rootId, domAll(dom), index - 1, null, null);
      }

    }
  }
}
