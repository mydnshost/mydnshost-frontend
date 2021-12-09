<H1>
	User :: Delete
</H1>

<div class="container">
	<p>
		You must enter the following confirmation code to delete your account: <strong>{{ confirmCode }}</strong>.
		<br><em><small>(This code is only valid for up to 2 minutes.)</small></em>
	</p>
	<p>
		Please note, deleting your account is instant and can not be undone, you will need to sign up again for a new account if you wish to start using this service again.
	</p>
	<p>
		Any domains that are linked to your account will be unlinked and may remain on the system until they are automatically removed after some time.
	</p>

	<form class="form-signin small" method="post" action="{{ url('/profile/delete') }}">
		<input type="hidden" name="csrftoken" value="{{csrftoken}}">

		<label for="inputConfirmCode" class="visually-hidden">Confirmation Code</label>
		<input type="text" name="confirmCode" id="inputConfirmCode" class="form-control" placeholder="Confirmation Code">

		{% if twofactor %}
			<label for="input2FAKey" class="visually-hidden">2FA Code</label>
			<input type="text" name="2fakey" id="input2FAKey" class="form-control" placeholder="2FA Code">
		{% endif %}

		<div class="d-grid mt-2 gap-2">
			<button class="btn btn-lg btn-danger" type="submit">Delete Account</button>
		</div>
	</form>

	<form class="form-signin small" method="get" action="{{ url('/profile') }}">
		<div class="d-grid mt-2 gap-2">
			<button class="btn btn-lg btn-primary" type="submit">Do not delete account</button>
		</div>
	</form>
</div>

