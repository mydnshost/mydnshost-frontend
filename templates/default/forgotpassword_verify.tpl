<h1>Forgot Password</h1>

<p>
	To complete the reset, please set a new password for your account.
</p>

<form class="form-signin small" method="post" id="forgotpasswordform">
	<div class="form-group">
		<label for="inputPassword" class="visually-hidden">Password</label>
		<input type="password" name="inputPassword" id="inputPassword" class="form-control" placeholder="Password" required autofocus>
	</div>

	<div class="form-group">
		<label for="inputPassword2" class="visually-hidden">Confirm Password</label>
		<input type="password" name="inputPassword2" id="inputPassword2" class="form-control" placeholder="Confirm Password" required>
	</div>

	<div class="d-grid mt-2 gap-2">
		<button class="btn btn-lg btn-primary" type="submit">Change Password</button>
	</div>
</form>

<script src="{{ url('/assets/forgotpassword_verify.js') }}"></script>
