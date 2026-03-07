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

<form id="elevatePageForm" method="post" action="{{ url('/admin/elevate') }}">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input type="hidden" name="redirect" value="{{ redirect }}">

	{% include 'admin/blocks/elevate_form.tpl' %}

	<div class="mt-2">
		<button type="submit" class="btn btn-warning">Elevate</button>
		<a href="{{ redirect | default(url('/admin/domains')) }}" class="btn btn-secondary">Cancel</a>
	</div>
</form>

<script>
$(function() {
	var $push = $('#elevate2fapush');
	if (!$push.length) return;

	$.ajax({
		url: '{{ url("/admin/elevate/2fa_push_check.json") }}',
		method: 'GET',
		dataType: 'json',
		success: function(data) {
			if (data.error) return;

			$push.removeClass('d-none');

			$.ajax({
				url: '{{ url("/admin/elevate/2fa_push.json") }}',
				method: 'GET',
				dataType: 'json',
				success: function(pushData) {
					if (pushData.pushcode) {
						$push.html('2FA Push approved!');
						$push.removeClass('alert-info').addClass('alert-success');
						$('#elevate_code').val(pushData.pushcode);
						$('#elevate2famanual').hide();
						$('#elevatePageForm').submit();
					} else {
						$push.html('2FA Push failed. Please enter a code manually.');
						$push.removeClass('alert-info').addClass('alert-warning');
					}
				},
				error: function() {
					$push.html('2FA Push failed. Please enter a code manually.');
					$push.removeClass('alert-info').addClass('alert-warning');
				}
			});
		}
	});
});
</script>
{% endif %}
