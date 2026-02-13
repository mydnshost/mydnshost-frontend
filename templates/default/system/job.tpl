<h1>Job {{ jobid }}</h1>

<div class="mb-3">
	<a href="{{ url('/system/jobs') }}" class="btn btn-outline-primary btn-sm">Back to Jobs</a>
	<a href="{{ url('/system/jobs/' ~ jobid) }}" class="btn btn-outline-secondary btn-sm">Refresh</a>
	<a href="{{ url('/system/jobs/' ~ jobid ~ '/repeat') }}" class="btn btn-outline-warning btn-sm">Repeat</a>
</div>

<div class="row">
	<div class="col-md-6">
		<div class="card mb-3">
			<div class="card-header">Details</div>
			<table class="table table-hover mb-0">
				<tbody>
					<tr>
						<th style="width: 30%">Job ID</th>
						<td>{{ job.id }}</td>
					</tr>
					<tr>
						<th>Name</th>
						<td><code>{{ job.name }}</code></td>
					</tr>
					<tr>
						<th>State</th>
						<td>
							{% if job.state == 'finished' %}
								<span class="badge bg-success">Finished</span>
							{% elseif job.state == 'error' %}
								<span class="badge bg-danger">Error</span>
							{% elseif job.state == 'started' %}
								<span class="badge bg-info text-dark">Started</span>
							{% elseif job.state == 'blocked' %}
								<span class="badge bg-warning text-dark">Blocked</span>
							{% elseif job.state == 'created' %}
								<span class="badge bg-secondary">Created</span>
							{% else %}
								<span class="badge bg-secondary">{{ job.state }}</span>
							{% endif %}
						</td>
					</tr>
					<tr>
						<th>Result</th>
						<td>{{ job.result|default('-') }}</td>
					</tr>
					{% if job.dependsOn %}
					<tr>
						<th>Depends On</th>
						<td>
							{% for dep in job.dependsOn %}
								<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
							{% endfor %}
						</td>
					</tr>
					{% endif %}
					{% if job.dependants %}
					<tr>
						<th>Dependants</th>
						<td>
							{% for dep in job.dependants %}
								<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
							{% endfor %}
						</td>
					</tr>
					{% endif %}
				</tbody>
			</table>
		</div>
	</div>

	<div class="col-md-6">
		<div class="card mb-3">
			<div class="card-header">Timing</div>
			<table class="table table-hover mb-0">
				<tbody>
					<tr>
						<th style="width: 30%">Created</th>
						<td>{{ job.created | date }}</td>
					</tr>
					<tr>
						<th>Started</th>
						<td>{% if job.started > 0 %}{{ job.started | date }}{% else %}<span class="text-muted">Not started</span>{% endif %}</td>
					</tr>
					<tr>
						<th>Finished</th>
						<td>{% if job.finished > 0 %}{{ job.finished | date }}{% else %}<span class="text-muted">Not finished</span>{% endif %}</td>
					</tr>
					{% if job.finished > 0 and job.started > 0 %}
					<tr>
						<th>Duration</th>
						<td>{{ (job.finished - job.started) }}s</td>
					</tr>
					{% endif %}
				</tbody>
			</table>
		</div>
	</div>
</div>

<div class="card mb-3">
	<div class="card-header">Payload</div>
	<div class="card-body p-0">
		<pre class="mb-0 p-3"><code>{{ job.data_formatted|default(job.data) }}</code></pre>
	</div>
</div>

<div class="card mb-3">
	<div class="card-header">Logs</div>
	{% if job.logs is defined and job.logs %}
	<table class="table table-borderless table-sm my-2 font-monospace" style="font-size: 0.8rem;">
		<tbody>
			{% for log in job.logs %}
			<tr{% if log.data starts with '# STDERR:' or log.data starts with 'EXCEPTION' %} class="text-danger"{% endif %}>
				<td class="text-nowrap py-0 ps-3 pe-2{% if not (log.data starts with '# STDERR:' or log.data starts with 'EXCEPTION') %} text-muted{% endif %}" style="width: 250px">{{ log.time | date }}</td>
				<td class="py-0">{{ log.data }}</td>
			</tr>
			{% endfor %}
		</tbody>
	</table>
	{% else %}
	<div class="card-body text-muted">
		No logs available. Either the job didn't produce any output, or the JobLogger service is not running.
	</div>
	{% endif %}
</div>
