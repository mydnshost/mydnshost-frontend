<H1>Add Domain</H1>

{% if hasPermission(['domains_create']) %}
	<form id="adddomain" method="post" action="{{ url("#{pathprepend}/domains/create") }}">
		<input type="hidden" name="csrftoken" value="{{csrftoken}}">
		<div class="form-group row">
			<label for="domainname" class="col-3 col-form-label">Domain Name</label>
			<div class="col-9">
				<input class="form-control" type="text" value="" id="domainname" name="domainname">
			</div>
		</div>
		{% if adminroute and hasPermission(['manage_domains']) %}
			<div class="form-group row">
				<label for="owner" class="col-3 col-form-label">Owner</label>
				<div class="col-9">
					<input class="form-control" type="text" value="" id="owner" name="owner">
				</div>
			</div>
		{% endif %}

		<div class="d-grid mt-2 gap-2">
			<a href="{{ url("#{pathprepend}/domains") }}" class="btn btn-warning" data-bs-dismiss="modal">Cancel</a>
			<button type="submit" data-action="ok" class="btn btn-success">Add Domain</button>
		</div>
	</form>
{% else %}
	<p>
		You do not have permission to create domains.
	</p>
{% endif %}
