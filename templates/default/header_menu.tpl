<ul class="navbar-nav me-auto mb-2 mb-lg-0">
{% for item in menu %}
	<li class="nav-item{% if item.active %} active{% endif %}">
		{% if item.link %}<a class="nav-link" href="{{ item.link }}">{% endif %}
		{{ item.title }}
		{% if item.active %}<span class="visually-hidden">(current)</span>{% endif %}
		{% if item.link %}</a>{% endif %}
	</li>
{% endfor %}
</ul>
