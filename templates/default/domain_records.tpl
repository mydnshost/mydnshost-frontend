<H1>
	Domain :: {{ domain.domain }} :: Records
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>
<p>
This is where you can add/edit/remove records for the domain.
</p>
<p>
Please note that all record names will have '<code>.{{ domain.domain }}</code>' appended to them, and all content will be saved as-is without anything appended, so you do not need to add a trailing '<code>.</code>' to content.
</p>
<p>
Domains require at least 1 NS record before they will be successfully served.
</p>

<div class="row">
	<div class="col">
		<div class="float-right">
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary" role="button">Back to zone details</a>
			<br>
			<br>
		</div>
	</div>
</div>

{% if has_domain_write %}
<form method="post" id="recordsform">
{% endif %}
<table id="soainfo" class="table table-striped table-bordered form-group">
	<tbody>
		<tr>
			<th>Serial Number</th>
			<td class="mono">{{ domain.SOA.serial }}</td>
		</tr>
	</tbody>
</table>

<table id="records" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="name">Name</th>
			<th class="type">Type</th>
			<th class="priority">Priority</th>
			<th class="content">Content</th>
			<th class="ttl">TTL</th>
			<th class="state">Disabled</th>
			{% if has_domain_write %}
			<th class="actions">Actions</th>
			{% endif %}
		</tr>
	</thead>
	<tbody>
		{% for record in records %}
		<tr data-id="{{ record.id }}" class="{% if record.disabled == 'true' or record.edited.disabled == 'true' %}disabled{% endif %}"
			{% if record.edited %}data-edited="true"{% endif %}
			{% if record.deleted %}data-deleted="true"{% endif %}
			{% if record.errorData %}data-error-data="{{ record.errorData }}"{% endif %}
			>

			<td class="name mono" data-value="{{ record.name }}" {% if record.edited %}data-edited-value="{{ record.edited.name }}"{% endif %}>
				{{ record.name }}
			</td>
			<td class="type mono" data-value="{{ record.type }}" {% if record.edited %}data-edited-value="{{ record.edited.type }}"{% endif %}>
				{{ record.type }}
			</td>
			<td class="priority mono" data-value="{{ record.priority }}" {% if record.edited %}data-edited-value="{{ record.edited.priority }}"{% endif %}>
				{{ record.priority }}
			</td>
			<td class="content mono" data-value="{{ record.content }}" {% if record.edited %}data-edited-value="{{ record.edited.content }}"{% endif %}>
				{{ record.content }}
			</td>
			<td class="ttl mono" data-value="{{ record.ttl }}" {% if record.edited %}data-edited-value="{{ record.edited.ttl }}"{% endif %}>
				{{ record.ttl }}
			</td>
			<td class="state" data-value="{{ record.disabled | yesno }}" {% if record.edited %}data-edited-value="{{ record.edited.disabled | yesno }}"{% endif %}>
				{% if record.disabled == 'true' or record.edited.disabled == 'true' %}
					<span class="badge badge-danger">
				{% else %}
					<span class="badge badge-success">
				{% endif %}
					{{ record.disabled | yesno }}
				</span>
			</td>
			{% if has_domain_write %}
				<td class="actions">
					<button type="button" class="btn btn-sm btn-success" data-action="edit" role="button">Edit</button>
					<button type="button" class="btn btn-sm btn-danger" data-action="delete" role="button">Delete</button>
				</td>
			{% endif %}
		</tr>
		{% endfor %}


		{% if has_domain_write %}
			{% for id,record in newRecords %}
			<tr class="new form-group" data-edited="true" {% if record.errorData %}data-error-data="{{ record.errorData }}"{% endif %}>
				<td class="name" data-edited-value="{{record.name }}"></td>
				<td class="type" data-edited-value="{{record.type }}"></td>
				<td class="priority" data-edited-value="{{record.priority }}"></td>
				<td class="content" data-edited-value="{{record.content }}"></td>
				<td class="ttl" data-edited-value="{{record.ttl }}"></td>
				<td class="ttl" data-edited-value="No"></td>
				<td class="actions">
					<button type="button" class="btn btn-sm btn-success" data-action="edit" role="button">Edit</button>
					<button type="button" class="btn btn-sm btn-warning" data-action="deletenew" role="button">Cancel</button>
				</td>
			</tr>
			{% endfor %}
		{% endif %}

	</tbody>
</table>

{% if has_domain_write %}
<div class="row">
	<div class="col">
		<button type="button" class="btn btn-primary btn-block" data-action="add" role="button">Add Record</button>
		<br><br>
		<button type="button" class="btn btn-warning btn-block" data-action="reset" role="button">Reset Changes</button>
		<button type="submit" class="btn btn-success btn-block" role="button">Save Changes</a>
	</div>
</div>
</form>

<script src="{{ url('/assets/records.js') }}"></script>
{% endif %}
