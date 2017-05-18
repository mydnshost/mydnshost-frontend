$('button[data-action="saveuser"]').click(function () {
	$('#profileinfo').submit();
});

$('button[data-action="edituser"]').click(function () {
	if ($(this).data('action') == "edituser") {
		setUserEditable();

		$(this).data('action', 'cancel');
		$(this).html('Cancel');
	} else if ($(this).data('action') == "cancel") {
		cancelEditUser();

		$(this).data('action', 'edituser');
		$(this).html('Edit user details');
	}

	return false;
});

function setUserEditable() {
	$('#usercontrols a').addClass('hidden');
	$('#usercontrols button[data-action="saveuser"]').removeClass('hidden');

	$('table#profileinfo td[data-name]').each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');
		var fieldType = field.data('type') == undefined ? 'text' : field.data('type');

		field.html('<input type="' + fieldType + '" class="form-control form-control-sm" id="' + key + '" name="' + key + '" value="' + escapeHtml(value) + '">');
	});
	$('table#profileinfo tr[data-hidden]').show();

}

function cancelEditUser() {
	$('#usercontrols a').removeClass('hidden');
	$('#usercontrols button[data-action="saveuser"]').addClass('hidden');

	$('table#profileinfo td[data-name]').each(function (index) {
		var field = $(this);
		field.text(field.data('value'));
		field.data('edited-value', null);
	});
	$('table#profileinfo tr[data-hidden]').hide();
}

$('button[data-action="saveuser"]').click(function () {
	$('#editprofile').submit();
});

$("#editprofile").validate({
	highlight: function(element) {
		$(element).closest('tr').addClass('has-danger');
		$(element).closest('tr').find('th').addClass('col-form-label');
	},
	unhighlight: function(element) {
		$(element).closest('tr').removeClass('has-danger');
		$(element).closest('tr').find('th').removeClass('col-form-label');
	},
	errorClass: 'form-control-feedback',
	rules: {
		password: {
			minlength: 6,
		},
		confirmpassword: {
			equalTo: "#password",
		},
		email: {
			email: true
		}
	},
});


$('button[data-action="editkey"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var recordid = row.data('value');

	if ($(this).data('action') == "editkey") {
		setKeyEditable(row, recordid);

		$(this).data('action', 'cancel');
		$(this).html('Cancel');
		$(this).removeClass('btn-success');
		$(this).addClass('btn-warning');
	} else if ($(this).data('action') == "cancel") {
		cancelEditKey(row);

		$(this).data('action', 'editkey');
		$(this).html('Edit');
		$(this).addClass('btn-success');
		$(this).removeClass('btn-warning');
	}

	return false;
});

$('button[data-action="savekey"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var saveform = row.find('form.editform');

	$('input[type="text"]', row).each(function (index) {
		saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
	});
	$('input[type="radio"]:checked', row).each(function (index) {
		saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
	});

	// TODO: Do this with AJAX.
	saveform.submit();
});

$('button[data-action="deletekey"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var deleteform = row.find('form.deleteform');

	var okButton = $('#confirmDelete button[data-action="ok"]');
	okButton.removeClass("btn-success").addClass("btn-danger").text("Delete API Key");

	okButton.off('click').click(function () {
		// TODO: Do this with AJAX.
		deleteform.submit();
	});

	$('#confirmDelete').modal({'backdrop': 'static'});
});

var newAPIKeyCount = 0;
function setKeyEditable(row, recordid) {
	row.find('button[data-action="deletekey"]').hide();
	row.find('button[data-action="savekey"]').show();

	var fieldName = 'key';
	if (recordid == undefined) {
		var fieldName = 'newkey';
		recordid = newAPIKeyCount++;
	}

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');
		var fieldType = field.data('type') == undefined ? 'text' : field.data('type');

		field.html('<input type="' + fieldType + '" class="form-control form-control-sm" name="' + fieldName + '[' + recordid + '][' + key + ']" value="' + escapeHtml(value) + '">');
	});

	editableYesNo(row, fieldName, recordid);
}

function cancelEditKey(row) {
	row.find('button[data-action="deletekey"]').show();
	row.find('button[data-action="savekey"]').hide();

	$('td[data-radio]', row).each(function (index) {
		var field = $(this);

		if (field.data('value') == "Yes") {
			field.html('<span class="badge badge-success">' + escapeHtml(field.data('value')) + '</span>');
		} else {
			field.html('<span class="badge badge-danger">' + escapeHtml(field.data('value')) + '</span>');
		}
		field.data('edited-value', null);
	});

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		field.html(escapeHtml(field.data('value')));
		field.data('edited-value', null);
	});
}

function editableYesNo(row, fieldName, recordid) {
	$('td[data-radio]', row).each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');

		var radioButtons = '';
		radioButtons += '<div class="btn-group" data-toggle="buttons">';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-success" data-inactive="btn-outline-success" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + fieldName + '[' + recordid + '][' + key + ']" value="true" autocomplete="off" ' + (value == "Yes" ? 'checked' : '') + '>Yes';
		radioButtons += '  </label>';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-danger" data-inactive="btn-outline-danger" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + fieldName + '[' + recordid + '][' + key + ']" value="false" autocomplete="off" ' + (value == "No" ? 'checked' : '') + '>No';
		radioButtons += '  </label>';
		radioButtons += '</div>';
		radioButtons = $(radioButtons);
		field.html(radioButtons);

		// Change state.
		$('input[type=radio]', radioButtons).change(function() {
			var container = $(this).parent('label').parent('div');

			$('label[data-toggle-class]', container).each(function() {
				if ($(this).find('input[type=radio]:checked').length == 0) {
					$(this).removeClass($(this).attr('data-active'));
					$(this).addClass($(this).attr('data-inactive'));
				} else {
					$(this).addClass($(this).attr('data-active'));
					$(this).removeClass($(this).attr('data-inactive'));
				}
			});
		});

		// Set initial state
		$('label[data-toggle-class]', radioButtons).each(function() {
			if ($(this).find('input[type=radio]:checked').length == 0) {
				$(this).removeClass($(this).attr('data-active'));
				$(this).addClass($(this).attr('data-inactive'));
			} else {
				$(this).addClass($(this).attr('data-active'));
				$(this).removeClass($(this).attr('data-inactive'));
			}
		});
	});

}


$("#addkeyform").validate({
	highlight: function(element) {
		$(element).closest('.form-group').addClass('has-danger');
	},
	unhighlight: function(element) {
		$(element).closest('.form-group').removeClass('has-danger');
	},
	errorClass: 'form-control-feedback',
	errorPlacement: function () { },
	rules: {
		description: {
			required: true
		}
	},
});



$('button[data-action="edit2fakey"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var recordid = row.data('value');

	if ($(this).data('action') == "edit2fakey") {
		set2FAKeyEditable(row, recordid);

		$(this).data('action', 'cancel');
		$(this).html('Cancel');
		$(this).removeClass('btn-success');
		$(this).addClass('btn-warning');
	} else if ($(this).data('action') == "cancel") {
		cancelEdit2FAKey(row);

		$(this).data('action', 'edit2fakey');
		$(this).html('Edit');
		$(this).addClass('btn-success');
		$(this).removeClass('btn-warning');
	}

	return false;
});

$('button[data-action="save2fakey"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var saveform = row.find('form.editform');

	$('input[type="text"]', row).each(function (index) {
		saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
	});
	$('input[type="radio"]:checked', row).each(function (index) {
		saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
	});

	// TODO: Do this with AJAX.
	saveform.submit();
});

$('button[data-action="delete2fakey"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var deleteform = row.find('form.deleteform');

	var okButton = $('#confirmDelete2FA button[data-action="ok"]');
	okButton.removeClass("btn-success").addClass("btn-danger").text("Delete 2FA Key");

	okButton.off('click').click(function () {
		// TODO: Do this with AJAX.
		deleteform.submit();
	});

	$('#confirmDelete2FA').modal({'backdrop': 'static'});
});

var new2FAKeyCount = 0;
function set2FAKeyEditable(row, recordid) {
	row.find('button[data-action="delete2fakey"]').hide();
	row.find('button[data-action="save2fakey"]').show();

	var fieldName = 'key';
	if (recordid == undefined) {
		var fieldName = 'newkey';
		recordid = newAPIKeyCount++;
	}

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');
		var fieldType = field.data('type') == undefined ? 'text' : field.data('type');

		field.html('<input type="' + fieldType + '" class="form-control form-control-sm" name="' + fieldName + '[' + recordid + '][' + key + ']" value="' + escapeHtml(value) + '">');
	});
}

function cancelEdit2FAKey(row) {
	row.find('button[data-action="delete2fakey"]').show();
	row.find('button[data-action="save2fakey"]').hide();

	$('td[data-radio]', row).each(function (index) {
		var field = $(this);

		if (field.data('value') == "Yes") {
			field.html('<span class="badge badge-success">' + escapeHtml(field.data('value')) + '</span>');
		} else {
			field.html('<span class="badge badge-danger">' + escapeHtml(field.data('value')) + '</span>');
		}
		field.data('edited-value', null);
	});

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		field.html(escapeHtml(field.data('value')));
		field.data('edited-value', null);
	});
}

$("#add2faform").validate({
	highlight: function(element) {
		$(element).closest('.form-group').addClass('has-danger');
	},
	unhighlight: function(element) {
		$(element).closest('.form-group').removeClass('has-danger');
	},
	errorClass: 'form-control-feedback',
	errorPlacement: function () { },
	rules: {
		description: {
			required: true
		}
	},
});
