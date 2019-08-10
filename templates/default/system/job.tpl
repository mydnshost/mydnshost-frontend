<H1>Jobs :: {{ jobid }}</H1>

<a href="{{ url('/system/jobs' ) }}" class="btn btn-primary">Back</a>
<a href="{{ url('/system/jobs/' ~ jobid) }}" class="btn btn-success">Refresh</a>
<br><br>

<table id="jobinfo" class="table table-striped table-bordered">
	<tbody>
		<tr>
			<th class="id">Job ID</th>
			<td class="id">{{ job.id }}</td>
		</tr>
		<tr>
			<th class="name">Details</th>
			<td class="name">
				<strong>Name:</strong> {{ job.name }} <br>
				<strong>Payload:</strong> <span class="mono">{{ job.data }}</span> <br>
				{% if job.dependsOn %}
					<strong>Depends On:</strong> {{ job.dependsOn | join(', ') }} <br>
				{% endif %}
				{% if job.dependants %}
					<strong>Dependants:</strong> {{ job.dependants | join(', ') }} <br>
				{% endif %}
			</td>
		</tr>
		<tr>
			<th class="times">Times</th>
			<td class="times">
				<strong>Created:</strong> {{ job.created | date }} <br>
				<strong>Started:</strong> {% if job.started > 0 %}{{ job.started | date }}{% else %}Not started.{% endif %} <br>
				<strong>Finished:</strong> {% if job.finished > 0 %}{{ job.finished | date }}{% else %}Not finished.{% endif %} <br>
			</td>
		</tr>
		<tr class="state-{{ job.state }}">
			<th class="state">State</th>
			<td class="state">{{ job.state }}</td>
		</tr>
		<tr>
			<th class="result">Result</th>
			<td class="result">{{ job.result }}</td>
		</tr>
		<tr>
			<th class="actions">Actions</th>
			<td class="actions">
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/logs') }}" class="btn btn-success btn-sm">Logs</a>
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/repeat') }}" class="btn btn-warning btn-sm">Repeat</a>
			</td>
		</tr>
	</tbody>
</table>

<br><br>


