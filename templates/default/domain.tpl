<H1>Domain :: {{ domain.domain }}</H1>

<table id="soainfo" class="table table-striped table-bordered">
	<tbody>
		<tr>
			<th>Primary Nameserver</th>
			<td>{{ domain.SOA.primaryNS }}</td>
		</tr>
		<tr>
			<th>Admin Email Address</th>
			<td>{{ domain.SOA.adminAddress }}</td>
		</tr>
		<tr>
			<th>Serial Number</th>
			<td>{{ domain.SOA.serial }}</td>
		</tr>
		<tr>
			<th>Refresh Time</th>
			<td>{{ domain.SOA.refresh }}</td>
		</tr>
		<tr>
			<th>Retry Time</th>
			<td>{{ domain.SOA.retry }}</td>
		</tr>
		<tr>
			<th>Expire Time</th>
			<td>{{ domain.SOA.expire }}</td>
		</tr>
		<tr>
			<th>Negative TTL</th>
			<td>{{ domain.SOA.minttl }}</td>
		</tr>
		<tr>
			<th>Disabled</th>
			<td class="disabled">
			{% if domain.disabled == 'true' %}
				Yes
			{% else %}
				No
			{% endif %}
			</td>
		</tr>
		<tr>
			<th>Access level</th>
			<td>{{ domain.access | capitalize }}</td>
		</tr>
	</tbody>
</table>

<div class="row">
	<div class="col">
		<a href="{{ url("/domain/#{domain.domain}/records") }}" class="btn btn-primary" role="button">View/Edit Records</a>
		{% if domain.access == 'owner' or domain.access == 'admin' or domain.access == 'write' %}
			<a href="{{ url("/domain/#{domain.domain}/edit") }}" class="btn btn-primary" role="button">Edit Domain Info</a>
		{% endif %}

		{% if domain.access == 'owner' %}
			<div class="float-right">
				<a href="{{ url("/domain/#{domain.domain}/delete") }}" class="btn btn-danger" role="button">Delete Domain</a>
			</div>
		{% endif %}
	</div>
</div>

<br><br>

<H2>Domain Access</H2>

<table id="accessinfo" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th>Who</th>
			<th>Access Level</th>
			{% if domain.access == 'owner' or domain.access == 'admin' %}
				<th>Actions</th>
			{% endif %}
		</tr>
	</thead>
	<tbody>
		{% for email,access in domainaccess %}
		<tr>
			<td>
				<img src="{{ email | gravatar }}" alt="{{ email }}" class="minigravatar" />&nbsp;
            	{{ email }}
			</td>
			<td>
				{{ access }}
			</td>
			{% if domain.access == 'owner' or domain.access == 'admin' %}
				<td>
					<a href="{{ url("/domain/#{domain.domain}/access/remove/#{email}") }}" class="btn btn-sm btn-danger" role="button">Remove</a>
				</td>
			{% endif %}
		</tr>
		{% endfor %}
	</tbody>
</table>

{% if domain.access == 'owner' or domain.access == 'admin' %}
	<a href="{{ url("/domain/#{domain.domain}/access/add") }}" class="btn btn-primary" role="button">Grant Access</a>
{% endif %}
