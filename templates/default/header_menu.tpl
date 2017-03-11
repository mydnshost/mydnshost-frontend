<ul class="navbar-nav mr-auto">
{% for item in menu %}
	<li class="nav-item{% if item.active %} active{% endif %}">
		<a class="nav-link" href="{{ item.link }}">{{ item.title }}{% if item.active %}<span class="sr-only">(current)</span>{% endif %}</a>
	</li>
{% endfor %}
</ul>
