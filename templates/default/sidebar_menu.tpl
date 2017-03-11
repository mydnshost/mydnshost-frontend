{% for section in menu %}
	<ul class="nav nav-pills flex-column">
	{% for item in section %}
		<li class="nav-item">
			<a class="nav-link{% if item.active %} active{% endif %}" href="{{ item.link }}">{{ item.title }}{% if item.active %}<span class="sr-only">(current)</span>{% endif %}</a>
		</li>
	{% endfor %}
	</ul>
{% endfor %}
