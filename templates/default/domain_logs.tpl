<H1>Domain :: {{ domain.domain }} :: Logs</H1>

<div class="d-grid mt-2 gap-2">
	<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary" role="button">Back</a>
	<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/logs") }}" class="btn btn-primary" role="button">Refresh</a>
</div>
<br><br>

<table id="servicelogs" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="log">Log</th>
		</tr>
	</thead>
	<tbody>
		{% for log in logs %}
		<tr data-searchable-value="{{ log['message'] }}">
			<td class="log">{{ log['message'] }}</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

