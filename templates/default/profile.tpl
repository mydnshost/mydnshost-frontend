<H1>User :: {{ user.realname }}</H1>

<form method="post" id="editprofile">
<input type="hidden" name="csrftoken" value="{{csrftoken}}">
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
		<tr>
			<th>
				Account Permissions
			</th>
			<td>
				<ul>
				{% for permission,value in useraccess %}
					<li> {{ permission }}
				{% endfor %}
				</ul>
			</td>
		</tr>
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

				<form class="d-inline form-inline editform" method="post" action="{{ url('/profile/editkey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/deletekey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url('/profile/addkey') }}" class="form-inline form-group" id="addkeyform">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
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

<br><br>

<H2>2FA Keys</H2>

Here you can see what 2FA Keys have been added to your account. If you have a 2FA key assigned, you will need to provide the code from at least one of the keys when ever you log in with a username and password.
<br><br>
You will only be able to see the key and associated QR code for any keys that have not yet been used to log in.

<table id="2fakeys" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
			<th class="lastused">Last Used</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for key,keydata in twofactorkeys %}
		<tr data-value="{{ key }}">
			<td class="key">
				{% if keydata.key %}
					<strong>{{ keydata.key }}</strong>
					<br>
					<img src="{{ keydata.key | get2FAQRCode }}" alt="{{ keydata.key }}">
				{% else %}
					<em>Hidden</em>
				{% endif %}
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}">
				{{ keydata.description }}
			</td>
			<td class="lastused">
				{% if keydata.lastused == 0 %}
					<em>Never</em>
				{% else %}
					{{ keydata.lastused | date }}
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="edit2fakey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="save2fakey" class="hidden btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="delete2fakey" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline editform" method="post" action="{{ url('/profile/edit2fakey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/delete2fakey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url('/profile/add2fakey') }}" class="form-inline form-group" id="add2faform">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">
	<button type="submit" class="btn btn-success" role="button">Add 2FA Key</button>
</form>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete2FA'} only %}
	{% block title %}
		Delete 2FA Key
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this 2FA Key?
		<br><br>
		Deleting this key will prevent logins using this device.
		<br><br>
		This can not be undone and you will need to re-enroll your device again.
	{% endblock %}
{% endembed %}

<script src="{{ url('/assets/profile.js') }}"></script>
