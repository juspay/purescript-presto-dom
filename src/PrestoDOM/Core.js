"use strict";
const prestoDayum = require("presto-ui").doms;
const webParseParams = require("presto-ui").helpers.web.parseParams;
const iOSParseParams = require("presto-ui").helpers.ios.parseParams;
const parseParams = require("presto-ui").helpers.android.parseParams;
const R = require("ramda");


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
  // console.log("REPLACE VIEW", element.__ref.__id, element.props);
  const props = R.clone(element.props);
  props.id = element.__ref.__id;
  var rep;
  const viewGroups = ["linearLayout", "relativeLayout", "scrollView", "frameLayout", "horizontalScrollView"];

  if (viewGroups.indexOf(element.type) != -1){
    props.root = true;
    rep = prestoDayum(element.type, props, []);
  } else if (window.__OS == "ANDROID") {
    rep = prestoDayum({elemType: element.type, parentType: element.parentNode.type}, props, []);
  } else {
    rep = prestoDayum(element.type, props, []);
  }
  if(window.__OS == "ANDROID"){
    Android.replaceView(JSON.stringify(rep), element.__ref.__id);
  } else {
    Android.replaceView(rep, element.__ref.__id);
  }
}



window.removeChild = removeChild;
window.addChild = addChild;
window.replaceView = replaceView;
window.addProperty = addAttribute;
// window.removeAttribute = removeAttribute;
window.updateProperty = updateAttribute;
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
  // console.log("Add child :", child.__ref.__id, child.type);
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
  element.props[attribute.value0] = attribute.value1;
  applyProp(element, attribute, true);
}

function removeAttribute(element, attribute) {
  // console.log("remove attr :", attribute);
    replaceView(element, attribute, true);
}

function updateAttribute(element, attribute) {
  // console.log("update attr :", attribute);
  element.props[attribute.value0] = attribute.value1;

  applyProp(element, attribute, false);
}


exports.setRootNode = function(nothing) {
  return function () {
    var root = {type: "relativeLayout", props: {root: "true"}, children: []};

    root.props.height = "match_parent";
    root.props.width = "match_parent";
    root.props.id = typeof Android.getNewID == "function" ?  parseInt(Android.getNewID()) : window.__PRESTO_ID++;
    root.type = "relativeLayout";
    root.__ref = window.createPrestoElement();

    window.N = root;
    window.__CACHELIMIT = 50;
    window.__prevScreenName = nothing;
    window.__currScreenName = nothing;
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

}

exports.getRootNode = function() {
  return window.N;
}

exports.saveScreenNameImpl = function(screen) {
  return function() {
    window.__prevScreenName = window.__currScreenName;
    window.__currScreenName = screen;
  }
}

exports.getPrevScreen = function() {
    return window.__prevScreenName;
}

// exports.logMe = function(tag) {
//   return function(a) {
//     console.log(tag, "!!! : ",a);
//     return a;
//   }
// }

exports.emitter = function(a) {
    return function() {
      a();
      console.log("Logger !!! : ",a);
    }
}

window.__popScreen = popScreen;

function popScreen() {
  var __id = window.__ROOTSCREEN.idSet.child.pop();

  Android.removeView(__id);

  var length =  window.__ROOTSCREEN.idSet.child.length;
  var prop = {
      id: window.__ROOTSCREEN.idSet.child[length - 1],
      visibility: "visible"
  }

  if (window.__OS == "ANDROID" && length > 1) {
    var cmd = cmdForAndroid(prop, true);
    Android.runInUI(cmd, null);
  } else if (window.__OS == "IOS"  && length > 1){
    Android.runInUI(prop);
  } else if (length > 1) {
    Android.runInUI(webParseParams("relativeLayout", prop, "set"));
  }

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

      var length = window.__ROOTSCREEN.idSet.child.push(dom.__ref.__id);
      if (length >= window.__CACHELIMIT) {
        window.__ROOTSCREEN.idSet.child.shift();
        length -= 1;
      }

      var prop = {
          id: window.__ROOTSCREEN.idSet.child[length - 2],
          visibility: "gone"
      }

      if (window.__OS == "ANDROID" && length > 1) {
        var cmd = cmdForAndroid(prop, true);
        Android.runInUI(cmd, null);
      } else if (window.__OS == "IOS"  && length > 1){
        Android.runInUI(prop);
      } else if (length > 1) {
        Android.runInUI(webParseParams("relativeLayout", prop, "set"));
      }

      if (window.__OS == "ANDROID") {
        Android.addViewToParent(rootId, JSON.stringify(domAll(dom)), length - 1, null, null);
      }
      else {
        Android.addViewToParent(rootId, domAll(dom), length - 1, null, null);
      }

    }
  }
}
