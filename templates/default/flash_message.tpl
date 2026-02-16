	<div class="alert alert-{{ type }} alert-dismissible fade show" role="alert">
		<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
		{% if title %}<h4 class="alert-heading">{{ title }}</h4>{% endif %}
		{% if message is iterable %}
			{% for m in message %}
				{% if raw|default(false) %}{{ m|raw }}{% else %}{{ m }}{% endif %}{% if not loop.last %}<br>{% endif %}
			{% endfor %}
		{% else %}
			{% if raw|default(false) %}{{ message|raw }}{% else %}{{ message }}{% endif %}
		{% endif %}
	</div>
