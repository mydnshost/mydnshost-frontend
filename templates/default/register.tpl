<h1>Register</h1>

<form class="form-signin small" method="post" id="registerform">
	<div class="form-group">
		<label for="inputEmail" class="visually-hidden">Email address</label>
		<input type="email" name="inputEmail" id="inputEmail" class="form-control" placeholder="Email address" required autofocus{% if posted.inputEmail %} value="{{ posted.inputEmail }}"{% endif %}>
	</div>

	<div class="form-group">
		<label for="inputEmail2" class="visually-hidden">Confim email address</label>
		<input type="email2" name="inputEmail2" id="inputEmail2" class="form-control" placeholder="Confirm Email address" required{% if posted.inputEmail %} value="{{ posted.inputEmail2 }}"{% endif %}>
	</div>

	<div class="form-group">
		<label for="inputName" class="visually-hidden">Your name</label>
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

	<div id='recaptcha' class="g-recaptcha" data-sitekey="{{ recaptcha }}" data-callback="registerSubmit" data-size="invisible" data-badge=""></div>

	<div class="d-grid mt-2 gap-2">
		<button class="btn btn-lg btn-primary" type="submit">Register</button>
	</div>

        <div class="recaptchaterms small text-muted form-group">
                This site is protected by reCAPTCHA and the Google <a href="https://policies.google.com/privacy">Privacy Policy</a> and <a href="https://policies.google.com/terms">Terms of Service</a> apply.
        </div>
</form>

<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<script src="{{ url('/assets/register.js') }}"></script>
