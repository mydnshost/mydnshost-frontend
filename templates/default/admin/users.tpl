<H1>User List</H1>

<input class="form-control" data-search-top="table#userlist" value="" placeholder="Search..."><br>

<table id="userlist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">ID</th>
			<th class="email">Email</th>
			<th class="realname">Realname</th>
			<th class="admin">Admin</th>
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
			</td>
			<td class="admin">
				<span class="value badge {% if userinfo.admin == 'true' %}badge-primary{% else %}badge-default{% endif %}" data-field="admin" data-class-yes="badge-primary" data-class-no="badge-default">
					{{ userinfo.admin | yesno }}
				</span>
				{% if userinfo.email != user.email and hasPermission(['manage_admins']) %}
					<span class="action {% if userinfo.admin != 'true' %}hidden{% endif %}" data-value="Yes">
						<button type="button" data-user-action="demote" data-user="{{ userinfo.id }}" class="btn btn-sm btn-warning float-right">Demote</button>
					</span>
					<span class="action {% if userinfo.admin == 'true' %}hidden{% endif %}" data-value="No">
						<button type="button" data-user-action="promote" data-user="{{ userinfo.id }}" class="btn btn-sm btn-info float-right">Promote</button>
					</span>
				{% endif %}
			</td>
			<td class="state">
				<span class="value badge {% if userinfo.disabled == 'true' %}badge-success{% else %}badge-danger{% endif %}" data-field="disabled" data-class-yes="badge-success" data-class-no="badge-danger">
					{{ userinfo.disabled | yesno }}
				</span>
				{% if userinfo.email != user.email and hasPermission(['manage_users']) %}
					<span class="action {% if userinfo.disabled != 'true' %}hidden{% endif %}" data-value="Yes">
						<button type="button" data-user-action="unsuspend" data-user="{{ userinfo.id }}" class="btn btn-sm btn-info float-right">Unsuspend</button>
					</span>
					<span class="action {% if userinfo.disabled == 'true' %}hidden{% endif %}" data-value="No">
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

<br><br>

<h1>Add User</h1>

<form id="adduser" method="post" action="{{ url('/admin/users/create') }}">
	<div class="form-group row">
		<label for="email" class="col-2 col-form-label">Email Address</label>
		<div class="col-10">
			<input class="form-control" type="email" value="" id="email" name="email">
		</div>
	</div>
	<div class="form-group row">
		<label for="realname" class="col-2 col-form-label">Real Name</label>
		<div class="col-10">
			<input class="form-control" type="text" value="" id="realname" name="realname">
		</div>
	</div>

	<div class="form-group row">
		<label for="password" class="col-2 col-form-label">Password</label>
		<div class="col-10">
			<input class="form-control" type="password" value="" id="password" name="password">
		</div>
	</div>
	<div class="form-group row">
		<label for="confirmpassword" class="col-2 col-form-label">Confirm Password</label>
		<div class="col-10">
			<input class="form-control" type="password" value="" id="confirmpassword" name="confirmpassword">
		</div>
	</div>

	<div class="form-group row">
		<div class="col-10 offset-2">
			<button type="submit" class="btn btn-primary btn-block">Add User</button>
		</div>
	</div>
</form>


<script src="{{ url('/assets/admin_users.js') }}"></script>
