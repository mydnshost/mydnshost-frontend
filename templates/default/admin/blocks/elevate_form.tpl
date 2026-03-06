{% if adminElevationType == '2fa' %}
	<div class="form-group row mb-3">
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
