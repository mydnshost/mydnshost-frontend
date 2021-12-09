	<div class="alert alert-{{ type }} alert-dismissible fade show" role="alert">
		<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
		{% if title %}<h4 class="alert-heading">{{ title }}</h4>{% endif %}
		{% if message is iterable %}
			{{ message | join("\n") | nl2br }}
		{% else %}
			{{ message }}
		{% endif %}
	</div>
