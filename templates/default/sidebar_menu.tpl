<div class="nav-link">
<strong>
Domains List
</strong>
<input class="form-control" id="sidebarsearch" value="" placeholder="Domain Search...">
</div>

{% for section in menu %}
	<ul class="nav nav-pills flex-column">
	{% for item in section %}
		<li class="nav-item" {% if item.dataValue %}data-value="{{ item.dataValue }}"{% endif %}>
			{% if item.link %}
				<a class="nav-link{% if item.active %} active{% endif %}" href="{{ item.link }}">
			{% else %}
				<div class="nav-link"><strong>
			{% endif %}
			{{ item.title }}
			{% if item.active %}<span class="sr-only">(current)</span>{% endif %}
			{% if item.link %}
				</a>
			{% else %}
				</strong></div>
			{% endif %}
		</li>
	{% endfor %}
	</ul>
{% endfor %}
