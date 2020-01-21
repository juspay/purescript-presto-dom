var PrestoDOM_Properties = require("../PrestoDOM.Properties/index.js");
var PrestoDOM_Types_DomAttributes = require("../PrestoDOM.Types.DomAttributes/index.js");

var getLoggerComponent;

if (process.env.NODE_ENV === "development") {
  var hasLoggedStackWarning = false;

  function logStackWarning(stacks) {
    if (!hasLoggedStackWarning) {
      hasLoggedStackWarning = true;
      console.warn(
        "Unable to find PrestoDOM.Elements.Elements in stack trace. Presto Chrome plugin will not work. Please check webpack config `devtool` option to fix this.",
        stacks
      );
    }
  }

  function detectFileFromError(err) {
    try {
      const stacks = err.stack.split("\n");
      const lastIndex = stacks
        .map(function(msg) {
          return msg.includes("PrestoDOM.Elements.Elements");
        })
        .lastIndexOf(true);

      if (lastIndex !== -1) {
        const arr = stacks
          .slice(lastIndex + 1)
          .map(function(nextInStack) {
            return nextInStack.match(/webpack:\/\/\/\.\/output\/(.*.js)/);
          })
          .filter(Boolean)
          .map(function(match) {
            return match[1].replace(/\/index\.js$/, "");
          })
          .filter(function(fileName) {
            return fileName !== "Effect.Aff/foreign.js";
          });
        if (arr.length > 0) {
          return arr.join(", ");
        } else {
          console.warn("Unable to find module from stack", stacks);
        }
      } else {
        logStackWarning(stacks);
      }
    } catch (err2) {
      // console.error("caller error 2", err2);
    }
  }

  function addModuleInfoToProps(props) {
    const err = new Error("hello");

    const fileName = detectFileFromError(err);
    var newProps = props;

    if (fileName) {
      const moduleSource1 = PrestoDOM_Properties.width(
        PrestoDOM_Types_DomAttributes.MATCH_PARENT.value
      );
      moduleSource1.value0 = "module";
      moduleSource1.value1 = fileName;
      const moduleSource2 = PrestoDOM_Properties.width(
        PrestoDOM_Types_DomAttributes.MATCH_PARENT.value
      );
      moduleSource2.value0 = "moduleErrStack";
      moduleSource2.value1 = err.stack;
      if (Array.isArray(props)) {
        newProps = [moduleSource1, moduleSource2].concat(props);
      }
    }
    return newProps;
  }

  getLoggerComponent = function(component) {
    return function(props) {
      const newProps = addModuleInfoToProps(props);
      return component(newProps);
    };
  };
} else {
  getLoggerComponent = function(component) {
    return component;
  };
}

exports["getLoggerComponent"] = getLoggerComponent;
