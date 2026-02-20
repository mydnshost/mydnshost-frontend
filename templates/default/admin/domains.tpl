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
				{% if domain.dnssec.state is defined and domain.dnssec.state in ['signed', 'signed_extra_keys'] %}
					<span class="badge dnssecstate state-signed" title="DNSSEC: {{ domain.dnssec.state }}"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2m3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2"/></svg></span>
				{% elseif domain.dnssec.state is defined and domain.dnssec.state == 'broken_signature' %}
					<span class="badge dnssecstate state-broken" title="DNSSEC: broken signature"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M11 1a2 2 0 0 0-2 2v4a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2h5V3a3 3 0 0 1 6 0v4a.5.5 0 0 1-1 0V3a2 2 0 0 0-2-2"/></svg></span>
				{% else %}
					<span class="badge dnssecstate state-none" title="DNSSEC: {{ domain.dnssec.state is defined ? domain.dnssec.state : 'unknown' }}"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2m3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2"/></svg></span>
				{% endif %}

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
