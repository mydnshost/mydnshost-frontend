<h1>Register</h1>

<form class="form-signin small" method="post" id="registerform">
	<div class="form-group">
		<label for="inputEmail" class="sr-only">Email address</label>
		<input type="email" name="inputEmail" id="inputEmail" class="form-control" placeholder="Email address" required autofocus{% if posted.inputEmail %} value="{{ posted.inputEmail }}"{% endif %}>
	</div>

	<div class="form-group">
		<label for="inputEmail2" class="sr-only">Confim email address</label>
		<input type="email2" name="inputEmail2" id="inputEmail2" class="form-control" placeholder="Confirm Email address" required{% if posted.inputEmail %} value="{{ posted.inputEmail2 }}"{% endif %}>
	</div>

	<div class="form-group">
		<label for="inputName" class="sr-only">Your name</label>
		<input type="text" name="inputName" id="inputName" class="form-control" placeholder="Your Name" required{% if posted.inputEmail %} value="{{ posted.inputName }}"{% endif %}>
	</div>

	{% if requireTerms %}
	<div class="form-check form-group">
		<label class="form-check-label">
			<input type="checkbox" name="acceptTerms" id="acceptTerms" class="form-check-input" required{% if posted.acceptTerms %} checked{% endif %}>
			{{ termsText | raw }}
		</label>
	</div>
	{% endif %}

	<div id='recaptcha' class="hidden g-recaptcha" data-sitekey="{{ recaptcha }}" data-callback="registerSubmit" data-size="invisible" data-badge="inline"></div>

	<button class="btn btn-lg btn-primary btn-block" type="submit">Register</button>
</form>

<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<script src="{{ url('/assets/register.js') }}"></script>
