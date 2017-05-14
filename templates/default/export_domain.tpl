<H1>
	Domain :: {{ domain.domain }} :: Export
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

Below is the zone contents as a bind zone file.
<div class="form-group">
	<textarea rows="20" class="form-control mono">{{ zone | join("\n") }}</textarea>
</div>

<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary btn-block" role="button">Back</a>
