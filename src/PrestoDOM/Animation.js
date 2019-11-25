const state = {
	counter: 0,
	bitMap: {}
};

function getBit(propertyName) {
	if (!state.bitMap[propertyName]) {
		const value = (state.counter >= 32) ? propertyName : ++state.counter;
		state.bitMap[propertyName] = 1 << value;
	}
	return state.bitMap[propertyName];
}

function mapName(key, propertyName) {
	const propBitValue = getBit(propertyName);
	if (typeof key === "string" || typeof propBitValue === "string") {
		return "" + key + propBitValue;
	}
	return key | propBitValue;
}

function createAnimationObject(animation) {
	const animObj = {};
	var key = 0;
	for (var i = 0; i < animation.length; i++) {
		const tuple = animation[i];
		key = mapName(key, tuple.value0);
		animObj[tuple.value0] = tuple.value1;
	}
	animObj.name = key;
	return animObj;
}

exports._mergeAnimation = function (animations) {
	return JSON.stringify(animations.map(createAnimationObject));
}

exports.consoleLog = function(x) {
  console.log(x);
  return x;
}
