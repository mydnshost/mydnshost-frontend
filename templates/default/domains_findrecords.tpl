<H1>Find Domain by Records</H1>

<form id="findRecords" method="post" action="{{ url("#{pathprepend}/domains/findRecords") }}">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<div class="form-group row">
		<label for="recordContent" class="col-3 col-form-label">Record Content</label>
		<div class="col-9">
			<input class="form-control" type="text" value="{{ recordContent }}" id="recordContent" name="recordContent">
		</div>
	</div>

	<div class="d-grid mt-2 gap-2">
		<a href="{{ url("#{pathprepend}/domains") }}" class="btn btn-warning" data-bs-dismiss="modal">Cancel</a>
		<button type="submit" data-action="ok" class="btn btn-success">Find Domains</button>
	</div>
</form>
<br><br>
{% for domain in domains %}
	<h2>
		{{ domain.domain }}
		{% if domain.subtitle %}
			<small class="subtitle">({{ domain.subtitle }})</small>
		{% endif %}
		<a href="{{ url(pathprepend ~ '/domain/' ~ domain.domain) }}" class="btn btn-sm btn-primary">View Domain</a>
		<a href="{{ url(pathprepend ~ '/domain/' ~ domain.domain ~ '/records') }}" class="btn btn-sm btn-success">Edit Records</a><br><br>
	</h2>
	<h4>Matching Records</h4>
	<table class="table table-striped table-bordered">
		<thead>
			<tr>
				<th class="name">Name</th>
				<th class="type">Type</th>
				<th class="priority">Priority</th>
				<th class="content">Content</th>
				<th class="ttl">TTL</th>
				<th class="state">Disabled</th>
			</tr>
		</thead>
		<tbody>
			{% for record in domain.records %}
			<tr data-id="{{ record.id }}" class="{% if record.disabled == 'true' or record.edited.disabled == 'true' %}disabled{% endif %}">
				<td class="name mono">
					{% if record.name == '' %}
						@
					{% else %}
						{{ record.name }}
					{% endif %}
				</td>
				<td class="type mono">
					{{ record.type }}
				</td>
				<td class="priority mono">
					{{ record.priority }}
				</td>
				<td class="content mono">
					{{ record.content }}
				</td>
				<td class="ttl mono">
					{{ record.ttl }}
				</td>
				<td class="state">
					{% if record.disabled == 'true' or record.edited.disabled == 'true' %}
						<span class="badge bg-danger">
					{% else %}
						<span class="badge bg-success">
					{% endif %}
						{{ record.disabled | yesno }}
					</span>
				</td>
			</tr>
		{% endfor %}
		</tbody>
	</table>
	<hr>
	<br><br>
{% endfor %}
