"use strict";

var chart;

exports.createChart = function(viewId) {
  return function(chartData) {
    return function() {
			if(!window.widgets) {
				window.widgets = [];
			}

			var n = window.createPrestoElement();
			var fn = function (id_) {
				chart = new CanvasJS.Chart("" + id_, chartData);

				chart.render();
				console.log("I am here, Thunk", n);
			}
			window.widgets.push({fn: fn, id_: n.__id - 1});
			return document.getElementById(n.__id - 1);
    }
  }
}


exports.newDate = function(yy, mm, dd) {
  return new Date(yy, mm, dd);
}

exports.renderChart = function() {
  chart.render();
}

var tds = function (e){
  if (typeof(e.dataSeries.visible) === "undefined" || e.dataSeries.visible) {
      e.dataSeries.visible = false;
    } else{
        e.dataSeries.visible = true;
      }
  chart.render();
}

exports.toogleDataSeries = function(e){
	if (typeof(e.dataSeries.visible) === "undefined" || e.dataSeries.visible) {
		e.dataSeries.visible = false;
	} else{
		e.dataSeries.visible = true;
	}
	chart.render();
}

