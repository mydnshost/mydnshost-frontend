$(function() {
	$("#forgotpasswordform").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
		rules: {
			inputEmail: {
				required: true,
				email: true
			},
		},
	});

	$('button[type="submit"]').click(function () {
		return $("#forgotpasswordform").valid();
	});
});
