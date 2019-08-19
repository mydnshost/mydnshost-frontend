<H1>Services</H1>

<table id="servicelist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="service">Service</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for service in services %}
		<tr data-searchable-value="{{ service }}">
			<td class="service">
				{{ service }}
			</td>
			<td class="actions">
				<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-success btn-sm">Logs</a>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<!-- <script src="{{ url('/assets/services/list.js') }}"></script> -->
