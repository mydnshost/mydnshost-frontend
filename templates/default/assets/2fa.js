$(function() {
	$("#savedevice").change(function() {
		if (this.checked) {
			$("#devicename").removeClass('d-none');
		} else {
			$("#devicename").addClass('d-none');
		}
	});

	if ($('#2fapush').length > 0) {
		$.ajax({
		  url: '{{ url('/2fa_push.json') }}',
		}).done(function(data) {
			if (data['pushcode'] !== undefined) {
				$('#2fapush').html('2FA push approved!');
				$('#2fapush').removeClass('alert-info').addClass('alert-success');
				$('#input2FAKey').val(data['pushcode']);
				$('#2famanual').hide();
				// TODO: Auto-submit?
				// $('#2fapush').closest('form').submit();
			} else {
				$('#2fapush').html('2FA Push failed<br>Please enter a code manually.');
				$('#2fapush').removeClass('alert-info').addClass('alert-warning');
			}
		}).fail(function(data) {
		  $('#2fapush').html('2FA Push failed<br>Please enter a code manually.');
		  $('#2fapush').removeClass('alert-info').addClass('alert-warning');
		});
	}
});
