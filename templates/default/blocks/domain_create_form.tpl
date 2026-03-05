<div class="form-group row mb-3">
	<label for="domainname" class="col-4 col-form-label">Domain Name</label>
	<div class="col-8">
		<input class="form-control" type="text" value="" id="domainname" name="domainname">
	</div>
</div>
{% if hasPermission(['manage_domains']) %}
	<div class="form-group row mb-3{% if hide_owner %} d-none{% endif %}" id="domainOwnerRow">
		<label for="owner" class="col-4 col-form-label">Owner</label>
		<div class="col-8">
			<input class="form-control" type="text" value="" id="owner" name="owner">
		</div>
	</div>
{% endif %}
