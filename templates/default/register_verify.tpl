<h1>Registration Verification</h1>

<p>
	To complete the registration, please set a password for your account.
</p>

<form class="form-signin small" method="post" id="registerform">
	<div class="form-group">
		<label for="inputPassword" class="sr-only">Password</label>
		<input type="password" name="inputPassword" id="inputPassword" class="form-control" placeholder="Password" required autofocus>
	</div>

	<div class="form-group">
		<label for="inputPassword2" class="sr-only">Confirm Password</label>
		<input type="password" name="inputPassword2" id="inputPassword2" class="form-control" placeholder="Confirm Password" required>
	</div>

	<button class="btn btn-lg btn-primary btn-block" type="submit">Complete registration</button>
</form>

<script src="{{ url('/assets/register_verify.js') }}"></script>
