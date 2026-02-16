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
				$('#2fapush').text('2FA push ok.');
				$('#input2FAKey').val(data['pushcode']);
			} else {
				$('#2fapush').text('2FA Push failed, please enter a code manually.');
			}
		}).fail(function(data) {
		  $('#2fapush').text('2FA Push failed, please enter a code manually.');
		});
	}
});
