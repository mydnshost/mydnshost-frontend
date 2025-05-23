// Load the Visualization API and the piechart package.
google.charts.load('current', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.charts.setOnLoadCallback(loadChartData);

function loadChartData() {
	$('div[data-graph]').each(function() {
		const element = this;
		const dataSource = $(element).data('graph');

		$.getJSON(dataSource, function (data) {
			drawChart(element, data);
		});
	});
}

function drawChart(element, statsData) {
	const keys = $.map(statsData["stats"], function(element,index) {return index});

	// TODO: Datatable should come from stats.
	const data = new google.visualization.DataTable();
	data.addColumn('datetime', 'Time');
	keys.forEach(function(value) {
		data.addColumn('number', value);
	});

	const timedata = {};
	$.each(statsData["stats"], function(rrtype, rrdata) {
		$.each(rrdata, function(k, v) {
			const time = v["time"];
			const value = v["value"];

			if (timedata[time] === undefined) {
				timedata[time] = new Array(keys.length + 1);
				timedata[time][0] = new Date(time * 1000);
			}

			timedata[time][keys.indexOf(rrtype) + 1] = value;
		});
	});

	$.each(timedata, (k, v) => { data.addRow(v); });

	let chartInstance;
	const baseChartOptions = JSON.parse(JSON.stringify(statsData["options"]));

	if (statsData['graphType'] === 'area') {
		chartInstance = new google.visualization.AreaChart(element);
	}

	const graphTitle = $(element).data('title');
	if (graphTitle !== undefined) {
		baseChartOptions['title'] = graphTitle;
	}

	if (chartInstance !== undefined) {
		// Store original series configurations and visibility state
		const seriesConfigurations = [];
		const defaultColors = ['#3366cc', '#dc3912', '#ff9900', '#109618', '#990099', '#0099c6', '#dd4477', '#66aa00', '#b82e2e', '#316395'];

		keys.forEach((key, index) => {
			let originalSeriesConfig = {};
			if (baseChartOptions.series && baseChartOptions.series[index]) {
				originalSeriesConfig = JSON.parse(JSON.stringify(baseChartOptions.series[index]));
			}

			if (!originalSeriesConfig.color) {
				originalSeriesConfig.color = defaultColors[index % defaultColors.length];
			}

			if (statsData['graphType'] === 'area') {
				if (originalSeriesConfig.lineWidth === undefined) { originalSeriesConfig.lineWidth = 2; }
				if (originalSeriesConfig.areaOpacity === undefined) { originalSeriesConfig.areaOpacity = 0.3; }
			}

			seriesConfigurations[index] = {
				original: originalSeriesConfig,
				visible: true,
			};
		});

		function prepareChartDataAndOptions() {
			const view = new google.visualization.DataView(data); // 'data' is the original DataTable
			const columnDefinitions = [0]; // Always include the domain column (index 0, e.g., 'Time')

			// The 'keys' array holds the names of the data series.
			// The original DataTable 'data' has columns: 0=Time, 1=keys[0], 2=keys[1], ...
			keys.forEach((keyName, originalSeriesIndex) => {
				// originalSeriesIndex is the 0-based index of the series in the 'keys' array
				// and corresponds to its configuration in 'seriesConfigurations'.

				if (seriesConfigurations[originalSeriesIndex].visible) {
					// If visible, use the original data column from the DataTable.
					// DataTable column index is originalSeriesIndex + 1.
					columnDefinitions.push(originalSeriesIndex + 1);
				} else {
					// If not visible, create a calculated column that returns null for all data points.
					// This effectively removes the series from rendering and stacking calculations.
					columnDefinitions.push({
						type: data.getColumnType(originalSeriesIndex + 1),
						label: data.getColumnLabel(originalSeriesIndex + 1),
						calc: () => null
					});
				}
			});
			view.setColumns(columnDefinitions);

			// Prepare chart drawing options
			let drawingOptions = JSON.parse(JSON.stringify(baseChartOptions));
			drawingOptions.series = {}; // Initialize series-specific options

			seriesConfigurations.forEach((config, originalSeriesIndex) => {
				// The 'series' option is 0-indexed based on the series columns in the DataView.
				// Since our DataView has a column for every original series (either real or null-calculated),
				// the originalSeriesIndex maps directly to the series index for styling purposes.
				if (config.visible) {
					drawingOptions.series[originalSeriesIndex] = JSON.parse(JSON.stringify(config.original));
				} else {
					// Style for hidden series' legend item
					drawingOptions.series[originalSeriesIndex] = {
						...JSON.parse(JSON.stringify(config.original)), // Retain other original settings
						color: '#E0E0E0', // Light grey color for the legend marker
					};
				}
			});
			return { dataView: view, options: drawingOptions };
		}

		google.visualization.events.addListener(chartInstance, 'select', function() {
			const selection = chartInstance.getSelection();

			if (selection.length > 0 && selection[0]) {
				const item = selection[0];
				let originalSeriesIndex = -1; // Index in the original 'keys' and 'seriesConfigurations'

				if (item.targetID && typeof item.targetID === 'string' && item.targetID.startsWith('legendentry#')) {
					const parsedIndex = parseInt(item.targetID.substring('legendentry#'.length), 10);
					if (!isNaN(parsedIndex)) {
						originalSeriesIndex = parsedIndex;
					}
				} else if (item.row === null && typeof item.column === 'number') {
					// For legend clicks, item.column is often the 1-based index in the *drawn data source* (DataView).
					// Since our DataView maintains a column for each original series,
					// item.column (1-based for series) corresponds to originalSeriesIndex (0-based).
					if (item.column > 0) {
						originalSeriesIndex = item.column - 1;
					}
				}

				if (originalSeriesIndex !== -1 && originalSeriesIndex >= 0 && originalSeriesIndex < seriesConfigurations.length) {
					seriesConfigurations[originalSeriesIndex].visible = !seriesConfigurations[originalSeriesIndex].visible;

					chartInstance.currentLegendPage = 0;
					for (const text of element.getElementsByTagName('text')) {
						if (text.getAttribute('text-anchor') === 'middle' && text.nextSibling == undefined && text.previousSibling == undefined) {
							var match = text.innerHTML.match(/^([0-9]+)\/[0-9]+$/);
							if (match) {
								chartInstance.currentLegendPage = match[1] - 1;
								break;
							}
						}
					};

					// Attempt to restore legend page
					if (chartInstance.currentLegendPage > 0) {
						google.visualization.events.addOneTimeListener(chartInstance, 'ready', function() {
							let clicksNeeded = chartInstance.currentLegendPage;

							function clickNextLegendPageRecursive() {
								if (clicksNeeded <= 0) {
									return;
								}

								let nextPageButton = undefined;
								for (const text of element.getElementsByTagName('text')) {
									if (text.getAttribute('text-anchor') === 'middle' && text.nextSibling == undefined && text.previousSibling == undefined) {
										var match = text.innerHTML.match(/^([0-9]+)\/[0-9]+$/);
										if (match) {
											nextPageButton = text.parentElement.nextSibling;
											break;
										}
									}
								}

								if (nextPageButton) {
									const clickEvent = new MouseEvent('click', {
										bubbles: true,
										cancelable: true,
										view: window
									});
									nextPageButton.dispatchEvent(clickEvent);

									clicksNeeded--;
									clickNextLegendPageRecursive();
								} else {
									clicksNeeded = 0;
								}
							}
							clickNextLegendPageRecursive();
						});
					}

					const { dataView, options } = prepareChartDataAndOptions();
					chartInstance.draw(dataView, options);
				}
			}
		});

		// Initial draw
		const { dataView, options } = prepareChartDataAndOptions();
		chartInstance.draw(dataView, options);
	}
}
