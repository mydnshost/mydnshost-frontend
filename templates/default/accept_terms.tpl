<H1>
	User :: {% block termstitle %}Accept Terms of Service{% endblock %}
</H1>

<div class="container">
	{% block termsblurb %}
	<p>
		{% if termstime > 0 %}
			There has been an update to our terms of service. Please review the changes and confirm your acceptance in order to continue to use this service.
		{% else %}
			You must accept the terms of service in order to continue to use this service.
		{% endif %}
	</p>
	{% endblock %}

	<form class="form-signin small" method="post" action="{{ url('/profile/terms') }}">
		<input type="hidden" name="csrftoken" value="{{csrftoken}}">

		<div class="form-check form-group">
			<label class="form-check-label">
				<input type="checkbox" name="acceptTerms" id="acceptTerms" class="form-check-input" required{% if posted.acceptTerms %} checked{% endif %}>
				{{ termsText | raw }}
			</label>
		</div>

		<div class="d-grid mt-2 gap-2">
			<button class="btn btn-lg btn-primary" type="submit">Accept</button>
		</div>
	</form>

	<p>
		Alternatively, if you do not accept, you can <a href="{{ url('/logout') }}">Logout</a> or <a href="{{ url('/profile/delete') }}">delete your account</a>.
	</p>
</div>
