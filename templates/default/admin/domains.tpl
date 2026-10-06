<H1>All Domains</H1>

<input class="form-control" data-search-top="table#domainlist" value="" placeholder="Search..."><br>

<div class="row mb-2">
	<div class="col">
		<div class="float-end">
			<a href="{{ url('/admin/domains/user/0') }}" class="btn btn-primary">Unowned Domains</a>
			<a href="{{ url('/admin/domains/findRecords') }}" data-action="findRecords" class="btn btn-success">Find Records</a>
			{% if hasPermission(['domains_create', 'manage_domains']) %}
				<a href="{{ url('/admin/domains/create') }}" data-action="addUserDomain" data-show-owner="true" class="btn btn-success" data-needs-elevation>Add Domain</a>
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
				{% include 'blocks/domain_dnssec_badge.tpl' %}

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
