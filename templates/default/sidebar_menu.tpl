{% if title or showsearch %}
	<div class="nav-link">
		{% if title %}
			<strong>
				{{ title }}
			</strong>
		{% endif %}
		{% if showsearch %}
			<input class="form-control" data-search-top="nav#sidebar" value="" placeholder="Search...">
		{% endif %}
	</div>
{% endif %}

{% for section in menu %}
	<ul class="nav nav-pills flex-column">
	{% for item in section %}
		<li class="nav-item" {% if item.dataValue %}data-searchable-value="{{ item.dataValue }}"{% endif %}>
			{% if item.link %}
				<a class="nav-link{% if item.active %} active{% endif %}" href="{{ item.link }}">
			{% elseif item.button %}
				<div class="nav-link">
				<button class="btn btn-block btn-{{ item.button }}" data-action="{{ item.action }}">
			{% else %}
				<div class="nav-link"><strong>
			{% endif %}
			{{ item.title }}
			{% if item.active %}<span class="sr-only">(current)</span>{% endif %}
			{% if item.link %}
				</a>
			{% elseif item.button %}
				</button></div>
			{% else %}
				</strong></div>
			{% endif %}
		</li>
	{% endfor %}
	</ul>
{% endfor %}
