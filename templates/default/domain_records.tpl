<H1>Domain :: {{ domain.domain }} :: Records</H1>

<form method="post">
<span><strong>Serial:</strong> {{ domain.SOA.serial }}</span>
<br><br>
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
		<tr data-id="{{ record.id }}"
		    class="{% if record.disabled == 'true' %} disabled{% endif %}"
			{% if record.edited %}data-edited="true"{% endif %}
			{% if record.deleted %}data-deleted="true"{% endif %}
			{% if record.errorData %}data-error-data="{{ record.errorData | e}}"{% endif %}
			>

			<td class="name" data-value="{{ record.name | e }}" {% if record.edited %}data-edited-value="{{record.edited.name | e}}"{% endif %}>
				{{ record.name | e }}
			</td>
			<td class="type" data-value="{{ record.type | e }}" {% if record.edited %}data-edited-value="{{record.edited.type | e}}"{% endif %}>
				{{ record.type | e }}
			</td>
			<td class="priority" data-value="{{ record.priority | e }}" {% if record.edited %}data-edited-value="{{record.edited.priority | e}}"{% endif %}>
				{{ record.priority | e }}
			</td>
			<td class="content" data-value="{{ record.content | e }}" {% if record.edited %}data-edited-value="{{record.edited.content | e}}"{% endif %}>
				{{ record.content | e }}
			</td>
			<td class="ttl" data-value="{{ record.ttl | e }}" {% if record.edited %}data-edited-value="{{record.edited.ttl | e}}"{% endif %}>
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


		{% for id,record in newRecords %}
		<tr class="new form-group" data-edited="true" {% if record.errorData %}data-error-data="{{ record.errorData | e}}"{% endif %}>
			<td class="name" data-edited-value="{{record.name | e}}"></td>
			<td class="type" data-edited-value="{{record.type | e}}"></td>
			<td class="priority" data-edited-value="{{record.priority | e}}"></td>
			<td class="content" data-edited-value="{{record.content | e}}"></td>
			<td class="ttl" data-edited-value="{{record.ttl | e}}"></td>
			<td class="actions">
				<button class="btn btn-sm btn-success" data-action="edit" role="button">Edit</button>
				<button class="btn btn-sm btn-danger" data-action="deletenew" role="button">Delete</button>
			</td>
		</tr>
		{% endfor %}

	</tbody>
</table>

<div class="row">
	<div class="col">
		<button class="btn btn-primary btn-block" data-action="add" role="button">Add Record</button>
		<br><br>
		<button class="btn btn-warning btn-block" data-action="reset" role="button">Reset Changes</button>
		<button type="submit" class="btn btn-success btn-block" role="button">Save Changes</a>
	</div>
</div>
</form>

<script src="{{ url('/assets/records.js') }}"></script>
