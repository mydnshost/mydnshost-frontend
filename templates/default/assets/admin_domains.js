$(function() {
	$("#adddomain").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
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

		$('#createAdminDomain').modal('show');

		return false;
	});
});
