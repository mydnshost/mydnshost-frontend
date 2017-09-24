<H1>
	User :: Statistics
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

<div data-graph="{{ url("/profile/stats.json") }}" style="width: 100%; height: 700px"></div>

<a href="{{ url("/profile") }}" class="btn btn-primary btn-block" role="button">Back</a>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script src="{{ url('/assets/stats.js') }}"></script>
