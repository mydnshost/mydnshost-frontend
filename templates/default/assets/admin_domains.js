
$("#adddomain").validate({
	highlight: function(element) {
		$(element).closest('.form-group').addClass('has-danger');
	},
	unhighlight: function(element) {
		$(element).closest('.form-group').removeClass('has-danger');
	},
	errorClass: 'form-control-feedback',
	rules: {
		domainname: {
			required: true
		},
		owner: {
			email: true
		}
	},
});
