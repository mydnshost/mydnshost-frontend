<H1>Add User</H1>

{% if hasPermission(['manage_users']) %}
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


		<a href="{{ url("#{pathprepend}/admin/users") }}" class="btn btn-block btn-warning" data-dismiss="modal">Cancel</a>
		<button type="submit" data-action="ok" class="btn btn-block btn-success">Add User</button>
	</form>

	<script src="{{ url('/assets/admin_users.js') }}"></script>
{% else %}
	<p>
		You do not have permission to add Users.
	</p>
{% endif %}
