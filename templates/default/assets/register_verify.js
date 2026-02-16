$(function() {
	$("#registerform").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
		rules: {
			inputPassword: {
				required: true,
			},
			inputPassword2: {
				equalTo: "#inputPassword"
			},
		},
	});

	$('button[type="submit"]').click(function () {
		return $("#registerform").valid();
	});
});
