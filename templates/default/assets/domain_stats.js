// Load the Visualization API and the piechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(loadChartData);

function loadChartData() {
	var domain = $('#chart').data('domain');
	var pathprepend = $('#chart').data('pathprepend');

	$.getJSON("{{ url('/') }}" + pathprepend + "/domain/" + domain + "/stats.json", function (data) {
		drawChart(data);
	});
}

function drawChart(statsData) {
	var keys = $.map(statsData["stats"], function(element,index) {return index});

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

			console.log(time);
			timedata[time][keys.indexOf(rrtype) + 1] = value;
		});
	});

	$.each(timedata, function(k, v) {
		data.addRow(v);
	});

	// Instantiate and draw our chart, passing in some options.
	var chart = new google.visualization.AreaChart(document.getElementById('chart'));

	var options = {
		title: 'Domain Queries-per-rrtype',
		hAxis: {title: 'Time',  titleTextStyle: {color: '#333'}},
		vAxis: {title: 'Queries',  minValue: 0},
	};
	chart.draw(data, options);
}
