<H1>User List</H1>

<input type="hidden" id="csrftoken" value="{{csrftoken}}">
<input class="form-control" data-search-top="table#userlist" value="" placeholder="Search..."><br>

{% if hasPermission(['manage_users']) %}
<div class="float-right">
	<button type="button" data-action="addNewUser" class="btn btn-success">Add User</button>
</div>
<br><br>
{% endif %}

<table id="userlist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">ID</th>
			<th class="email">Email</th>
			<th class="realname">Realname</th>
			<th class="permissions">Permissions</th>
			<th class="state">Disabled</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for userinfo in users %}
		<tr data-searchable-value="{{ userinfo.email }}">
			<td class="id">
				{{ userinfo.id }}
			</td>
			<td class="email">
				<img src="{{ userinfo.email | gravatar }}" alt="{{ userinfo.realname }}" class="minigravatar" />&nbsp;
				{{ userinfo.email }}
			</td>
			<td class="realname">
				{{ userinfo.realname }}
				<span class="action {% if userinfo.disabled != 'true' %}hidden{% endif %}" data-showsuspend="Yes">
					<button type="button" data-extra-prompt="Suspend Reason:" data-user-action="suspendreason" data-user="{{ userinfo.id }}" class="btn btn-sm btn-primary float-right">Set Suspend Reason</button>
				</span>
				<span class="action {% if userinfo.disabled != 'true' or not userinfo.disabledreason %}hidden{% endif %}" data-showsuspend="Yes">
					<br>
					<span class="small muted">(<strong>Disabled:</strong> <span class="value" data-raw="yes" data-field="disabledreason">{{ userinfo.disabledreason }}</span>)</span>
				</span>
				{% if userinfo.unverified %}
					<br>
					<button data-user-action="resendwelcome" data-user="{{ userinfo.id }}" class="btn btn-sm btn-primary">Resend Welcome Email</a>
				{% endif %}
				{% if userinfo.pendingreset %}
					<br>
					<span class="small muted">(Password reset pending)</span>
				{% endif %}
			</td>
			<td class="permissions">
				<div class="permissionsText">
					<span> {{ userinfo.permissions | keys | join(', ') }} </span>
					{% if hasPermission(['manage_permissions']) %}
						{% if userinfo.permissions|keys|length > 0 %}<br>{% endif %}
						<button data-action="editpermissions" class="btn btn-sm btn-info">Edit Permissions</button>
					{% endif %}
				</div>
				<table class="permissionsTable table table-sm hidden">
				{% for permission in ['manage_domains', 'domains_create', 'manage_users', 'manage_permissions', 'impersonate_users'] %}
					<tr>
						<td class="name">
							{{ permission }}
						</td>
						<td class="value">
							<span class="value badge {% if userinfo.permissions[permission] == 'true' %}badge-primary{% else %}badge-default{% endif %}" data-permission="{{ permission }}" data-class-yes="badge-primary" data-class-no="badge-default">
								{{ userinfo.permissions[permission] | yesno }}
							</span>
						</td>
						<td class="actions">
							{% if (userinfo.email != user.email or (permission != "manage_permissions" and permission != "manage_users")) and hasPermission(['manage_permissions']) %}
								<button type="button" data-permission="{{ permission }}" data-user="{{ userinfo.id }}" class="btn btn-sm btn-info">Toggle</button>
							{% endif %}
						</td>
					</tr>
				{% endfor %}
				</table>
			</td>
			<td class="state">
				<span class="value badge {% if userinfo.disabled == 'true' %}badge-success{% else %}badge-danger{% endif %}" data-field="disabled" data-class-yes="badge-success" data-class-no="badge-danger">
					{{ userinfo.disabled | yesno }}
				</span>
				{% if userinfo.email != user.email and hasPermission(['manage_users']) %}
					<span class="action {% if userinfo.disabled != 'true' %}hidden{% endif %}" data-showsuspend="Yes">
						<button type="button" data-user-action="unsuspend" data-user="{{ userinfo.id }}" class="btn btn-sm btn-info float-right">Unsuspend</button>
					</span>
					<span class="action {% if userinfo.disabled == 'true' %}hidden{% endif %}" data-showsuspend="No">
						<button type="button" data-user-action="suspend" data-user="{{ userinfo.id }}" class="btn btn-sm btn-warning float-right">Suspend</button>
					</span>
				{% endif %}
			</td>
			<td class="actions">
				{% if userinfo.email != user.email %}
					{% if hasPermission(['impersonate_users']) %}
						<a href="{{ url('/impersonate/user/' ~ userinfo.id) }}" class="btn btn-sm btn-success">Impersonate</a>
					{% endif %}

					<button data-action="deleteuser" data-id="{{ userinfo.id }}" class="btn btn-sm btn-danger">Delete</a>
				{% endif %}
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete'} only %}
	{% block title %}
		Delete User
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this user?
		<br><br>
		This will change all of their owned domains to unowned.
	{% endblock %}
{% endembed %}


{% if hasPermission(['manage_users']) %}
	{% embed 'blocks/modal_confirm.tpl' with {'id': 'createUser', 'large': true, 'csrftoken': csrftoken} only %}
		{% block title %}
			Add User
		{% endblock %}

		{% block body %}
			<form id="adduser" method="post" action="{{ url('/admin/users/create') }}">
				<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				<div class="form-group row">
					<label for="email" class="col-3 col-form-label">Email Address</label>
					<div class="col-9">
						<input class="form-control" type="email" value="" id="email" name="email">
					</div>
				</div>
				<div class="form-group row">
					<label for="realname" class="col-3 col-form-label">Real Name</label>
					<div class="col-9">
						<input class="form-control" type="text" value="" id="realname" name="realname">
					</div>
				</div>

				<div class="form-check">
					<label class="form-check-label">
						<input type="radio" class="form-check-input" name="registerUser" id="registerUserAuto" value="registerUserAuto" checked>
						Send user a registration email to let them pick their own password.
					</label>
				</div>

				<div class="form-check">
					<label class="form-check-label">
						<input type="radio" class="form-check-input" name="registerUser" id="registerUserManual" value="registerUserManual">
						Choose a password for the new user and do not send them a welcome email.
					</label>
				</div>

				<div class="form-group row registerUserManual">
					<label for="password" class="col-3 col-form-label">Password</label>
					<div class="col-9">
						<input class="form-control" type="password" value="" id="password" name="password" disabled>
					</div>
				</div>

				<div class="form-group row registerUserManual">
					<label for="confirmpassword" class="col-3 col-form-label">Confirm Password</label>
					<div class="col-9">
						<input class="form-control" type="password" value="" id="confirmpassword" name="confirmpassword" disabled>
					</div>
				</div>
			</form>
		{% endblock %}

		{% block buttons %}
			<button type="button" data-action="cancel" class="btn btn-primary" data-dismiss="modal">Cancel</button>
			<button type="button" data-action="ok" class="btn btn-success">Ok</button>
		{% endblock %}
	{% endembed %}
{% endif %}

<script src="{{ url('/assets/admin_users.js') }}"></script>
