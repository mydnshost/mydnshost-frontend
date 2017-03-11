<H1>Domain :: {{ domain.domain }} :: Records</H1>

<table id="records" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="name">Name</th>
			<th class="type">Type</th>
			<th class="priority">Priority</th>
			<th class="content">Content</th>
			<th class="ttl">TTL</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for record in records %}
		<tr data-id="{{ record.id }}" class="{% if record.disabled == 'true' %}disabled{% endif %}">
			<td class="name" data-value="{{ record.name | e }}">
				{{ record.name | e }}
			</td>
			<td class="type" data-value="{{ record.type | e }}">
				{{ record.type | e }}
			</td>
			<td class="priority" data-value="{{ record.priority | e }}">
				{{ record.priority | e }}
			</td>
			<td class="content" data-value="{{ record.content | e }}">
				{{ record.content | e }}
			</td>
			<td class="ttl" data-value="{{ record.ttl | e }}">
				{{ record.ttl | e }}
			</td>
			<td class="actions">
				<button class="btn btn-sm btn-success" data-action="edit" role="button">Edit</button>

				{#
				{% if record.disabled == 'true' %}
					<button class="btn btn-sm btn-info" data-action="enable" role="button">Enable</button>
				{% else %}
					<button class="btn btn-sm btn-warning" data-action="disable" role="button">Disable</button>
				{% endif %}
				#}

				<button class="btn btn-sm btn-danger" data-action="delete" role="button">Delete</button>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<div class="row">
	<div class="col">
		<button href="#" class="btn btn-primary btn-block" data-action="add" role="button">Add Record</button>

		<a href="#" class="btn btn-success btn-block" role="button">Save Changes</a>
	</div>
</div>

<script src="{{ url('/assets/records.js') }}"></script>
