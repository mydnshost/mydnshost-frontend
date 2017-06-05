$(function() {
	$("#forgotpasswordform").validate({
		highlight: function(element) {
			$(element).closest('.form-group').addClass('has-danger');
		},
		unhighlight: function(element) {
			$(element).closest('.form-group').removeClass('has-danger');
		},
		errorClass: 'form-control-feedback',
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
		return $("#forgotpasswordform").valid();
	});
});
