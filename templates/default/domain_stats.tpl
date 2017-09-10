<H1>
	Domain :: {{ domain.domain }} :: Statistics
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

<div id="chart" data-pathprepend="{{pathprepend}}" data-domain="{{domain.domain}}" style="width: 100%; height: 700px"></div>

<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary btn-block" role="button">Back</a>

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script src="{{ url('/assets/domain_stats.js') }}"></script>
