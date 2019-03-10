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
			<th>Primary Nameserver</th>
			<td class="mono" data-name="primaryNS" data-soa data-value="{{ domain.SOA.primaryNS }}">{{ domain.SOA.primaryNS }}</td>
		</tr>
		<tr>
			<th>Admin Email Address</th>
			<td class="mono" data-name="adminAddress" data-soa data-value="{{ domain.SOA.adminAddress }}">{{ domain.SOA.adminAddress }}</td>
		</tr>
		<tr>
			<th>Serial Number</th>
			<td class="mono" data-name="serial" data-soa data-value="{{ domain.SOA.serial }}">{{ domain.SOA.serial }}</td>
		</tr>
		<tr>
			<th>Refresh Time</th>
			<td class="mono" data-name="refresh" data-soa data-value="{{ domain.SOA.refresh }}">{{ domain.SOA.refresh }}</td>
		</tr>
		<tr>
			<th>Retry Time</th>
			<td class="mono" data-name="retry" data-soa data-value="{{ domain.SOA.retry }}">{{ domain.SOA.retry }}</td>
		</tr>
		<tr>
			<th>Expire Time</th>
			<td class="mono" data-name="expire" data-soa data-value="{{ domain.SOA.expire }}">{{ domain.SOA.expire }}</td>
		</tr>
		<tr>
			<th>Negative TTL</th>
			<td class="mono" data-name="minttl" data-soa data-value="{{ domain.SOA.minttl }}">{{ domain.SOA.minttl }}</td>
		</tr>
		<tr>
			<th>Default TTL for new records</th>
			<td class="mono" data-name="defaultttl" data-value="{{ domain.defaultttl }}">{{ domain.defaultttl }}</td>
		</tr>
		<tr>
			<th>Disabled</th>
			<td class="state" data-radio="disabled" data-value="{{ domain.disabled | yesno }}">
			{% if domain.disabled == 'true' %}
				<span class="badge badge-danger">
					Yes
				</span>
			{% else %}
				<span class="badge badge-success">
					No
				</span>
			{% endif %}
			</td>
		</tr>
		<tr>
			<th>Access level</th>
			<td class="mono" data-myaccess="{{ domain_access_level }}">{{ domain_access_level | capitalize }}</td>
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
	</tbody>
</table>
</form>

<div class="row" id="domaincontrols">
	<div class="col">
		<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/records") }}" class="btn btn-primary" role="button">View/Edit Records</a>

		{% if has_domain_write %}
			<button type="button" data-action="editsoa" class="btn btn-primary" role="button">Edit Domain Info</button>
			<button type="button" data-action="savesoa" class="btn btn-success hidden" role="button">Save</button>
		{% endif %}

		<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/export") }}" class="btn btn-primary" role="button">Export Zone</a>

		{% if hasPermission(['domains_stats']) %}
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/stats") }}" class="btn btn-primary" role="button">Stats</a>
		{% endif %}
		{% if hasPermission(['domains_logs']) %}
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/logs") }}" class="btn btn-primary" role="button">Logs</a>
		{% endif %}

		<div class="float-right">
			{% if has_domain_write %}
				<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/sync") }}" class="btn btn-info" role="button">Resync Zone</a>
				<a href="{{ url("#{pathprepend}/domain/#{domain.domain}/import") }}" class="btn btn-danger" role="button">Import Zone</a>
			{% endif %}
			{% if has_domain_owner %}
				<button type="button" class="btn btn-danger" role="button" data-toggle="modal" data-target="#deleteModal" data-backdrop="static">Delete Domain</button>
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
					<button type="button" class="btn btn-primary" data-dismiss="modal">Cancel</button>
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
		<tr {% if editedaccess[email] %} data-edited="true"{% endif %}>
			<td class="who" data-value="{{ email }}">
				<img src="{{ email | gravatar }}" alt="{{ email }}" class="minigravatar" />&nbsp;
				{{ email }}
			</td>
			<td class="access" data-value="{{ access }}" {% if editedaccess[email] %} data-edited-value="{{ editedaccess[email].level }}" {% endif %}>
				{{ access }}
			</td>
			{% if has_domain_admin %}
				<td class="actions">
					{% if canChangeAccess(email) %}
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

<H2>Domain Keys</H2>

<table id="apikeys" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
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
				</span>
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}">
				{{ keydata.description }}
			</td>
			<td class="domains_write" data-radio data-name="domains_write" data-value="{{ keydata.domains_write | yesno }}">
				{% if keydata.domains_write == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
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
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">
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

<br><br>

<H2>Domain Web Hooks</H2>

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
					<span class="badge badge-danger">Yes</span>
				{% else %}
					<span class="badge badge-success">No</span>
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
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="hookurl" value="" placeholder="Hook URL...">
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="hookpassword" value="" placeholder="Hook Password">
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

<script src="{{ url('/assets/domains.js') }}"></script>
