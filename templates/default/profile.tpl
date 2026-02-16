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
			<td {% if not hasPermission(['admin_managed_user']) %}data-name="email" data-value="{{ user.email }}"{% endif %}>{{ user.email }}</td>
		</tr>
		<tr>
			<th>
				Avatar<br>
				{% if user.avatar == 'gravatar' %}
					<small class="form-text text-muted">(This can be changed at <a href="//gravatar.com/emails">Gravatar</a>)</small>
				{% else %}
					<small class="form-text text-muted">(This can be changed by enabling Gravatar)</small>
				{% endif %}
			</th>
			<td data-type="option" data-name="avatar" data-value="{{ user.avatar }}" data-rich>
				{% if user.avatar == 'gravatar' %}
					<img src="{{ user.email | gravatar(200) }}" alt="{{ user.realname }}" class="avatar" />
				{% elseif user.avatar == 'none' %}
					<img src="{{ 'none' | gravatar(200) }}" alt="{{ user.realname }}" class="avatar" />
				{% else %}
					<img src="{{ user.avatar }}" alt="{{ user.realname }}" class="avatar" />
				{% endif %}
			</td>
		</tr>
		{% if not hasPermission(['admin_managed_user']) %}
		<tr data-hidden="true" class="d-none">
			<th>
				New Password<br>
				<small class="form-text text-muted">(Leave blank if unchanged)</small>
			</th>
			<td data-type="password" data-name="password" data-value=""></td>
		</tr>
		<tr data-hidden="true" class="d-none">
			<th>
				Confirm New Password<br>
				<small class="form-text text-muted">(Leave blank if unchanged)</small>
			</th>
			<td data-type="password" data-name="confirmpassword" data-value=""></td>
		</tr>
		{% endif %}

		<tr>
			<th>Default domain page</th>
			<td data-type="option" data-name="domain_defaultpage" data-value="{{ domain_defaultpage }}">
			{{ domain_defaultpage }}
			</td>
		</tr>

		<tr>
			<th>Sidebar style</th>
			<td data-type="option" data-name="sidebar_layout" data-value="{{ sidebar_layout }}">
			{{ sidebar_layout }}
			</td>
		</tr>

		<tr>
			<th>Theme</th>
			<td data-type="option" data-name="sitetheme" data-value="{{ sitetheme }}">
			{{ sitetheme }}
			</td>
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
		{% if hasPermission(['user_write']) %}
			<button type="button" data-action="edituser" class="btn btn-primary" role="button">Edit user details</button>
			<button type="button" data-action="saveuser" class="btn btn-success d-none" role="button">Save</button>
		{% endif %}
		{% if hasPermission(['domains_stats']) %}
			<a href="{{ url("/profile/stats") }}" class="btn btn-primary" role="button">Profile Statistics</a>
		{% endif %}

		{% if hasPermission(['user_write']) %}
			<div class="float-end">
				{% if candelete %}
					<a href="{{ url("/profile/delete") }}" class="btn btn-danger" role="button">Delete Account</a>
				{% endif %}
			</div>
		{% endif %}
	</div>
</div>

{% if apikeys is not null %}
	{% include 'profile/apikeys.tpl' %}
	{% include 'profile/2fakeys.tpl' %}
	{% include 'profile/2fadevices.tpl' %}

	<br><br>

	<H2>API/2FA Key Authentication</H2>
	For security, once you are done making changes to your API/2FA keys, you can re-enable the authentication prompt by de-authenticating.

	<div class="container">
		<form class="form-signin small" method="post" action="{{ url('/unauth') }}">
			<input type="hidden" name="csrftoken" value="{{csrftoken}}">
			<input type="hidden" name="redirect" value="/profile">
			<div class="d-grid mt-2 gap-2">
				<button class="btn btn-lg btn-primary" type="submit">De-Authenticate</button>
			</div>
		</form>
	</div>
{% elseif (hasPermission(['user_write']) or hasPermission(['user_read'])) %}
	<br><br>

	<H2>API/2FA Key Authentication</H2>
	For security, you must re-authenticate to view API/2FA Keys.

	<div class="container">
		<form class="form-signin small" method="post" action="{{ url('/checkauth') }}">
			<input type="hidden" name="csrftoken" value="{{csrftoken}}">
			<input type="hidden" name="redirect" value="/profile">
			<label for="inputPassword" class="visually-hidden">Password</label>
			<input type="password" name="pass" id="inputPassword" class="form-control" placeholder="Password" required>
			<div class="d-grid mt-2 gap-2">
				<button class="btn btn-lg btn-primary" type="submit">Authenticate</button>
			</div>
		</form>
	</div>
{% endif %}

<script src="{{ url('/assets/profile.js') }}"></script>
