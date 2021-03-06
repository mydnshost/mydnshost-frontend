<H1>All Domains</H1>

<table id="domainlist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="domain">Domain</th>
			<th class="access">Access Level</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for domain in domains %}
		<tr>
			<td class="domain">
				{{ domain.domain }}
				{% if domain.subtitle %}
					<small class="subtitle">({{ domain.subtitle }})</small>
				{% endif %}
			</td>
			<td class="access">
				{{ domain.access }}
			</td>
			<td class="actions">
				{% if domain_defaultpage == 'records' %}
					<a href="{{ url('/domain/' ~ domain.domain ~ '/records') }}" class="btn btn-success">View</a>
				{% else %}
					<a href="{{ url('/domain/' ~ domain.domain) }}" class="btn btn-success">View</a>
				{% endif %}
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>
