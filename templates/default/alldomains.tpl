<H1>All Domains</H1>

<div class="float-end">
	<a href="{{ url('/domains/findRecords') }}" class="btn btn-success">Find Records</a>
	{% if hasPermission(['domains_create', 'manage_domains']) %}
		<a href="{{ url('/admin/domains/create') }}" data-action="addAdminDomain" class="btn btn-success">Add Domain</a>
	{% endif %}
</div>
<br><br>

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
				<span class="badge verificationstate state-{{ domain.verification.state }}" title="Verification state: {{ domain.verification.state }} as of {{ domain.verification.time | date }}">
					{%- if domain.verification.state == 'valid' -%}
						✓
					{%- elseif domain.verification.state == 'invalid' -%}
						X
					{%- else -%}
						?
					{%- endif -%}
				</span>

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
