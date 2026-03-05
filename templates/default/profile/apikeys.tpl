<br><br>

<H2>API Keys</H2>
<p>API Keys are used to allow programmatic access to certain account data without needing to provide the account username/password. Different keys can have different levels of access.</p>
<p>API Keys below are masked for safety. You can unmask them by clicking on them, or use the copy button to copy the key to your clipboard.</p>
<table id="apikeys" class="table table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
			<th class="domains_read">Domain Read</th>
			<th class="domains_write">Domain Write</th>
			<th class="user_read">User Read</th>
			<th class="user_write">User Write</th>
			<th class="admin_features">Admin Features</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for key,keydata in apikeys %}
		<tr data-value="{{ key }}" class="{% if loop.index % 2 != 0 %}odd{% endif %}">
			<td class="key" rowspan=2>
				<span class="pointer" data-hiddenText="{{ key }}">
					{% if keydata.maskedkey %}
						{{ keydata.maskedkey }}
					{% else %}
						<em>Hidden - click to view</em>
					{% endif %}
				</span>
				<button type="button" class="btn btn-sm btn-outline-secondary ms-1 copykey" data-key="{{ key }}" title="Copy to clipboard">&#128203;</button>
				<br>
				<small class="{% if keydata.lastused < keyoldcutoff %}text-danger{% elseif keydata.lastused < keycutoff %}text-warning{% endif %}"><strong>Last Used:</strong> {% if keydata.lastused == 0 %}Never{% else %}{{ keydata.lastused | date }}{% endif %}</small>
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}" rowspan=2>
				{{ keydata.description }}
			</td>
			<td class="domains_read" data-radio data-name="domains_read" data-value="{{ keydata.domains_read | yesno }}">
				{% if keydata.domains_read == 'true' %}
					<span class="badge bg-success">Yes</span>
				{% else %}
					<span class="badge bg-danger">No</span>
				{% endif %}
			</td>
			<td class="domains_write" data-radio data-name="domains_write" data-value="{{ keydata.domains_write | yesno }}">
				{% if keydata.domains_write == 'true' %}
					<span class="badge bg-success">Yes</span>
				{% else %}
					<span class="badge bg-danger">No</span>
				{% endif %}
			</td>
			<td class="user_read" data-radio data-name="user_read" data-value="{{ keydata.user_read | yesno }}">
				{% if keydata.user_read == 'true' %}
					<span class="badge bg-success">Yes</span>
				{% else %}
					<span class="badge bg-danger">No</span>
				{% endif %}
			</td>
			<td class="user_write" data-radio data-name="user_write" data-value="{{ keydata.user_write | yesno }}">
				{% if keydata.user_write == 'true' %}
					<span class="badge bg-success">Yes</span>
				{% else %}
					<span class="badge bg-danger">No</span>
				{% endif %}
			</td>
			<td class="admin_features" data-radio data-name="admin_features" data-value="{{ keydata.admin_features | yesno }}">
				{% if keydata.admin_features == 'true' %}
					<span class="badge bg-success">Yes</span>
				{% else %}
					<span class="badge bg-danger">No</span>
				{% endif %}
			</td>
			<td class="actions" rowspan="2">
				<button type="button" data-action="editkey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="savekey" class="d-none btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="deletekey" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline editform" method="post" action="{{ url('/profile/editkey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/deletekey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		<tr data-value="{{ key }}" class="{% if loop.index % 2 != 0 %}odd{% endif %}">
			<th>Record Regex</th>
			<td class="recordregex mono" data-text data-name="recordregex" data-value="{{ keydata.recordregex }}" colspan=4>
				{{ keydata.recordregex }}
			</td>
		<tr>
		{% endfor %}
	</tbody>
</table>

<button type="button" id="showaddkey" class="btn btn-success mt-3" role="button">Add API Key</button>

<div class="card mt-3 d-none" id="addkeycard">
	<div class="card-header">Add API Key</div>
	<div class="card-body">
		<form method="post" action="{{ url('/profile/addkey') }}" id="addkeyform">
			<input type="hidden" name="csrftoken" value="{{csrftoken}}">
			<div class="row g-3">
				<div class="col-md-6">
					<label for="addkey_description" class="form-label">Description</label>
					<input class="form-control" type="text" name="description" id="addkey_description" value="" placeholder="Key description...">
				</div>
				<div class="col-md-6">
					<label for="addkey_recordregex" class="form-label">Record Regex</label>
					<input class="form-control font-monospace" type="text" name="recordregex" id="addkey_recordregex" value="">
				</div>
				<div class="col-md-12">
					<div class="d-flex flex-column gap-2">
						<div class="d-flex align-items-center">
							<span class="me-2" style="min-width: 10em;">Domain Read</span>
							<div class="btn-group" role="group">
								<input type="radio" class="btn-check" name="domains_read" id="add_domains_read_yes" value="true" autocomplete="off">
								<label class="btn btn-sm btn-outline-success" for="add_domains_read_yes">Yes</label>
								<input type="radio" class="btn-check" name="domains_read" id="add_domains_read_no" value="false" autocomplete="off" checked>
								<label class="btn btn-sm btn-outline-danger" for="add_domains_read_no">No</label>
							</div>
						</div>
						<div class="d-flex align-items-center">
							<span class="me-2" style="min-width: 10em;">Domain Write</span>
							<div class="btn-group" role="group">
								<input type="radio" class="btn-check" name="domains_write" id="add_domains_write_yes" value="true" autocomplete="off">
								<label class="btn btn-sm btn-outline-success" for="add_domains_write_yes">Yes</label>
								<input type="radio" class="btn-check" name="domains_write" id="add_domains_write_no" value="false" autocomplete="off" checked>
								<label class="btn btn-sm btn-outline-danger" for="add_domains_write_no">No</label>
							</div>
						</div>
						<div class="d-flex align-items-center">
							<span class="me-2" style="min-width: 10em;">User Read</span>
							<div class="btn-group" role="group">
								<input type="radio" class="btn-check" name="user_read" id="add_user_read_yes" value="true" autocomplete="off">
								<label class="btn btn-sm btn-outline-success" for="add_user_read_yes">Yes</label>
								<input type="radio" class="btn-check" name="user_read" id="add_user_read_no" value="false" autocomplete="off" checked>
								<label class="btn btn-sm btn-outline-danger" for="add_user_read_no">No</label>
							</div>
						</div>
						<div class="d-flex align-items-center">
							<span class="me-2" style="min-width: 10em;">User Write</span>
							<div class="btn-group" role="group">
								<input type="radio" class="btn-check" name="user_write" id="add_user_write_yes" value="true" autocomplete="off">
								<label class="btn btn-sm btn-outline-success" for="add_user_write_yes">Yes</label>
								<input type="radio" class="btn-check" name="user_write" id="add_user_write_no" value="false" autocomplete="off" checked>
								<label class="btn btn-sm btn-outline-danger" for="add_user_write_no">No</label>
							</div>
						</div>
						<div class="d-flex align-items-center">
							<span class="me-2" style="min-width: 10em;">Admin Features</span>
							<div class="btn-group" role="group">
								<input type="radio" class="btn-check" name="admin_features" id="add_admin_features_yes" value="true" autocomplete="off">
								<label class="btn btn-sm btn-outline-success" for="add_admin_features_yes">Yes</label>
								<input type="radio" class="btn-check" name="admin_features" id="add_admin_features_no" value="false" autocomplete="off" checked>
								<label class="btn btn-sm btn-outline-danger" for="add_admin_features_no">No</label>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="mt-3">
				<button type="submit" class="btn btn-success" role="button">Add</button>
				<button type="button" id="canceladdkey" class="btn btn-warning" role="button">Cancel</button>
			</div>
		</form>
	</div>
</div>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete'} only %}
	{% block title %}
		Delete API Key
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this API Key?
		<br><br>
		Deleting this key will cause any applications using it to no longer have access to the api.
		<br><br>
		This can not be undone and any applications will need to be updated to use a new key.
	{% endblock %}
{% endembed %}
