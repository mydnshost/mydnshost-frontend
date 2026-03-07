{% if adminElevationType == '2fa' %}
	<div id="elevate2fapush" class="alert alert-info d-none mb-3">
		<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
		Waiting for 2FA Push...
	</div>
	<div id="elevate2famanual" class="form-group row mb-3">
		<label for="elevate_code" class="col-3 col-form-label">2FA Code</label>
		<div class="col-9">
			<input class="form-control" type="text" id="elevate_code" name="code" placeholder="000000" autocomplete="off">
		</div>
	</div>
{% else %}
	<div class="form-group row mb-3">
		<label for="elevate_password" class="col-3 col-form-label">Password</label>
		<div class="col-9">
			<input class="form-control" type="password" id="elevate_password" name="password">
		</div>
	</div>
{% endif %}
