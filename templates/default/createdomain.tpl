<H1>Add Domain</H1>

{% if hasPermission(['domains_create', 'manage_domains']) %}
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

		<a href="{{ url("#{pathprepend}/domains") }}" class="btn btn-block btn-warning" data-dismiss="modal">Cancel</a>
		<button type="submit" data-action="ok" class="btn btn-block btn-success">Add Domain</button>
	</form>
{% else %}
	<p>
		You do not have permission to create domains.
	</p>
{% endif %}
