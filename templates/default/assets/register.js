$(function() {
	$("#registerform").validate({
		highlight: function(element) {
			$(element).closest('.form-group').addClass('has-danger');
		},
		unhighlight: function(element) {
			$(element).closest('.form-group').removeClass('has-danger');
		},
		errorClass: 'form-control-feedback',
		rules: {
			inputEmail: {
				required: true,
				email: true
			},
			inputEmail2: {
				equalTo: "#inputEmail"
			},
			inputName: {
				required: true
			},
			acceptTerms: {
				required: function(element) {
					return $('#acceptTerms').length > 0;
				},
			},
		},
	});

	$('button[type="submit"]').click(function () {
		if ($("#registerform").valid()) {
			grecaptcha.execute();
		}

		return false;
	});
});

function registerSubmit(token) {
	document.getElementById("registerform").submit();
}
