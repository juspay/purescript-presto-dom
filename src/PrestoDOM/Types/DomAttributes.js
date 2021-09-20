"use strict";

exports.stringifyGradient = function (type, angle, values) {
  var obj = {};
  obj["type"] = type;
  obj["angle"] = angle;
  obj["values"] = values;
  return JSON.stringify(obj);
};

exports.__IS_ANDROID = function () {
  return window.__OS == "ANDROID";
};

exports["toSafeInt"] = function (constructor) {
  return function (json) {
    return function (left) {
      return function (right) {
        if (json != undefined && !isNaN(parseInt(json))) {
          return right(constructor(parseInt(json)));
        } else return left("unable to parse into integer type");
      };
    };
  };
};

exports["toSafeString"] = function (json) {
  if (json != undefined) {
    if (typeof json == "string") {
      return json;
    } else if (typeof json == "number") {
      return json.toString();
    } else return "";
  } else return "";
};

exports["isUndefined"] = function (json) {
  return (json === undefined || json == null || json == NaN);
};

const mapTypes = function (dataArr, typeArr) {
  if (
    typeof typeArr == "object" &&
    typeof dataArr == "object" &&
    typeArr.length != undefined &&
    dataArr.length != undefined &&
    typeArr.length == dataArr.length
  ) {
    var newDataArr = [];
    for (
      var typeIndex = 0, dataIndex = 0;
      typeIndex < dataArr.length && dataIndex < typeArr.length;
      typeIndex++, dataIndex++
    ) {
      const typeEl = typeArr[typeIndex],
        dataEl = dataArr[dataIndex];
      if (typeof typeEl == "string") {
        switch (typeEl.toLowerCase()) {
          case "number":
            if (!isNaN(parseFloat(dataEl))) {
              newDataArr.push(parseFloat(dataEl));
            } else throw "Cannot parse element to number/float type";
            break;
          case "int":
            if (!isNaN(parseInt(dataEl))) {
              newDataArr.push(parseInt(dataEl));
            } else throw "Cannot parse element to integer type";
            break;
          case "string":
            if (typeof dataEl == "string") newDataArr.push(dataEl);
            else throw "Expected type to be string for this element";
            break;
          case "boolean":
            if (
              typeof dataEl == "boolean" ||
              (typeof dataEl == "string" &&
                (dataEl.toLowerCase() == "true" ||
                  dataEl.toLowerCase() == "false"))
            ) {
              newDataArr.push(dataEl);
            } else throw "Cannot parse element into boolean type";
            break;
          default:
            throw "Unsupported type";
        }
      } else {
        console.error("typeElement is not a string");
        throw "typeElement is not a string";
      }
    }
    return newDataArr;
  } else {
    console.error("Invalid typeArray and dataArray");
    throw "This format is not Supported \nInvalid typeArray and dataArray";
  }
};

exports["toSafeArray"] = function (dataConstructor) {
  return function (dataArray) {
    return function (left) {
      return function (right) {
        return function (typeArray) {
          try {
            const newDataArray = mapTypes(dataArray, typeArray);
            for (var i = 0; i < newDataArray.length; i++) {
              dataConstructor = dataConstructor(newDataArray[i]);
            }
            return right(dataConstructor);
          } catch (e) {
            return left(e);
          }
        };
      };
    };
  };
};

exports["toSafeGradientType"] = function (json) {
  return function (left) {
    return function (right) {
      try {
        if (
          json != undefined &&
          typeof json == "object" &&
          json.angle != undefined &&
          !isNaN(parseFloat(json.angle)) &&
          json.values != undefined &&
          typeof json.values == "object" &&
          json.values.length != undefined
        ) {
          return right(json);
        } else return left("Unsupported Gradient format");
      } catch (err) {
        console.error("Presto-DOM :: Exception in gradient parse", err);
        return left(err);
      }
    };
  };
};

exports["toSafeObject"] = function (json) {
  return function (left) {
    return function (right) {
      if (
        json != undefined &&
        typeof json == "object" &&
        json.type != undefined &&
        typeof json.type == "string" &&
        json.value != undefined &&
        typeof json.value == "string"
      ) {
        return right(json);
      } else {
        console.error(json);
        return left("Unsupported Object format");
      }
    };
  };
};
