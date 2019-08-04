<H1>Service :: {{ service }} :: Logs</H1>

<a href="{{ url('/system/services/' ~ service ) }}" class="btn btn-primary">Back</a>
<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-success">Refresh</a>
<br><br>

<table id="servicelogs" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="timestamp">Time</th>
			<th class="log">Log</th>
		</tr>
	</thead>
	<tbody>
		{% for log in logs %}
			<tr data-searchable-value="{{ log[2] }}" class="logtype_{{ log[0] }}">
				<td class="timestamp">{{ log[1] }}</td>
				<td class="log mono">{{ log[2] }}</td>
			</tr>
		{% else %}
			<tr class="logtype_line">
				<td colspan="2">There are no logs to show.</td>
			</tr>
		{% endfor %}
	</tbody>
</table>

