<H1>All Domains</H1>

<input class="form-control" data-search-top="table#domainlist" value="" placeholder="Search..."><br>

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
		<tr data-searchable-value="{{ name }}">
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

{% if hasPermission(['domains_create']) %}
<br><br>

<h1>Add Domain</h1>

<form id="adddomain" method="post" action="{{ url('/admin/domains/create') }}">
	<div class="form-group row">
		<label for="domainname" class="col-2 col-form-label">Domain Name</label>
		<div class="col-10">
			<input class="form-control" type="text" value="" id="domainname" name="domainname">
		</div>
	</div>
	{% if hasPermission(['manage_domains']) %}
		<div class="form-group row">
			<label for="owner" class="col-2 col-form-label">Owner</label>
			<div class="col-10">
				<input class="form-control" type="text" value="" id="owner" name="owner">
			</div>
		</div>
	{% endif %}
	<div class="form-group row">
		<div class="col-10 offset-2">
			<button type="submit" class="btn btn-primary btn-block">Add Domain</button>
		</div>
	</div>
</form>
{% endif %}

<script src="{{ url('/assets/admin_domains.js') }}"></script>
