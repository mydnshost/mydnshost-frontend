<h1>Job {{ jobid }} :: Logs</h1>

<div class="mb-3">
	<a href="{{ url('/system/jobs/' ~ jobid) }}" class="btn btn-outline-primary btn-sm">Back to Job</a>
	<a href="{{ url('/system/jobs/' ~ jobid ~ '/logs') }}" class="btn btn-outline-secondary btn-sm">Refresh</a>
</div>

<div class="card">
	{% if logs %}
	<table class="table table-borderless table-sm my-2 font-monospace" style="font-size: 0.8rem;">
		<tbody>
			{% for log in logs %}
			<tr data-searchable-value="{{ log.data }}"{% if log.data starts with '# STDERR:' or log.data starts with 'EXCEPTION' %} class="text-danger"{% endif %}>
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
