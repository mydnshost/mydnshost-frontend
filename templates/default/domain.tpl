<H1>
	Domain :: {{ domain.domain }}
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

<form method="post" id="editsoaform">
<input type="hidden" name="csrftoken" value="{{csrftoken}}">
<input type="hidden" name="changetype" value="soa">
<table id="soainfo" class="table table-striped table-bordered">
	<tbody>
		<tr>
			<th>User-Specific Label</th>
			<td class="mono" data-name="custom_label" data-editable data-value="{{ domain.userdata["uk.co.mydnshost.www/domain/label"] }}">{{ domain.userdata["uk.co.mydnshost.www/domain/label"] }}</td>
		</tr>
		<tr>
			<th>User-Specific Notes</th>
			<td class="mono pre" data-name="custom_notes" data-editable data-type="textarea" data-rich data-value="{{ domain.userdata["uk.co.mydnshost.www/domain/notes"] }}">{{ domain.userdata["uk.co.mydnshost.www/domain/notes"] }}</td>
		</tr>
		{% if domain.SOA %}
			<tr>
				<th>Primary Nameserver</th>
				<td class="mono" data-name="primaryNS" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.primaryNS }}">{{ domain.SOA.primaryNS }}</td>
			</tr>
			<tr>
				<th>Admin Email Address</th>
				<td class="mono" data-name="adminAddress" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.adminAddress }}">{{ domain.SOA.adminAddress }}</td>
			</tr>
			<tr>
				<th>Serial Number</th>
				<td class="mono" data-name="serial" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.serial }}">{{ domain.SOA.serial }}</td>
			</tr>
			<tr>
				<th>Refresh Time</th>
				<td class="mono" data-name="refresh" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.refresh }}">{{ domain.SOA.refresh }}</td>
			</tr>
			<tr>
				<th>Retry Time</th>
				<td class="mono" data-name="retry" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.retry }}">{{ domain.SOA.retry }}</td>
			</tr>
			<tr>
				<th>Expire Time</th>
				<td class="mono" data-name="expire" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.expire }}">{{ domain.SOA.expire }}</td>
			</tr>
			<tr>
				<th>Negative TTL</th>
				<td class="mono" data-name="minttl" {% if has_domain_write %}data-editable{% endif %} data-soa data-value="{{ domain.SOA.minttl }}">{{ domain.SOA.minttl }}</td>
			</tr>
		{% endif %}
		{% if not domain.aliasof %}
			<tr>
				<th>Default TTL for new records</th>
				<td class="mono" data-name="defaultttl" {% if has_domain_write %}data-editable{% endif %} data-value="{{ domain.defaultttl }}">{{ domain.defaultttl }}</td>
			</tr>
		{% endif %}
		<tr>
			<th>Disabled</th>
			<td class="state" data-radio="disabled" {% if has_domain_write %}data-editable{% endif %} data-value="{{ domain.disabled | yesno }}">
			{% if domain.disabled == 'true' %}
				<span class="badge bg-danger">
					Yes
				</span>
			{% else %}
				<span class="badge bg-success">
					No
				</span>
			{% endif %}
			</td>
		</tr>
		{% if has_domain_owner or domain.aliasof %}
			<tr>
				<th>Alias of</th>
				<td class="mono" data-rich data-type="option" data-include-current data-name="aliasof" {% if has_domain_write %}data-editable{% endif %} data-value="{{ domain.aliasof }}">
					{% if domain.aliasof %}
						<a href="{{ url("#{pathprepend}/domain/#{domain.aliasof}") }}">{{ domain.aliasof }}</a>
						{% if domain.superalias %}
							(=> <a href="{{ url("#{pathprepend}/domain/#{domain.superalias}") }}">{{ domain.superalias }}</a>)
						{% endif %}
					{% else %}
						None
					{% endif %}
				</td>
			</tr>
		{% endif %}
		{% if domain.aliases.direct %}
			<tr>
				<th>Direct Aliases</th>
				<td class="mono">
					{% for aliasname in domain.aliases.direct %}
						<a href="{{ url("#{pathprepend}/domain/#{aliasname}") }}">{{ aliasname }}</a><br>
					{% endfor %}
				</td>
			</tr>
		{% endif %}
		{% if domain.aliases.indirect %}
			<tr>
				<th>Indirect Aliases</th>
				<td class="mono">
					{% for aliasname in domain.aliases.indirect %}
						<a href="{{ url("#{pathprepend}/domain/#{aliasname}") }}">{{ aliasname }}</a><br>
					{% endfor %}
				</td>
			</tr>
		{% endif %}
		<tr>
			<th>Access level</th>
			<td id="myaccess" class="mono" data-myaccess="{{ domain_access_level }}">{{ domain_access_level | capitalize }}</td>
		</tr>
		<tr>
			<th>DNSSEC Keys</th>
			{% if domain.DNSSEC.DS %}
				<td>
					<span class="mono">{{ domain.DNSSEC.DS | join("\n") | nl2br }}</span>

					<br><br>
					<button type="button" data-action="dnssec-more" class="btn btn-primary btn-sm" role="button">More..</button>
					<div id="dnssec-more" class="hidden">
						{# {% for rrtype,rrdata in domain.DNSSEC %}
							{% if rrtype != 'DS' and rrtype != 'parsed' %}
								<br><br>
								<span class="mono">{{ rrdata | join("\n") | nl2br }}</span>
							{% endif %}
						{% endfor %} #}

						{% for keyid,keydata in domain.DNSSEC.parsed %}
							<br><br>
							<h4>Key ID: {{ keyid }}</h4>
							<table>
								{% for dstype,dsdata in keydata %}
									{% if dstype != "Key ID" %}
										<tr>
											<th>{{ dstype }}</th>
											<td class="mono">{{ dsdata | nl2br }}</td>
										</tr>
									{% endif %}
								{% endfor %}
							</table>
						{% endfor %}
					</div>
				</td>
			{% else %}
				<td>
					<em>Keys have not yet been generated. Keys will be generated when the zone is next reloaded.</em>
				</td>
			{% endif %}
		</tr>
		<tr>
			<th>Verification State</th>
			<td>
				<span class="badge verificationstate state-{{ domain.verificationstate }}" title="Verification state: {{ domain.verificationstate }} as of {{ domain.verificationstatetime | date }}">
					{%- if domain.verificationstate == 'valid' -%}
						✓
					{%- elseif domain.verificationstate == 'invalid' -%}
						X
					{%- else -%}
						?
					{%- endif -%}
				</span>
				{{ domain.verificationstate }} as of {{ domain.verificationstatetime | date }}

				{% if hasPermission(['domains_verify']) %}
					<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/verify") }}" class="btn btn-info btn-sm" role="button">Update</a>
				{% endif %}
			</td>
		</tr>
	</tbody>
</table>
</form>

<div class="row" id="domaincontrols">
	<div class="col">
		{% if not domain.aliasof %}
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/records") }}" class="btn btn-primary" role="button">View/Edit Records</a>
		{% endif %}

		<button type="button" data-action="editsoa" class="btn btn-primary" role="button">Edit Domain Info</button>
		<button type="button" data-action="savesoa" class="btn btn-success hidden" role="button">Save</button>

		<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/export") }}" class="btn btn-primary" role="button">Export Zone</a>

		{% if hasPermission(['domains_stats']) %}
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/stats") }}" class="btn btn-primary" role="button">Stats</a>
		{% endif %}
		{% if hasPermission(['domains_logs']) %}
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/logs") }}" class="btn btn-primary" role="button">Logs</a>
		{% endif %}
		{% if hasPermission(['system_job_mgmt']) %}
			<a href="{{ url("#{pathprepend}/system/jobs?filter[data][domain]=#{domain.domain}") }}" class="btn btn-primary" role="button">Jobs</a>
		{% endif %}
		<div class="float-end">
			{% if has_domain_write %}
				<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/sync") }}" class="btn btn-info" role="button">Resync Zone</a>
				{% if not domain.aliasof %}
					<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/import") }}" class="btn btn-danger" role="button">Import Zone</a>
				{% endif %}
			{% endif %}
			{% if has_domain_owner %}
				<button type="button" class="btn btn-danger" role="button" data-bs-toggle="modal" data-bs-target="#deleteModal" data-backdrop="static">Delete Domain</button>
			{% endif %}
		</div>


		{% if has_domain_owner %}
			{% embed 'blocks/modal_confirm.tpl' with {'id': 'deleteModal'} %}
				{% block title %}
					Delete Domain
				{% endblock %}

				{% block body %}
					Are you sure you want to delete this domain?
					<br><br>
					This will delete all records and data associated with this domain and can not be undone.
				{% endblock %}

				{% block buttons %}
					<button type="button" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
					<form id="deletedomainform" method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/delete") }}">
						<input type="hidden" name="csrftoken" value="{{csrftoken}}">
						<input type="hidden" name="confirm" value="true">
						<button type="submit" class="btn btn-danger">Delete domain</button>
					</form>
				{% endblock %}
			{% endembed %}
		{% endif %}
	</div>
</div>

<br><br>

<H2>Domain Access</H2>

<p>Control which users have access to view/edit this domain.</p>

<form method="post" id="editaccess">
<input type="hidden" name="csrftoken" value="{{csrftoken}}">
<input type="hidden" name="changetype" value="access">
<table id="accessinfo" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th>Who</th>
			<th>Access Level</th>
			{% if has_domain_admin %}
				<th>Actions</th>
			{% endif %}
		</tr>
	</thead>
	<tbody>
		{% for email,access in domainaccess %}
		<tr {% if editedaccess[email] %} data-edited="true"{% endif %} {% if email == user.email %} data-self {% endif %}>
			<td class="who" data-value="{{ email }}">
				{% if userinfo[email].avatar == 'gravatar' %}
					<img src="{{ email | gravatar }}" alt="{{ email }}" class="avatar miniavatar" />&nbsp;
				{% elseif userinfo[email].avatar == 'none' %}
					<img src="{{ 'none' | gravatar }}" alt="{{ email }}" class="avatar miniavatar" />&nbsp;
				{% else %}
					<img src="{{ userinfo[email].avatar }}" alt="{{ email }}" class="avatar miniavatar" />&nbsp;
				{% endif %}

				{{ email }}
			</td>
			<td class="access" data-value="{{ access }}" {% if editedaccess[email] %} data-edited-value="{{ editedaccess[email].level }}" {% endif %}>
				{{ access }}
				{% if not has_domain_admin and email == user.email %}
				    {# TODO: Prompt for this? #}
					<button type="submit" name="removeselfaccess" value="true" class="btn btn-sm btn-danger" data-action="removeselfaccess" role="button">Leave Domain</button>
				{% endif %}
			</td>
			{% if has_domain_admin %}
				<td class="actions">
					{% if hasHigherAccess(access) or email == user.email %}
						<button type="button" data-action="editaccess" class="btn btn-sm btn-success" role="button">Edit</button>
					{% endif %}
				</td>
			{% endif %}
		</tr>
		{% endfor %}

		{% for new in newaccess %}
		<tr class="new form-group" data-edited="true">
			<td class="who" data-edited-value="{{ new.who }}"></td>
			<td class="access" data-edited-value="{{ new.level }}"></td>
			<td>
				<button type="button" class="btn btn-sm btn-danger" data-action="editaccess" role="button">Edit</button>
				<button type="button" class="btn btn-sm btn-danger" data-action="deleteaccess" role="button">Cancel</button>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% if has_domain_admin %}
	<button type="button" data-action="addaccess" class="btn btn-success" role="button">Add Access</button>
	<button type="submit" class="btn btn-primary" role="button">Update Access</button>
{% endif %}
</form>

{% if has_domain_write and domainkeys is not null %}
<br><br>

<H2>Domain API Keys</H2>

<p>Domain API Keys are special API Keys used to allow access to only a single-domain rather than a whole account.</p>

<table id="apikeys" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
			<th class="recordregex">Record Regex</th>
			<th class="domains_write">Domain Write</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for key,keydata in domainkeys %}
		<tr data-value="{{ key }}">
			<td class="key">
				<span class="pointer" data-hiddenText="{{ key }}">
					{% if keydata.maskedkey %}
						{{ keydata.maskedkey }}
					{% else %}
						<em>Hidden - click to view</em>
					{% endif %}
				</span><br>
				<small><strong>Last Used:</strong> {% if keydata.lastused == 0 %}Never{% else %}{{ keydata.lastused | date }}{% endif %}</small>
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}">
				{{ keydata.description }}
			</td>
			<td class="recordregex" data-text data-name="recordregex" data-value="{{ keydata.recordregex }}">
				{{ keydata.recordregex }}
			</td>
			<td class="domains_write" data-radio data-name="domains_write" data-value="{{ keydata.domains_write | yesno }}">
				{% if keydata.domains_write == 'true' %}
					<span class="badge bg-success">Yes</span>
				{% else %}
					<span class="badge bg-danger">No</span>
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="editkey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="savekey" class="hidden btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="deletekey" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline editkeyform" method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/editkey/" ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deletekeyform" method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/deletekey/" ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/addkey") }}" class="form-inline form-group" id="addkeyform">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input class="form-control col-3 mb-2 me-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">
	<button type="submit" class="btn btn-success" role="button">Add Domain Key</button>
</form>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDeleteKey'} only %}
	{% block title %}
		Delete Domain Key
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this Domain Key?
		<br><br>
		Deleting this key will cause any applications using it to no longer have access to the api.
		<br><br>
		This can not be undone and any applications will need to be updated to use a new key.
	{% endblock %}
{% endembed %}

{% endif %}

{% if has_domain_write and domainhooks is not null %}
<br><br>

<H2>Domain Web Hooks</H2>

<p>Web Hooks will be called when changes are made to the domain.</p>

<table id="domainhooks" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="url">Url</th>
			<th class="password">Password</th>
			<th class="disabled">Disabled</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for hookid,hookdata in domainhooks %}
		<tr data-value="{{ hookid }}">
			<td class="url" data-text data-name="url" data-value="{{ hookdata.url }}">
				{{ hookdata.url }}
			</td>
			<td class="password" data-text data-name="password" data-value="{{ hookdata.password }}">
				{{ hookdata.password }}
			</td>
			<td class="disabled" data-radio data-name="disabled" data-value="{{ hookdata.disabled | yesno }}">
				{% if hookdata.disabled == 'true' %}
					<span class="badge bg-danger">Yes</span>
				{% else %}
					<span class="badge bg-success">No</span>
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="edithook" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="savehook" class="hidden btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="deletehook" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline edithookform" method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/edithook/" ~ hookid) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deletehookform" method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/deletehook/" ~ hookid) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url("#{pathprepend}/domain/#{domain.domain}/addhook") }}" class="form-inline form-group" id="addhookform">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input class="form-control col-3 mb-2 me-sm-2 mb-sm-0" type="text" name="hookurl" value="" placeholder="Hook URL...">
	<input class="form-control col-3 mb-2 me-sm-2 mb-sm-0" type="text" name="hookpassword" value="" placeholder="Hook Password">
	<button type="submit" class="btn btn-success" role="button">Add Domain Hook</button>
</form>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDeleteHook'} only %}
	{% block title %}
		Delete Domain Hook
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this Domain Hook?
		<br><br>
		Deleting this hook will cause it to no longer be triggered when changes are made to this domain.
		<br><br>
		This can not be undone
	{% endblock %}
{% endembed %}
{% endif %}

<script src="{{ url('/assets/domains.js') }}"></script>
