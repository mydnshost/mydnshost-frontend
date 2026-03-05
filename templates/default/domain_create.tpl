<H1>Add Domain</H1>

{% if hasPermission(['domains_create']) %}
	<form id="adddomain" method="post" action="{{ url("#{pathprepend}/domains/create") }}">
		<input type="hidden" name="csrftoken" value="{{csrftoken}}">
		{% include 'blocks/domain_create_form.tpl' with {'hide_owner': not adminroute} %}

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
