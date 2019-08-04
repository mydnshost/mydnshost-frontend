<H1>Job :: {{ jobid }} :: Logs</H1>

<!-- <a href="{{ url('/system/jobs/' ~ jobid ) }}" class="btn btn-primary">Back</a> -->
<a href="{{ url('/system/jobs' ) }}" class="btn btn-primary">Back</a>
<a href="{{ url('/system/jobs/' ~ jobid ~ '/logs') }}" class="btn btn-success">Refresh</a>
<br><br>

<table id="joblogs" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="timestamp">Time</th>
			<th class="log">Log</th>
		</tr>
	</thead>
	<tbody>
		{% for log in logs %}
		<tr data-searchable-value="{{ log.data }}" class="logtype_line">
			<td class="timestamp">{{ log.time | date }}</td>
			<td class="log mono">{{ log.data }}</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

