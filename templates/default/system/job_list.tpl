<H1>Jobs</H1>

<table id="joblist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">Job ID</th>
			<th class="name">Details</th>
			<th class="times">Times</th>
			<th class="state">State</th>
			<th class="result">Result</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for job in jobs %}
		<tr data-searchable-value="{{ job.name }} {{ job.id }}" class="state-{{ job.state }}">
			<td class="id">{{ job.id }}</td>
			<td class="name">
				<strong>Name:</strong> {{ job.name }} <br>
				<strong>Payload:</strong> <span class="mono breakable">{{ job.data }}</span> <br>
				{% if job.dependsOn %}
					<strong>Depends On:</strong> {{ job.dependsOn | join(', ') }} <br>
				{% endif %}
				{% if job.dependants %}
					<strong>Dependants:</strong> {{ job.dependants | join(', ') }} <br>
				{% endif %}
			</td>
			<td class="times">
				<strong>Created:</strong> {{ job.created | date }} <br>
				<strong>Started:</strong> {% if job.started > 0 %}{{ job.started | date }}{% else %}Not started.{% endif %} <br>
				<strong>Finished:</strong> {% if job.finished > 0 %}{{ job.finished | date }}{% else %}Not finished.{% endif %} <br>
			</td>
			<td class="state">{{ job.state }}</td>
			<td class="result">{{ job.result }}</td>
			<td class="actions">
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/logs') }}" class="btn btn-success btn-sm">Logs</a>
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/repeat') }}" class="btn btn-warning btn-sm">Repeat</a>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<!-- <script src="{{ url('/assets/jobs/list.js') }}"></script> -->
