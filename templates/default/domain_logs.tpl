<H1>Domain :: {{ domain }} :: Logs</H1>

<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary btn-block" role="button">Back</a>
<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/logs") }}" class="btn btn-primary btn-block" role="button">Refresh</a>
<br><br>

<table id="servicelogs" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="log">Log</th>
		</tr>
	</thead>
	<tbody>
		{% for log in logs %}
		<tr data-searchable-value="{{ log }}">
			<td class="log">{{ log }}</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

