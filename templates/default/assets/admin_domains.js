$(function() {
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

	$('a[data-action="addAdminDomain"]').click(function () {
		var okButton = $('#createAdminDomain button[data-action="ok"]');
		okButton.text("Create");

		okButton.off('click').click(function () {
			if ($("#adddomain").valid()) {
				$("#adddomain").submit();
				$('#createAdminDomain').modal('hide');
			}
		});

		var cancelButton = $('#createAdminDomain button[data-action="cancel"]');
		cancelButton.off('click').click(function () {
			$("#adddomain").validate().resetForm();
		});

		$('#createAdminDomain').modal({'backdrop': 'static'});

		return false;
	});
});
