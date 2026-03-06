<h1>Admin Elevation</h1>

{% if hasAdminToken is defined and hasAdminToken %}
<p>You are currently elevated. Elevation expires in <span class="badge bg-light text-dark elevation-timer"></span>.</p>

<form method="post" action="{{ url('/admin/deelevate') }}">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<button type="submit" class="btn btn-warning">De-elevate</button>
	<a href="{{ redirect | default(url('/admin/domains')) }}" class="btn btn-secondary">Back</a>
</form>
{% else %}
<p>Additional verification is required for admin write operations. Please verify your identity to continue.</p>

<form method="post" action="{{ url('/admin/elevate') }}">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input type="hidden" name="redirect" value="{{ redirect }}">

	{% include 'admin/blocks/elevate_form.tpl' %}

	<div class="mt-2">
		<button type="submit" class="btn btn-warning">Elevate</button>
		<a href="{{ redirect | default(url('/admin/domains')) }}" class="btn btn-secondary">Cancel</a>
	</div>
</form>
{% endif %}
