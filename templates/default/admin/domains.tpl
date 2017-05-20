<H1>All Domains</H1>

<input class="form-control" data-search-top="table#domainlist" value="" placeholder="Search..."><br>

{% if hasPermission(['domains_create', 'manage_domains']) %}
<div class="float-right">
	<a href="{{ url('/admin/domains/create') }}" data-action="addAdminDomain" class="btn btn-success">Add Domain</a>
</div>
<br><br>
{% endif %}

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
				{% if getARPA(name) %}
					<small class="subtitle">(RDNS: {{ getARPA(name) }})</small>
				{% endif %}
			</td>
			<td class="owner">
				{% set foundowner = false %}
				{% for user,access in domain.users if not break %}
					{% if access == "owner" %}
						{% if foundowner %}<br>{% endif %}
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
				<a href="{{ url('/admin/domain/' ~ name) }}" class="btn btn-success btn-sm">Manage</a>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% if hasPermission(['domains_create', 'manage_domains']) %}
	{% embed 'blocks/modal_confirm.tpl' with {'id': 'createAdminDomain', 'large': true, 'csrftoken': csrftoken} only %}
		{% block title %}
			Create Domain
		{% endblock %}

		{% block body %}
			<form id="adddomain" method="post" action="{{ url('/admin/domains/create') }}">
				<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				<div class="form-group row">
					<label for="domainname" class="col-3 col-form-label">Domain Name</label>
					<div class="col-9">
						<input class="form-control" type="text" value="" id="domainname" name="domainname">
					</div>
				</div>
				{% if hasPermission(['manage_domains']) %}
					<div class="form-group row">
						<label for="owner" class="col-3 col-form-label">Owner</label>
						<div class="col-9">
							<input class="form-control" type="text" value="" id="owner" name="owner">
						</div>
					</div>
				{% endif %}
			</form>
		{% endblock %}

		{% block buttons %}
			<button type="button" data-action="cancel" class="btn btn-primary" data-dismiss="modal">Cancel</button>
			<button type="button" data-action="ok" class="btn btn-success">Ok</button>
		{% endblock %}
	{% endembed %}
{% endif %}

<script src="{{ url('/assets/admin_domains.js') }}"></script>
