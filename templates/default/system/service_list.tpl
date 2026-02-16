<h1>Services</h1>

<table id="servicelist" class="table table-striped table-hover">
	<thead>
		<tr>
			<th>Service</th>
			<th>Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for service in services %}
		<tr data-searchable-value="{{ service }}">
			<td><code>{{ service }}</code></td>
			<td>
				<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-outline-primary btn-sm">Logs</a>
			</td>
		</tr>
		{% else %}
		<tr>
			<td colspan="2" class="text-center text-muted py-4">No services found.</td>
		</tr>
		{% endfor %}
	</tbody>
</table>
