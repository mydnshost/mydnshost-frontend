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
			<th>Default domain page</th>
			<td data-type="option" data-name="domain_defaultpage" data-value="{{ domain_defaultpage }}">
			{{ domain_defaultpage }}
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
		<button type="button" data-action="edituser" class="btn btn-primary" role="button">Edit user details</button>
		<button type="button" data-action="saveuser" class="btn btn-success hidden" role="button">Save</button>
		{% if hasPermission(['domains_stats']) %}
			<a href="{{ url("/profile/stats") }}" class="btn btn-primary" role="button">Profile Statistics</a>
		{% endif %}

		<div class="float-right">
			{% if candelete %}
				<a href="{{ url("/profile/delete") }}" class="btn btn-info btn-danger" role="button">Delete Account</a>
			{% endif %}
		</div>
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
			<button class="btn btn-lg btn-primary btn-block" type="submit">De-Authenticate</button>
		</form>
	</div>
{% else %}
	<br><br>

	<H2>API/2FA Key Authentication</H2>
	For security, you must re-authenticate to view API/2FA Keys.

	<div class="container">
		<form class="form-signin small" method="post" action="{{ url('/checkauth') }}">
			<input type="hidden" name="csrftoken" value="{{csrftoken}}">
			<input type="hidden" name="redirect" value="/profile">
			<label for="inputPassword" class="sr-only">Password</label>
			<input type="password" name="pass" id="inputPassword" class="form-control" placeholder="Password" required>
			<button class="btn btn-lg btn-primary btn-block" type="submit">Authenticate</button>
		</form>
	</div>
{% endif %}

<script src="{{ url('/assets/profile.js') }}"></script>
