<h1>Domain :: {{ domain.domain }} :: Logs</h1>

<div class="mb-3">
	<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-outline-primary btn-sm">Back</a>
	<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/logs") }}" class="btn btn-outline-secondary btn-sm">Refresh</a>
</div>

<input class="form-control form-control-sm mb-3" data-search-top="table#domainlogs" value="" placeholder="Search logs...">

<div class="card">
	{% if logs %}
	<table id="domainlogs" class="table table-borderless table-sm my-2 font-monospace" style="font-size: 0.8rem;">
		<tbody>
			{% for log in logs %}
			<tr data-searchable-value="{{ log['message'] }}">
				<td class="text-nowrap text-muted py-0 ps-3 pe-2" style="width: 1%; white-space: nowrap">{{ log['timestamp'] }}</td>
				<td class="py-0" style="width: 100%">{{ log['message'] }}</td>
			</tr>
			{% endfor %}
		</tbody>
	</table>
	{% else %}
	<div class="card-body text-muted">
		No logs to show.
	</div>
	{% endif %}
</div>

