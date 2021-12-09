<h1>Forgot Password</h1>

<form class="form-signin small" method="post" id="forgotpasswordform">
	<div class="form-group">
		<label for="inputEmail" class="visually-hidden">Email address</label>
		<input type="email" name="inputEmail" id="inputEmail" class="form-control" placeholder="Email address" required autofocus{% if posted.inputEmail %} value="{{ posted.inputEmail }}"{% endif %}>
	</div>

	<div class="d-grid mt-2 gap-2">
		<button class="btn btn-lg btn-primary" type="submit">Request Password Reset</button>
	</div>
</form>

<script src="{{ url('/assets/forgotpassword.js') }}"></script>
