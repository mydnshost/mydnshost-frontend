{% if title or showsearch %}
	<div class="nav-link text-black">
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
				{% if item.button %}
					<div class="nav-link">
						<div class="d-grid mt-2 gap-2">
					<a class="btn btn-{{ item.button }}"
				{% else %}
					<a class="nav-link{% if item.active %} active{% endif %}"
				{% endif %}
					href="{{ item.link }}"
					{% if item.action %} data-action="{{ item.action }}"{% endif %}
					{% if item.hover %} title="{{ item.hover }}"{% endif %}
				>


			{% elseif item.button %}
				<div class="nav-link">
				<div class="d-grid mt-2 gap-2">
				<button class="btn btn-{{ item.button }}" data-action="{{ item.action }}">
			{% else %}
				<div class="nav-link text-black"><strong>
			{% endif %}
			{% if item.badge %}
				<span class="badge {{ item.badge.classes | join(' ') }}" title="{{ item.badge.title }}">{{ item.badge.value }}</span>
			{% endif %}
			{{ item.title }}
			{% if item.subtitle %}<small class="subtitle">({{item.subtitle}})</small>{% endif %}
			{% if item.active %}<span class="visually-hidden">(current)</span>{% endif %}
			{% if item.link %}
				</a>
				{% if item.button %}
				</div>
				</div>
				{% endif %}
			{% elseif item.button %}
				</button></div></div>
			{% else %}
				</strong></div>
			{% endif %}
		</li>
	{% endfor %}
	</ul>
{% endfor %}
