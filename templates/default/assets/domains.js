$(function() {
	$('button[data-action="dnssec-more"]').click(function () {
		if ($('#dnssec-more').is(":visible")) {
			$(this).text('More...');
			$('#dnssec-more').hide();
		} else {
			$(this).text('Less...');
			$('#dnssec-more').show();
		}
	});

	$('button[data-action="savesoa"]').click(function () {
		$('#editsoaform').submit();
	});

	$('button[data-action="editsoa"]').click(function () {
		if ($(this).data('action') == "editsoa") {
			setSOAEditable();

			$(this).data('action', 'cancel');
			$(this).html('Cancel');
			$(this).removeClass('btn-primary');
			$(this).addClass('btn-warning');
		} else if ($(this).data('action') == "cancel") {
			cancelEditSOA();

			$(this).data('action', 'editsoa');
			$(this).html('Edit Domain Info');
			$(this).addClass('btn-primary');
			$(this).removeClass('btn-warning');
		}

		return false;
	});

	$('button[data-action="editaccess"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var person = row.find('td.who').data('value');

		if ($(this).data('action') == "editaccess") {
			setEditAccess(row, person);

			$(this).data('action', 'cancel');
			$(this).html('Cancel');
			$(this).removeClass('btn-success');
			$(this).addClass('btn-warning');
		} else if ($(this).data('action') == "cancel") {
			cancelEditAccess(row);

			$(this).data('action', 'editaccess');
			$(this).html('Edit');
			$(this).addClass('btn-success');
			$(this).removeClass('btn-warning');
		}

		// If this is a hacky edit button, remove it.
		if (row.hasClass("new")) {
			$(this).remove();
		}
		return false;
	});

	$('button[data-action="deleteaccess"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		row.remove();
		// Don't submit the form.
		return false;
	});

	$('button[data-action="addaccess"]').click(function () {
		var table = $('table#accessinfo');

		var row = '';
		row += '<tr class="new">';
		row += '	<td class="who" data-value=""></td>';
		row += '	<td class="access" data-value="read"></td>';
		row += '	<td class="actions" data-value="">';
		row += '		<button type="button" class="btn btn-sm btn-warning" data-action="deleteaccess" role="button">Cancel</button>';
		row += '	</td>';
		row += '</tr>';

		row = $(row);
		table.append(row);

		setEditAccess(row, undefined);

		row.find('button[data-action="deleteaccess"]').click(function () {
			var row = $(this).parent('td').parent('tr');
			row.remove();
			// Don't submit the form.
			return false;
		});

		// Don't submit the form.
		return false;
	});

	$("#editaccess").validate({
		highlight: function(element) {
			$(element).closest('td').addClass('has-danger');
		},
		unhighlight: function(element) {
			$(element).closest('td').removeClass('has-danger');
		},
		errorClass: 'form-control-feedback'
	});


	$('tr[data-edited="true"]').each(function (index) {
		$(this).find('button[data-action="editaccess"]').click();
	});

	$('span[data-hiddenText]').click(function () {
		$(this).text($(this).attr('data-hiddenText'));
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
		var saveform = row.find('form.editkeyform');

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
		var deleteform = row.find('form.deletekeyform');

		var okButton = $('#confirmDeleteKey button[data-action="ok"]');
		okButton.removeClass("btn-success").addClass("btn-danger").text("Delete Domain Key");

		okButton.off('click').click(function () {
			// TODO: Do this with AJAX.
			deleteform.submit();
		});

		$('#confirmDeleteKey').modal({'backdrop': 'static'});
	});

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

	$('button[data-action="edithook"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var recordid = row.data('value');

		if ($(this).data('action') == "edithook") {
			setHookEditable(row, recordid);

			$(this).data('action', 'cancel');
			$(this).html('Cancel');
			$(this).removeClass('btn-success');
			$(this).addClass('btn-warning');
		} else if ($(this).data('action') == "cancel") {
			cancelEditHook(row);

			$(this).data('action', 'edithook');
			$(this).html('Edit');
			$(this).addClass('btn-success');
			$(this).removeClass('btn-warning');
		}

		return false;
	});

	$('button[data-action="savehook"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var saveform = row.find('form.edithookform');

		$('input[type="text"]', row).each(function (index) {
			saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
		});
		$('input[type="radio"]:checked', row).each(function (index) {
			saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
		});

		// TODO: Do this with AJAX.
		saveform.submit();
	});

	$('button[data-action="deletehook"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var deleteform = row.find('form.deletehookform');

		var okButton = $('#confirmDeleteHook button[data-action="ok"]');
		okButton.removeClass("btn-success").addClass("btn-danger").text("Delete Domain Hook");

		okButton.off('click').click(function () {
			// TODO: Do this with AJAX.
			deleteform.submit();
		});

		$('#confirmDeleteHook').modal({'backdrop': 'static'});
	});

	$("#addhookform").validate({
		highlight: function(element) {
			$(element).closest('.form-group').addClass('has-danger');
		},
		unhighlight: function(element) {
			$(element).closest('.form-group').removeClass('has-danger');
		},
		errorClass: 'form-control-feedback',
		errorPlacement: function () { },
		rules: {
			url: {
				required: true
			}
		},
	});
});

var optionsValues = {};

// TODO: This should come via an ajax call or something, not as part of this js file.
optionsValues['aliasof'] = {
  "": "None",
  {% for domain,access in userdomains %}
    {% if access == "owner" %}
      "{{ domain }}": "{{ domain }}",
    {% endif %}
  {% endfor %}
};

function setSOAEditable() {
	$('#domaincontrols a').addClass('hidden');
	$('#domaincontrols button[data-action="savesoa"]').removeClass('hidden');

	$('table#soainfo td[data-name]').each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');
		var isSOA = field.data('soa') !== undefined;
		var includeCurrent = field.data('include-current') !== undefined;
		var fieldType = field.data('type') == undefined ? 'text' : field.data('type');

		if (field.data('rich') != undefined) {
			field.data('rich', field.html());
		}

		if (fieldType == 'option') {
			var select = '';
			select += '<select class="form-control form-control-sm" name="' + key + '">';
			foundValue = false;
			$.each(optionsValues[key], function(optionkey, optionvalue) {
				foundValue |= (value == optionkey);
				select += '	<option ' + (value == optionkey ? 'selected' : '') + ' value="' + optionkey + '">' + optionvalue + '</option>';
			});
			if (includeCurrent && !foundValue) {
				select += '	<option selected value="' + value + '">' + value + '</option>';
			}
			select += '</select>';
			field.html(select);
		} else if (fieldType == 'textarea') {
			field.html('<textarea class="form-control form-control-sm" name="' + key + '">' + escapeHtml(value) + '</textarea>');
		} else {
			if (isSOA) {
				field.html('<input type="text" class="form-control form-control-sm" name="soa[' + key + ']" value="' + escapeHtml(value) + '">');
			} else {
				field.html('<input type="text" class="form-control form-control-sm" name="' + key + '" value="' + escapeHtml(value) + '">');
			}
		}
	});

	$('table#soainfo td[data-radio]').each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('radio');

		var radioButtons = '';
		radioButtons += '<div class="btn-group" data-toggle="buttons">';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-danger" data-inactive="btn-outline-danger" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + key + '" value="true" autocomplete="off" ' + (value == "Yes" ? 'checked' : '') + '>Yes';
		radioButtons += '  </label>';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-success" data-inactive="btn-outline-success" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + key + '" value="false" autocomplete="off" ' + (value == "No" ? 'checked' : '') + '>No';
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

function cancelEditSOA() {
	$('#domaincontrols a').removeClass('hidden');
	$('#domaincontrols button[data-action="savesoa"]').addClass('hidden');

	$('table#soainfo td[data-name]').each(function (index) {
		var field = $(this);
		if (field.data('rich') != undefined) {
			field.html(field.data('rich'));
		} else {
			field.text(field.data('value'));
		}
		field.data('edited-value', null);
	});

	$('table#soainfo td[data-radio]').each(function (index) {
		var field = $(this);
		field.html(field.data('value'));
		field.data('edited-value', null);
	});

	var state = $('table#soainfo td.state');
	if (state.data('value') == "Yes") {
		state.html('<span class="badge badge-danger">' + $('<div/>').text(state.data('value')).html() + '</span>');
	} else {
		state.html('<span class="badge badge-success">' + $('<div/>').text(state.data('value')).html() + '</span>');
	}
	state.data('edited-value', null);
}

var accessLevels = ["owner", "admin", "write", "read", "none"];
var newAccessCount = 0;

function cancelEditAccess(row) {
	var fields = {"access": row.find('td.access')
	             };

    $.each(fields, function(key, field) {
		field.text(field.data('value'));
		field.data('edited-value', null);
	});

	row.tooltip('dispose');
	row.removeClass('error');

	return false;
}

function setEditAccess(row, who) {
	var access = row.find('td.access');
	var fieldName = (who == undefined) ? 'newAccess' : 'access';

	var fieldID = (who == undefined) ? newAccessCount++ : who;

	if (who == undefined) {
		var whoField = row.find('td.who');
		var whoValue = (whoField.data('edited-value') == undefined || whoField.data('edited-value') == null) ? whoField.data('value') : whoField.data('edited-value');
		whoField.html('<input type="text" class="form-control form-control-sm" name="' + fieldName + '[' + fieldID + '][who]" value="' + escapeHtml(whoValue) + '">');

		whoField.find('input').rules("add", {
			email: true,
			required: true
		});
	}

	var accessValue = (access.data('edited-value') == undefined || access.data('edited-value') == null) ? access.data('value') : access.data('edited-value');

	var select = '';
	select += '<select class="form-control form-control-sm" name="' + fieldName + '[' + fieldID + '][level]">';
	$.each(accessLevels, function(key, value) {
		select += '	<option ' + (accessValue == value ? 'selected' : '') + ' value="' + escapeHtml(value) + '">' + value + '</option>';
	});
	select += '</select>';
	access.html(select);

	row.addClass('form-group');
}


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

	editableYesNo(row, fieldName, recordid, false);
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

function editableYesNo(row, fieldName, recordid, inverse) {
	$('td[data-radio]', row).each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');

		var yesState = inverse ? 'danger' : 'success';
		var noState = inverse ? 'success' : 'danger';

		var radioButtons = '';
		radioButtons += '<div class="btn-group" data-toggle="buttons">';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-' + yesState + '" data-inactive="btn-outline-' + yesState + '" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + fieldName + '[' + recordid + '][' + key + ']" value="true" autocomplete="off" ' + (value == "Yes" ? 'checked' : '') + '>Yes';
		radioButtons += '  </label>';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-' + noState + '" data-inactive="btn-outline-' + noState + '" data-toggle-class>';
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


var newHookCount = 0;
function setHookEditable(row, recordid) {
	row.find('button[data-action="deletehook"]').hide();
	row.find('button[data-action="savehook"]').show();

	var fieldName = 'hook';
	if (recordid == undefined) {
		var fieldName = 'newhook';
		recordid = newHookCount++;
	}

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var hook = field.data('name');
		var fieldType = field.data('type') == undefined ? 'text' : field.data('type');

		field.html('<input type="' + fieldType + '" class="form-control form-control-sm" name="' + fieldName + '[' + recordid + '][' + hook + ']" value="' + escapeHtml(value) + '">');
	});

	editableYesNo(row, fieldName, recordid, true);
}

function cancelEditHook(row) {
	row.find('button[data-action="deletehook"]').show();
	row.find('button[data-action="savehook"]').hide();

	$('td[data-radio]', row).each(function (index) {
		var field = $(this);

		if (field.data('value') == "Yes") {
			field.html('<span class="badge badge-danger">' + escapeHtml(field.data('value')) + '</span>');
		} else {
			field.html('<span class="badge badge-success">' + escapeHtml(field.data('value')) + '</span>');
		}
		field.data('edited-value', null);
	});

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		field.html(escapeHtml(field.data('value')));
		field.data('edited-value', null);
	});
}
