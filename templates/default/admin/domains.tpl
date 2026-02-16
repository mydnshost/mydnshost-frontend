<H1>All Domains</H1>

<input class="form-control" data-search-top="table#domainlist" value="" placeholder="Search..."><br>

<div class="row mb-2">
	<div class="col">
		<div class="float-end">
			<a href="{{ url('/admin/domains/user/0') }}" class="btn btn-primary">Unowned Domains</a>
			<a href="{{ url('/admin/domains/findRecords') }}" class="btn btn-success">Find Records</a>
			{% if hasPermission(['domains_create', 'manage_domains']) %}
				<a href="{{ url('/admin/domains/create') }}" data-action="addAdminDomain" class="btn btn-success">Add Domain</a>
			{% endif %}
		</div>
	</div>
</div>


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
				<span class="badge verificationstate state-{{ domain.verification.state }}" title="Verification state: {{ domain.verification.state }} as of {{ domain.verification.time | date }}">
					{%- if domain.verification.state == 'valid' -%}
						✓
					{%- elseif domain.verification.state == 'invalid' -%}
						X
					{%- else -%}
						?
					{%- endif -%}
				</span>

				{{ name }}
				{% if domain.subtitle %}
					<small class="subtitle">({{ domain.subtitle }})</small>
				{% endif %}
			</td>
			<td class="owner">
				{% set foundowner = false %}
				{% for user,access in domain.users | filter(a => a == "owner") -%}
					{% if foundowner %}<br>{% endif %}

					{% if domain.userinfo[user].avatar == 'gravatar' %}
						<img src="{{ user | gravatar }}" alt="{{ user }}" class="avatar miniavatar" />&nbsp;
					{% elseif domain.userinfo[user].avatar == 'none' %}
						<img src="{{ 'none' | gravatar }}" alt="{{ user }}" class="avatar miniavatar" />&nbsp;
					{% else %}
						<img src="{{ domain.userinfo[user].avatar}}" alt="{{ user }}" class="avatar miniavatar" />&nbsp;
					{% endif %}
					{{ user }}
					{% set foundowner = true %}
				{% else %}
					<span class="text-muted">Unowned</span>
				{% endfor %}
			</td>
			<td class="actions">
				{% if domain_defaultpage == 'records' %}
					<a href="{{ url('/admin/domain/' ~ name ~ '/records') }}" class="btn btn-success btn-sm">Manage</a>
				{% else %}
					<a href="{{ url('/admin/domain/' ~ name) }}" class="btn btn-success btn-sm">Manage</a>
				{% endif %}
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
			<button type="button" data-action="cancel" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
			<button type="button" data-action="ok" class="btn btn-success">Ok</button>
		{% endblock %}
	{% endembed %}
{% endif %}

<script src="{{ url('/assets/admin_domains.js') }}"></script>
