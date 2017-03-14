<H1>All Domains</H1>

<table id="domainlist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="domain">Domain</th>
			<th class="owner">Owner</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for name,domain in domains %}
		<tr>
			<td class="domain">
				{{ name }}
			</td>
			<td class="owner">
				{% set foundowner = false %}
				{% for user,access in domain.users if not break %}
					{% if access == "owner" %}
						<img src="{{ user | gravatar }}" alt="{{ user }}" class="minigravatar" />&nbsp;
						{{ user }}
						{% set foundowner = true %}
					{% endif %}
				{% endfor %}
				{% if not foundowner %}
					<span class="text-muted">Unowned</span>
				{% endif %}
			</td>
			<td class="actions">
				<a href="{{ url('/admin/domain/' ~ name) }}" class="btn btn-success">Manage</a>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>
