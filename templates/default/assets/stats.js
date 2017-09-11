// Load the Visualization API and the piechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(loadChartData);

function loadChartData() {
	$('div[data-graph]').each(function() {
		var element = this;
		var dataSource = $(element).data('graph');

		$.getJSON(dataSource, function (data) {
			drawChart(element, data);
		});
	});
}

function drawChart(element, statsData) {
	var keys = $.map(statsData["stats"], function(element,index) {return index});

	// TODO: Datatable should come from stats.
	var data = new google.visualization.DataTable();
	data.addColumn('datetime', 'Time');
	$.each(keys, function(key, value) {
		data.addColumn('number', value);
	});

	var timedata = {};
	$.each(statsData["stats"], function(rrtype, rrdata) {
		$.each(rrdata, function(k, v) {
			var time = v["time"];
			var value = v["value"];

			if (timedata[time] == undefined) {
				timedata[time] = new Array(keys.length + 1);
				timedata[time][0] = new Date(time * 1000);
			}

			timedata[time][keys.indexOf(rrtype) + 1] = value;
		});
	});

	$.each(timedata, function(k, v) { data.addRow(v); });

	// Instantiate and draw our chart, passing in some options.
	var chart = undefined;
	var options = statsData["options"];

	if (statsData['graphType'] == 'area') {
		chart = new google.visualization.AreaChart(element);
	}

	var graphTitle = $(element).data('title');
	if (graphTitle != undefined) {
		options['title'] = graphTitle;
	}

	if (chart !== undefined) {
		chart.draw(data, options);
	}
}
