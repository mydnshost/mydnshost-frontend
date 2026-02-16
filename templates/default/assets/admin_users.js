$(function() {
	// Helper to rebuild the permissions summary text from checkbox states
	function updatePermissionsText(permissionsCell) {
		var perms = [];
		permissionsCell.find('.permissionsTable input[data-permission]:checked').each(function() {
			perms.push($(this).data('permission'));
		});
		var listSpan = permissionsCell.find('.permissionsList');
		listSpan.text(perms.length > 0 ? ' ' + perms.join(', ') + ' ' : ' ');

		// Update the line break before the edit button
		var editBtn = permissionsCell.find('button[data-action=editpermissions]');
		if (editBtn.length) {
			editBtn.prev('br').remove();
			if (perms.length > 0) {
				editBtn.before('<br>');
			}
		}
	}

	// Toggle permission via checkbox switch
	$('.permissionsTable input[data-permission]').change(function () {
		var checkbox = $(this);
		var user = checkbox.data('user');
		var permission = checkbox.data('permission');
		var permissionsCell = checkbox.closest('td.permissions');

		var setPermissions = {'permissions': {}};
		setPermissions['permissions'][permission] = checkbox.is(':checked') ? 'True' : 'False';
		setPermissions['csrftoken'] = $('#csrftoken').val();

		// Disable the checkbox while the request is in flight
		checkbox.prop('disabled', true);

		$.ajax({
			url: "{{ url('/admin/users/action') }}/setPermission/" + user,
			data: setPermissions,
			method: "POST",
		}).done(function(data) {
			if (data['error'] !== undefined) {
				alert('There was an error: ' + data['error']);
				// Revert checkbox
				checkbox.prop('checked', !checkbox.is(':checked'));
			} else if (data['response'] !== undefined) {
				var result = data['response']['permissions'][permission];
				var isEnabled = (result === true || result == 'true');
				checkbox.prop('checked', isEnabled);

				updatePermissionsText(permissionsCell);
			}
		}).fail(function(data) {
			alert('There was an error: ' + data.responseText);
			// Revert checkbox
			checkbox.prop('checked', !checkbox.is(':checked'));
		}).always(function() {
			checkbox.prop('disabled', false);
		});
	});

	// Open permissions edit mode
	$('button[data-action=editpermissions]').click(function () {
		var col = $(this).closest('td');

		col.find('div.permissionsText').addClass('d-none');
		col.find('div.permissionsEdit').removeClass('d-none');
	});

	// Close permissions edit mode
	$('button[data-action=closepermissions]').click(function () {
		var col = $(this).closest('td');

		col.find('div.permissionsEdit').addClass('d-none');
		col.find('div.permissionsText').removeClass('d-none');
	});

	$('button[data-user-action]').click(function () {
		var action = $(this).data('user-action');
		var user = $(this).data('user');
		var col = $(this).closest('td');
		var row = col.closest('tr');
		var value = col.find('span.value');
		var extra = $(this).data('extra') ? $(this).data('extra') : '';

		if ($(this).data('extra-prompt')) {
			var extra = prompt($(this).data('extra-prompt'));
		}

		$.ajax({
			url: "{{ url('/admin/users/action') }}/" + action + "/" + user,
			data: {'csrftoken': $('#csrftoken').val(), 'extra': extra},
			method: "POST",
		}).done(function(data) {
			if (data['error'] !== undefined) {
				alert('There was an error: ' + data['error']);
			} else if (data['response'] !== undefined) {
				if (data['response']['success'] !== undefined) {
					alert(data['response']['success']);
				} else {
					if (value.data('raw')) {
						var newVal = data['response'][value.data('field')];
						value.text(newVal);
					} else {
						var fieldVal = data['response'][value.data('field')];
						var newVal = (fieldVal === true || fieldVal == 'true') ? "Yes" : "No";
						var classVal = value.data('class-' + newVal.toLowerCase().trim());
						var classOldVal = value.data('class-' + value.text().toLowerCase().trim());

						value.text(newVal);
						value.removeClass(classOldVal);
						value.addClass(classVal);
					}

					if (action == "suspend" || action == "unsuspend") {
						var reasonfield = row.find('span.value[data-field=disabledreason]');
						reasonfield.text(data['response'][reasonfield.data('field')]);

						row.find('span[data-showsuspend]').each(function() {
							if ($(this).data('showsuspend') == newVal) {
								$(this).removeClass('d-none');
							} else {
								$(this).addClass('d-none');
							}
						});
					}

					if (action == "suspend" || action == "unsuspend" || action == "suspendreason") {
						var disabledreason = data['response']["disabledreason"];
						var reasonSpan = row.find('span[data-show-when-reason]');
						if (disabledreason == "" || disabledreason == undefined || disabledreason == null) {
							reasonSpan.addClass('d-none');
						} else {
							reasonSpan.removeClass('d-none');
						}
					}

					row.fadeOut(100).fadeIn(100);
				};
			}
		}).fail(function(data) {
			alert('There was an error: ' + data.responseText);
		});
	});


	$('button[data-action="deleteuser"]').click(function () {
		var user = $(this).data('id');
		var row = $(this).closest('tr');

		var okButton = $('#confirmDelete button[data-action="ok"]');
		okButton.removeClass("btn-success").addClass("btn-danger").text("Delete User");

		okButton.off('click').click(function () {
			$.ajax({
				url: "{{ url('/admin/users/delete') }}/" + user,
				data: {'csrftoken': $('#csrftoken').val()},
				method: "POST",
			}).done(function(data) {
				if (data['error'] !== undefined) {
					alert('There was an error: ' + data['error']);
				} else if (data['response'] !== undefined) {
					row.fadeOut(500, function(){ $(this).remove(); });
				}
			}).fail(function(data) {
				alert('There was an error: ' + data.responseText);
			});
		});

		$('#confirmDelete').modal('show');
	});

	$("#adduser").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
		rules: {
			password: {
				required: function(element) {
					return $('input:radio[name=registerUser]:checked').val() == "registerUserManual";
				},
				minlength: 6,
			},
			confirmpassword: {
				required: function(element) {
					return $('input:radio[name=registerUser]:checked').val() == "registerUserManual";
				},
				equalTo: "#password",
			},
			email: {
				required: true,
				email: true
			},
			realname: {
				required: true
			}
		},
	});

	$('input:radio[name=registerUser]').change(function () {
		var inputs = $('div.registerUserManual input[type=password]');
		if ($('input:radio[name=registerUser]:checked').val() == "registerUserManual") {
			inputs.prop("disabled", false);
		} else {
			inputs.prop("disabled", true);
			inputs.val("");
			inputs.removeClass('is-invalid');
			inputs.closest('.form-group').find('.invalid-feedback').remove();
		}
	});

	$('a[data-action="addNewUser"]').click(function () {
		var okButton = $('#createUser button[data-action="ok"]');
		okButton.text("Create");

		okButton.off('click').click(function () {
			if ($("#adduser").valid()) {
				$("#adduser").submit();
				$('#createUser').modal('hide');
			}
		});

		$('div.registerUserManual input[type=password]').prop("disabled", true);
		$("#adduser")[0].reset();

		var cancelButton = $('#createUser button[data-action="cancel"]');
		cancelButton.off('click').click(function () {
			$("#adduser").validate().resetForm();
		});

		$('#createUser').modal('show');

		return false;
	});
});
