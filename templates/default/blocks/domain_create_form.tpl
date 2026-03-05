<div class="form-group row mb-3">
	<label for="domainname" class="col-3 col-form-label">Domain Name</label>
	<div class="col-9">
		<input class="form-control" type="text" value="" id="domainname" name="domainname">
	</div>
</div>
{% if show_owner %}
	<div class="form-group row mb-3">
		<label for="owner" class="col-3 col-form-label">Owner</label>
		<div class="col-9">
			<input class="form-control" type="text" value="" id="owner" name="owner">
		</div>
	</div>
{% endif %}
