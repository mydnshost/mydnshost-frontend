$(function() {
	$("#articleform").validate({
		highlight: function(element) {
			$(element).closest('.form-group').addClass('has-danger');
		},
		unhighlight: function(element) {
			$(element).closest('.form-group').removeClass('has-danger');
		},
		errorClass: 'form-control-feedback',
		rules: {
			title: {
				required: true
			},
			content: {
				required: true
			},
			visiblefrom: {
				required: true,
				number: true
			},
			visibleuntil: {
				required: true,
				number: true
			}
		},
	});
});
