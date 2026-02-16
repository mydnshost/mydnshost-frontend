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
