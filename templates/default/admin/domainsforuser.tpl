<H1>All Domains for {{ admindomainuser.email }} </H1>

<input class="form-control" data-search-top="table#domainlist" value="" placeholder="Search..."><br>

<br><br>

<table id="domainlist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="domain">Domain</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
    {% for accesslevel,domains in adminuserdomains %}
	<tbody>
        <tr>
            <th colspan="2">Access: {{ accesslevel | capitalize }}</th>
        </tr>
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
    {% endfor %}
</table>

<script src="{{ url('/assets/admin_domains.js') }}"></script>
