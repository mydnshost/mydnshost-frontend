<H1>User :: {{ user.realname }}</H1>

<form method="post" id="editprofile">
<input type="hidden" name="changetype" value="profile">
<table id="profileinfo" class="table table-striped table-bordered">
	<tbody>
		<tr>
			<th>Name</th>
			<td data-name="realname" data-value="{{ user.realname }}">{{ user.realname }}</td>
		</tr>
		<tr>
			<th>Email Address</th>
			<td data-name="email" data-value="{{ user.email }}">{{ user.email }}</td>
		</tr>
		<tr>
			<th>
				Avatar<br>
				<small class="form-text text-muted">(This can be changed at <a href="//gravatar.com/emails">Gravatar</a>)</small>
			</th>
			<td>
				<img src="{{ user.email | gravatar(200) }}" alt="{{ user.realname }}" class="minigravatar" />
			</td>
		</tr>
		<tr data-hidden="true" class="hidden">
			<th>
				New Password<br>
				<small class="form-text text-muted">(Leave blank if unchanged)</small>
			</th>
			<td data-type="password" data-name="password" data-value=""></td>
		</tr>
		<tr data-hidden="true" class="hidden">
			<th>
				Confirm New Password<br>
				<small class="form-text text-muted">(Leave blank if unchanged)</small>
			</th>
			<td data-type="password" data-name="confirmpassword" data-value=""></td>
		</tr>
		{% if user.admin %}
			<tr>
				<th>Admin</th>
				<td> {{ user.admin | yesno }}</td>
			</tr>
			<tr>
				<th>Disabled</th>
				<td> {{ user.disabled | yesno }}</td>
			</tr>
		{% endif %}

	</tbody>
</table>
</form>

<div class="row" id="usercontrols">
	<div class="col">
		<button type="button" data-action="edituser" class="btn btn-primary" role="button">Edit user details</button>
		<button type="button" data-action="saveuser" class="btn btn-success hidden" role="button">Save</button>
	</div>
</div>


<br><br>

<H2>API Keys</H2>

<table id="apikeys" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
			<th class="domains_read">Domain Read</th>
			<th class="domains_write">Domain Write</th>
			<th class="user_read">User Read</th>
			<th class="user_write">User Write</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for key,keydata in apikeys %}
		<tr {% if editedaccess[email] %} data-edited="true"{% endif %} data-value="{{ key }}">
			<td class="key">
				{{ key }}
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}">
				{{ keydata.description }}
			</td>
			<td class="domains_read" data-radio data-name="domains_read" data-value="{{ keydata.domains_read | yesno }}">
				{% if keydata.domains_read == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="domains_write" data-radio data-name="domains_write" data-value="{{ keydata.domains_write | yesno }}">
				{% if keydata.domains_write == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="user_read" data-radio data-name="user_read" data-value="{{ keydata.user_read | yesno }}">
				{% if keydata.user_read == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="user_write" data-radio data-name="user_write" data-value="{{ keydata.user_write | yesno }}">
				{% if keydata.user_write == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="editkey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="savekey" class="hidden btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="deletekey" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline editform" method="post" action="{{ url('/profile/editkey/' ~ key) }}"></form>
				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/deletekey/' ~ key) }}"></form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url('/profile/addkey') }}" class="form-inline form-group" id="addkeyform">
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">
	<button type="submit" class="btn btn-success" role="button">Add API Key</button>
</form>

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

<script src="{{ url('/assets/profile.js') }}"></script>
