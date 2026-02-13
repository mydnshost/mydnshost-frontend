<H1>
	Admin :: Statistics
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

<select class="form-select mb-3 stats-time-selector">
	<option value="3600" selected>Last Hour</option>
	<option value="21600">Last 6 Hours</option>
	<option value="43200">Last 12 Hours</option>
	<option value="172800">Last 48 Hours</option>
	<option value="604800">Last Week</option>
	<option value="2592000">Last Month</option>
	<option value="5184000">Last 2 Months</option>
	<option value="15552000">Last 6 Months</option>
	<option value="31536000">Last Year</option>
</select>

<div data-graph="{{ url("/admin/stats/queries-per-server.json") }}" data-title="Queries per server" style="width: 100%; height: 700px"></div>
<div data-graph="{{ url("/admin/stats/queries-per-rrtype.json") }}" data-title="Queries per rrtype" style="width: 100%; height: 700px"></div>
<div data-graph="{{ url("/admin/stats/queries-per-zone.json") }}" data-title="Queries per zone" style="width: 100%; height: 700px"></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.9.0/d3.min.js"></script>
<script src="{{ url('/assets/stats.js') }}"></script>
