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
			{% if item.labelKey %}
				<a href="#" class="rename-label-link" data-label="{{ item.labelKey }}" title="Rename label"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M12.146.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1 0 .708l-10 10a.5.5 0 0 1-.168.11l-5 2a.5.5 0 0 1-.65-.65l2-5a.5.5 0 0 1 .11-.168l10-10zM11.207 2.5 13.5 4.793 14.793 3.5 12.5 1.207 11.207 2.5zm1.586 3L10.5 3.207 4 9.707V10h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.293l6.5-6.5zm-9.761 5.175-.106.106-1.528 3.821 3.821-1.528.106-.106A.5.5 0 0 1 5 12.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.468-.325z"/></svg></a>
			{% endif %}
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
