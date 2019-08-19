<H1>Service :: {{ service }} :: Logs</H1>

<a href="{{ url('/system/services/') }}" class="btn btn-primary">Back</a>
<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-success">Refresh</a>
<br><br>

<table id="servicelogs" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="timestamp">Time</th>
			<th class="stream">Stream</th>
			<th class="log">Log</th>
		</tr>
	</thead>
	<tbody>
		{% for log in logs %}
			<tr data-searchable-value="{{ log['message'] }}" class="logtype_{{ log['stream'] }}">
				<td class="timestamp">{{ log['timestamp'] }}</td>
				<td class="stream">{{ log['docker']['name'] }} :: {{ log['stream'] }}</td>
				<td class="log mono">{{ log['message'] }}</td>
			</tr>
		{% else %}
			<tr class="logtype_line">
				<td colspan="4">There are no logs to show.</td>
			</tr>
		{% endfor %}
	</tbody>
</table>

