(function() {
	const defaultColors = ['#3366cc', '#dc3912', '#ff9900', '#109618', '#990099', '#0099c6', '#dd4477', '#66aa00', '#b82e2e', '#316395'];

	function loadChartData(timeSeconds) {
		document.querySelectorAll('div[data-graph]').forEach(function(element) {
			// Clear any previous chart content
			element.innerHTML = '';

			const baseUrl = element.getAttribute('data-graph');
			const separator = baseUrl.indexOf('?') === -1 ? '?' : '&';
			const dataSource = timeSeconds ? baseUrl + separator + 'time=' + timeSeconds : baseUrl;

			fetch(dataSource)
				.then(function(response) { return response.json(); })
				.then(function(data) { drawChart(element, data, timeSeconds); });
		});
	}

	function drawChart(element, statsData, timeSeconds) {
		const keys = Object.keys(statsData.stats);
		if (keys.length === 0) return;

		// Derive theme colors from computed styles
		const computedStyle = getComputedStyle(element);
		const textColor = computedStyle.color || '#333';
		const mutedColor = computedStyle.getPropertyValue('--bs-secondary-color').trim() || '#aaa';
		const bgColor = computedStyle.getPropertyValue('--bs-body-bg').trim() || '#fff';

		const isStacked = statsData.options && statsData.options.isStacked;
		const graphTitle = element.getAttribute('data-title') || (statsData.options && statsData.options.title) || '';
		const yAxisLabel = (statsData.options && statsData.options.vAxis && statsData.options.vAxis.title) || '';

		// Build time-indexed data from the stats object
		const timeMap = {};
		keys.forEach(function(seriesName) {
			statsData.stats[seriesName].forEach(function(point) {
				const time = point.time;
				if (!timeMap[time]) {
					timeMap[time] = { date: new Date(time * 1000) };
					keys.forEach(function(k) { timeMap[time][k] = 0; });
				}
				timeMap[time][seriesName] = point.value;
			});
		});

		const data = Object.values(timeMap).sort(function(a, b) { return a.date - b.date; });
		if (data.length === 0) return;

		// Track visibility per series
		const visibility = {};
		keys.forEach(function(k) { visibility[k] = true; });

		// Dimensions
		const containerWidth = element.clientWidth || 900;
		const containerHeight = element.clientHeight || 700;
		const legendWidth = 180;
		const margin = { top: 40, right: legendWidth + 20, bottom: 40, left: 70 };
		const width = containerWidth - margin.left - margin.right;
		const height = containerHeight - margin.top - margin.bottom;

		// Color scale
		const color = function(i) { return defaultColors[i % defaultColors.length]; };

		// Create SVG
		const svg = d3.select(element)
			.append('svg')
			.attr('width', containerWidth)
			.attr('height', containerHeight);

		const chartGroup = svg.append('g')
			.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

		// Title
		if (graphTitle) {
			svg.append('text')
				.attr('x', containerWidth / 2)
				.attr('y', 20)
				.attr('text-anchor', 'middle')
				.style('font-size', '14px')
				.style('font-weight', 'bold')
				.style('fill', textColor)
				.text(graphTitle);
		}

		// Scales
		const x = d3.scaleTime().range([0, width]);
		const y = d3.scaleLinear().range([height, 0]);

		// Axes groups
		const xAxisGroup = chartGroup.append('g')
			.attr('transform', 'translate(0,' + height + ')');
		const yAxisGroup = chartGroup.append('g');

		// Y axis label
		if (yAxisLabel) {
			chartGroup.append('text')
				.attr('transform', 'rotate(-90)')
				.attr('y', -margin.left + 15)
				.attr('x', -height / 2)
				.attr('text-anchor', 'middle')
				.style('font-size', '12px')
				.style('fill', textColor)
				.text(yAxisLabel);
		}

		// Clip path so areas don't overflow
		chartGroup.append('defs').append('clipPath')
			.attr('id', 'clip-' + Math.random().toString(36).substring(2, 11))
			.append('rect')
			.attr('width', width)
			.attr('height', height);

		const clipId = chartGroup.select('clipPath').attr('id');
		const areaGroup = chartGroup.append('g')
			.attr('clip-path', 'url(#' + clipId + ')');

		// Tooltip
		const tooltip = d3.select(element)
			.append('div')
			.style('position', 'absolute')
			.style('background', bgColor)
			.style('color', textColor)
			.style('border', '1px solid ' + mutedColor)
			.style('border-radius', '4px')
			.style('padding', '8px')
			.style('font-size', '12px')
			.style('pointer-events', 'none')
			.style('opacity', 0)
			.style('z-index', 10);

		// Make container relative for tooltip positioning
		element.style.position = 'relative';

		// Legend (right side, scrollable HTML div)
		const legendDiv = d3.select(element)
			.append('div')
			.style('position', 'absolute')
			.style('top', margin.top + 'px')
			.style('right', '0')
			.style('width', legendWidth + 'px')
			.style('max-height', height + 'px')
			.style('overflow-y', 'auto')
			.style('font-size', '11px');

		function buildLegend() {
			legendDiv.selectAll('*').remove();

			keys.forEach(function(key, i) {
				const item = legendDiv.append('div')
					.style('display', 'flex')
					.style('align-items', 'center')
					.style('gap', '4px')
					.style('padding', '2px 4px')
					.style('cursor', 'pointer')
					.style('white-space', 'nowrap')
					.style('overflow', 'hidden')
					.style('text-overflow', 'ellipsis')
					.on('click', function() {
						visibility[key] = !visibility[key];
						render();
					});

				item.append('span')
					.style('display', 'inline-block')
					.style('width', '12px')
					.style('height', '12px')
					.style('min-width', '12px')
					.style('border-radius', '2px')
					.style('background', visibility[key] ? color(i) : '#e0e0e0');

				item.append('span')
					.style('color', visibility[key] ? textColor : mutedColor)
					.style('overflow', 'hidden')
					.style('text-overflow', 'ellipsis')
					.text(key)
					.attr('title', key);
			});
		}

		// Overlay for tooltip interaction
		const overlay = chartGroup.append('rect')
			.attr('width', width)
			.attr('height', height)
			.attr('fill', 'none')
			.attr('pointer-events', 'all');

		const hoverLine = chartGroup.append('line')
			.attr('y1', 0)
			.attr('y2', height)
			.attr('stroke', '#999')
			.attr('stroke-width', 1)
			.attr('stroke-dasharray', '4,4')
			.style('opacity', 0);

		// Choose x-axis time format based on selected range
		function getTimeFormat() {
			if (!timeSeconds || timeSeconds <= 172800) {
				return d3.timeFormat('%H:%M');
			} else if (timeSeconds <= 604800) {
				return d3.timeFormat('%a %H:%M');
			} else if (timeSeconds <= 5184000) {
				return d3.timeFormat('%b %d');
			} else {
				return d3.timeFormat('%b %Y');
			}
		}

		overlay
			.on('mousemove', function(event) {
				const [mx] = d3.pointer(event);
				const hoveredDate = x.invert(mx);
				const bisect = d3.bisector(function(d) { return d.date; }).left;
				let idx = bisect(data, hoveredDate);
				if (idx >= data.length) idx = data.length - 1;
				if (idx > 0) {
					const d0 = data[idx - 1];
					const d1 = data[idx];
					if (hoveredDate - d0.date > d1.date - hoveredDate) idx = idx;
					else idx = idx - 1;
				}
				const d = data[idx];
				if (!d) return;

				hoverLine
					.attr('x1', x(d.date))
					.attr('x2', x(d.date))
					.style('opacity', 1);

				const visibleKeys = keys.filter(function(k) { return visibility[k]; });
				let html = '<strong>' + d3.timeFormat('%Y-%m-%d %H:%M')(d.date) + '</strong>';
				visibleKeys.forEach(function(k) {
					const ci = keys.indexOf(k);
					html += '<br><span style="color:' + color(ci) + '">&#9679;</span> ' + k + ': ' + (d[k] != null ? d[k] : 0);
				});

				tooltip.html(html).style('opacity', 1);

				// Position tooltip
				const tooltipNode = tooltip.node();
				const tipWidth = tooltipNode.offsetWidth;
				let tipX = x(d.date) + margin.left + 15;
				if (tipX + tipWidth > containerWidth - 10) {
					tipX = x(d.date) + margin.left - tipWidth - 15;
				}
				tooltip.style('left', tipX + 'px').style('top', (margin.top + 10) + 'px');
			})
			.on('mouseleave', function() {
				tooltip.style('opacity', 0);
				hoverLine.style('opacity', 0);
			});

		function render() {
			const visibleKeys = keys.filter(function(k) { return visibility[k]; });

			// Clear previous paths before redrawing
			areaGroup.selectAll('*').remove();

			// Update scales
			x.domain(d3.extent(data, function(d) { return d.date; }));

			if (isStacked && visibleKeys.length > 0) {
				const stack = d3.stack()
					.keys(visibleKeys)
					.value(function(d, key) { return d[key] || 0; })
					.order(d3.stackOrderNone)
					.offset(d3.stackOffsetNone);

				const stackedData = stack(data);

				y.domain([0, d3.max(stackedData, function(layer) {
					return d3.max(layer, function(d) { return d[1]; });
				}) || 1]).nice();

				// Draw stacked areas
				const area = d3.area()
					.x(function(d) { return x(d.data.date); })
					.y0(function(d) { return y(d[0]); })
					.y1(function(d) { return y(d[1]); });

				const areas = areaGroup.selectAll('path.area')
					.data(stackedData, function(d) { return d.key; });

				areas.exit().remove();

				areas.enter()
					.append('path')
					.attr('class', 'area')
					.merge(areas)
					.attr('d', area)
					.attr('fill', function(d) { return color(keys.indexOf(d.key)); })
					.attr('fill-opacity', 0.3)
					.attr('stroke', function(d) { return color(keys.indexOf(d.key)); })
					.attr('stroke-width', 1.5);
			} else {
				// Non-stacked: individual areas
				y.domain([0, d3.max(data, function(d) {
					let max = 0;
					visibleKeys.forEach(function(k) {
						if (d[k] > max) max = d[k];
					});
					return max;
				}) || 1]).nice();

				// Bind data as array of {key, values} objects
				const seriesData = visibleKeys.map(function(k) {
					return { key: k, values: data };
				});

				const groups = areaGroup.selectAll('g.series')
					.data(seriesData, function(d) { return d.key; });

				groups.exit().remove();

				const enter = groups.enter()
					.append('g')
					.attr('class', 'series');

				enter.append('path').attr('class', 'area-fill');
				enter.append('path').attr('class', 'area-line');

				const merged = enter.merge(groups);

				merged.datum(function(d) { return d.key; });

				merged.select('path.area-fill')
					.attr('d', function(key) {
						return d3.area()
							.x(function(d) { return x(d.date); })
							.y0(height)
							.y1(function(d) { return y(d[key] || 0); })
							(data);
					})
					.attr('fill', function(key) { return color(keys.indexOf(key)); })
					.attr('fill-opacity', 0.3);

				merged.select('path.area-line')
					.attr('d', function(key) {
						return d3.line()
							.x(function(d) { return x(d.date); })
							.y(function(d) { return y(d[key] || 0); })
							(data);
					})
					.attr('stroke', function(key) { return color(keys.indexOf(key)); })
					.attr('stroke-width', 1.5)
					.attr('fill', 'none');
			}

			// Update axes
			xAxisGroup.call(d3.axisBottom(x).ticks(8).tickFormat(getTimeFormat()));
			yAxisGroup.call(d3.axisLeft(y).ticks(6));

			// Style axes for current theme
			svg.selectAll('.tick text').style('fill', textColor);
			svg.selectAll('.tick line, .domain').style('stroke', mutedColor);

			buildLegend();
		}

		render();
	}

	function init() {
		const selector = document.querySelector('.stats-time-selector');
		var currentTime = selector ? selector.value : null;

		loadChartData(currentTime);

		if (selector) {
			selector.addEventListener('change', function() {
				currentTime = this.value;
				loadChartData(currentTime);
			});
		}
	}

	// Run when DOM is ready
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}
})();
