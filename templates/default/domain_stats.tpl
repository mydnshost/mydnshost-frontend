<H1>
	Domain :: {{ domain.domain }} :: Statistics
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

<div data-graph="{{ url("#{pathprepend}/domain/#{domain.domain}/stats.json") }}" style="width: 100%; height: 700px"></div>

<div class="d-grid mt-2 gap-2">
	<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary" role="button">Back</a>
</div>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script src="{{ url('/assets/stats.js') }}"></script>
