/**
 * Const state has been added as purescript optimize compile removes variables defined with `var`
 * taggedViews: Id counter for views with holder properties
 * holderViews: Holds view holder object containing properties to be applied
 */
const state = {
    taggedViews: 0,
    holderViews: []
}


const HOLDER = "holder_";

/**
 * Extracts the view object consumable by domAll and trims the "holder_*" properties 
 * Maps holder_* properties object to holderViews
 * @param {*} vdom halogen vdom structure
 */
function extractView(vdom) {
    // const attrs = vdom.value0;
    // const children = vdom.value1;
    // const propArray = attrs.value2;

    const children = vdom.value3;
    const propArray = vdom.value2;

    const type = vdom.value1;
    const props = {};

    const holderObj = {};
    var holderViewId = -1;

    for (var i = 0, len = propArray.length; i < len; i++) {
        const name = propArray[i].value0;
        const value = propArray[i].value1;
        if (name.indexOf(HOLDER) === 0) {
            if (holderViewId === -1) {
                holderViewId = ++state.taggedViews;
                state.holderViews.push(holderObj);
                holderObj["id"] = holderViewId;
            }
            holderObj[name.substr(HOLDER.length)] = value;
        } else {
            props[name] = value;
        }
    }

    if (holderViewId !== -1) {
        props["id"] = holderViewId;
    }

    return {
        type: type,
        props: props,
        children: children.map(extractView)
    }
}

/**
 * FFI for creating list item instance to be consumed by the 
 */
exports._createListItem = function (vdomView) {
    return function (domAll) {
        state.taggedViews = 200000;
        state.holderViews = [];
        const itemView = domAll(extractView(vdomView));
        const data = {
            itemView: itemView,
            holderViews: state.holderViews,
        };
        return JSON.stringify(data);
    }
}
