<H1>
	Domain :: {{ domain.domain }} :: Export
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

{% if zone %}
Below is the zone contents as a zone file.

<div class="form-group">
	<textarea rows="20" class="form-control mono">{{ zone | join("\n") }}</textarea>
</div>
{% endif %}

{% if exportTypes and exportTypes|length > 1 %}
	<div class="form-group">
		Show as:
		<ul>
			{% for type in exportTypes %}
				<li> <a href="{{ url("#{pathprepend}/domain/#{domain.domain}/export?type=#{type}") }}">{{ type }}{% if descriptions[type] %} - {{ descriptions[type] }}{% endif %}</a>
			{% endfor %}
		</ul>
	</div>
{% endif %}

<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary btn-block" role="button">Back</a>
