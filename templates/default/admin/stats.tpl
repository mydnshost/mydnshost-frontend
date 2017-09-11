<H1>
	Admin :: Statistics
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

<div data-graph="{{ url("/admin/stats/queries-per-server.json") }}" data-title="Queries per server" style="width: 100%; height: 700px"></div>
<div data-graph="{{ url("/admin/stats/queries-per-rrtype.json") }}" data-title="Queries per rrtype" style="width: 100%; height: 700px"></div>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script src="{{ url('/assets/stats.js') }}"></script>
