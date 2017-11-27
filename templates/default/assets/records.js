var recordtypes = {
  "A": "A Record",
  "AAAA": "AAAA Record",
  "MX": "MX",
  "CNAME": "CNAME",
  "TXT": "Text",
  "NS": "Nameserver (NS)",
  "PTR": "PTR Record",
  "SRV": "Service Record (SRV)",
  "CAA": "Certification Authority Authorization (CAA)",
  "DS": "Delegation Signer (DS)",
  "SSHFP": "SSH Fingerprint (SSHFP)",
  "TLSA": "TLSA Record"
};

var newRecordCount = 0;

$(function() {
	$('button[data-action="edit"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var recordid = row.data('id');

		if ($(this).data('action') == "edit") {
			setEditable(row, recordid);

			$(this).data('action', 'cancel');
			$(this).html('Cancel');
			row.addClass('edited');
			$(this).removeClass('btn-success');
			$(this).addClass('btn-warning');
		} else if ($(this).data('action') == "cancel") {
			cancelEdit(row);

			$(this).data('action', 'edit');
			$(this).html('Edit');
			row.removeClass('edited');
			$(this).addClass('btn-success');
			$(this).removeClass('btn-warning');
		}

		// If this is a hacky edit button, remove it.
		if (row.hasClass("new")) {
			$(this).remove();
		}

		// Don't submit the form.
		return false;
	});

	$('button[data-action="delete"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var recordid = row.data('id');

		cancelEdit(row);
		row.find('button[data-action="edit"]').data('action', 'edit');
		row.find('button[data-action="edit"]').html('Edit');
		row.find('button[data-action="edit"]').addClass('btn-success');
		row.find('button[data-action="edit"]').removeClass('btn-warning');

		if ($(this).data('action') == "delete") {
			row.find('button[data-action="edit"]').hide();

			row.addClass('deleted');
			$(this).data('action', 'undelete');
			$(this).html('Undelete');
			$(row).find('td.actions').append('<input type="hidden" data-marker="delete" name="record[' + recordid + '][delete]" value="true">');
		} else if ($(this).data('action') == "undelete") {
			row.find('button[data-action="edit"]').show();
			row.removeClass('deleted');
			row.find('td.actions').find('input[data-marker="delete"]').remove();

			$(this).data('action', 'delete');
			$(this).html('Delete');
		}

		// Don't submit the form.
		return false;
	});

	$('button[data-action="deletenew"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		row.remove();

		// Don't submit the form.
		return false;
	});

	$('button[data-action="add"]').click(function () {

		var table = $('table#records');

		var row = '';
		row += '<tr class="new">';
		row += '	<td class="name" data-value=""></td>';
		row += '	<td class="type" data-value=""></td>';
		row += '	<td class="priority" data-value=""></td>';
		row += '	<td class="content" data-value=""></td>';
		row += '	<td class="ttl" data-value=""></td>';
		row += '	<td class="state" data-value="No"></td>';
		row += '	<td class="actions" data-value="">';
		row += '		<button type="button" class="btn btn-sm btn-warning" data-action="delete" role="button">Cancel</button>';
		row += '	</td>';
		row += '</tr>';

		row = $(row);
		table.append(row);

		setEditable(row, undefined);

		$('html,body').animate({
			scrollTop: row.offset().top
		});

		row.find('button[data-action="delete"]').click(function () {
			var row = $(this).parent('td').parent('tr');
			row.remove();
			// Don't submit the form.
			return false;
		});

		// Don't submit the form.
		return false;
	});

	$('button[data-action="reset"]').click(function () {
		$('tr.new').remove();
		$('tr.edited button[data-action="edit"]').click();
		$('tr.deleted button[data-action="delete"]').click();
		return false;
	});


	$('tr[data-edited="true"]').each(function (index) {
		$(this).find('button[data-action="edit"]').click();
	});

	$('tr[data-deleted="true"]').each(function (index) {
		$(this).find('button[data-action="delete"]').click();
	});

	$('tr[data-error-data]').each(function (index) {
		$(this).addClass("error");
		$(this).addClass("has-danger");

		$(this).tooltip({'title': $(this).data('error-data')});
	});

	$("#recordsform").validate({
		highlight: function(element) {
			$(element).closest('td').addClass('has-danger');
			$(element).closest('tr').addClass('error');
		},
		unhighlight: function(element) {
			$(element).closest('td').removeClass('has-danger');
			$(element).closest('td').tooltip('dispose');

			if ($(element).closest('tr').find('.has-danger').length == 0) {
				$(element).closest('tr').removeClass('error');
			}
		},
		errorPlacement: function (error, element) {
			$(element).closest('td').tooltip('dispose');
			$(element).closest('td').tooltip({'title': error});
		},
		errorClass: 'form-control-feedback',
	});

	$('button[type="submit"]').click(function () {
		$("#actionbuttons button").prop('disabled', true);

		var valid = $("#recordsform").valid();
		if (valid) {
			$("#recordsform").submit();
		} else {
			$("#actionbuttons button").prop('disabled', false);
		}

		return false;
	});
});

function setEditable(row, recordid) {
	var textFields = {"name": row.find('td.name'),
	                  "priority": row.find('td.priority'),
	                  "content": row.find('td.content'),
	                  "ttl": row.find('td.ttl')
	                  };

	var type = row.find('td.type');

	var fieldName = 'record';
	if (recordid == undefined) {
		var fieldName = 'newRecord';
		recordid = newRecordCount++;

		row.data('id', recordid);
	}

	$.each(textFields, function(key, field) {
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');

		field.html('<input type="text" class="form-control form-control-sm ' + key + '" name="' + fieldName + '[' + recordid + '][' + key + ']" value="' + escapeHtml(value) + '">');
	});

	var typeValue = (type.data('edited-value') == undefined || type.data('edited-value') == null) ? type.data('value') : type.data('edited-value');
	var select = '';
	select += '<select class="form-control form-control-sm" name="' + fieldName + '[' + recordid + '][type]">';
	$.each(recordtypes, function(key, value) {
		select += '	<option ' + (typeValue == key ? 'selected' : '') + ' value="' + key + '">' + value + '</option>';
	});
	select += '</select>';
	type.html(select);

	type.find('select').on('change', function() {
		$("#recordsform").valid();
	});

	$('td.state', row).each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('radio');

		var radioButtons = '';
		radioButtons += '<div class="btn-group" data-toggle="buttons">';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-danger" data-inactive="btn-outline-danger" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + fieldName + '[' + recordid + '][disabled]" value="true" autocomplete="off" ' + (value == "Yes" ? 'checked' : '') + '>Yes';
		radioButtons += '  </label>';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-success" data-inactive="btn-outline-success" data-toggle-class>';
		radioButtons += '    <input type="radio" name="' + fieldName + '[' + recordid + '][disabled]" value="false" autocomplete="off" ' + (value == "No" ? 'checked' : '') + '>No';
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

	row.addClass('form-group');

	$("#recordsform").valid();
}

function cancelEdit(row) {
	var fields = {"name": row.find('td.name'),
	              "type": row.find('td.type'),
	              "priority": row.find('td.priority'),
	              "content": row.find('td.content'),
	              "ttl": row.find('td.ttl')
	             };

	$.each(fields, function(key, field) {
		if (key == "name" && field.data('value') == '') {
			field.text('@');
		} else {
			field.text(field.data('value'));
		}

		field.data('edited-value', null);
		field.tooltip('dispose');
	});

	var state = row.find('td.state');

	if (state.data('value') == "Yes") {
		state.html('<span class="badge badge-danger">' + $('<div/>').text(state.data('value')).html() + '</span>');
	} else {
		state.html('<span class="badge badge-success">' + $('<div/>').text(state.data('value')).html() + '</span>');
	}
	state.data('edited-value', null);

	row.tooltip('dispose');
	row.removeClass('error');

	return false;
}


// Regexs from https://github.com/kvz/locutus/blob/c57a814de23460dad15a1c0802396f97120e391d/workbench/filter/filter_var.js
function isIPv4(input) {
	var ipv4 = /^(25[0-5]|2[0-4]\d|[01]?\d?\d)\.(25[0-5]|2[0-4]\d|[01]?\d?\d)\.(25[0-5]|2[0-4]\d|[01]?\d?\d)\.(25[0-5]|2[0-4]\d|[01]?\d?\d)$/;
	return ipv4.test(input);
}

function isIPv6(input) {
	var ipv6 = /^((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?$/i;
	return ipv6.test(input);
}

function isIPAddress(input) {
	return isIPv4(input) || isIPv6(input);
}

$.validator.addMethod("validateContent", function(value, element) {
	var record = $(element).closest('tr');
	var record_name = record.find('td.name input').val();
	var record_type = record.find('td.type option:selected').val();
	var record_content = record.find('td.content input').val();
	var record_ttl = record.find('td.ttl input').val();
	var record_priority = record.find('td.priority input').val();

	var error = false;
	var errorReason = '';

	if ($.inArray(record_type, ['A']) != -1 && !isIPv4(record_content)) {
		error = true;
		errorReason = 'Record must point at an IP Address';
	} else if ($.inArray(record_type, ['AAAA']) != -1 && !isIPv6(record_content)) {
		error = true;
		errorReason = 'Record must point at an IP Address';
	} else if ($.inArray(record_type, ['MX', 'CNAME', 'PTR']) != -1 && isIPAddress(record_content)) {
		error = true;
		errorReason = 'Record must point at a hostname not an IP addresses.';
	} else if (record_type == 'CNAME' && record_name == '') {
		error = true;
		errorReason = 'You can not have a CNAME for the root record of the domain.';
	} else if (record_type == 'SRV' && !record_content.match(/^[0-9]+ [0-9]+ .+$/)) {
		error = true;
		errorReason = 'SRV records should be formatted as \'<weight> <port> <address>\' eg \'1 443 somehost.com\'.';
	} else if (record_type == 'CAA' && !record_content.match(/^[0-9]+ [a-z]+ "[^\s]+"$/i)) {
		error = true;
		errorReason = 'CAA record content should have the format: <flag> <tag> "<value>"';
	} else if (record_type == 'SSHFP' && !record_content.match(/^[0-9]+ [0-9]+ [0-9A-F]+$/i)) {
		error = true;
		errorReason = 'SSHFP record content should have the format: <algorithm> <fingerprint type> <fingerprint>';
	} else if (record_type == 'TLSA' && !record_content.match(/^[0-9]+ [0-9]+ [0-9]+ [0-9A-F]+$/i)) {
		error = true;
		errorReason = 'TLSA record content should have the format: <usage> <selector> <matching type> <fingerprint>';
	} else if (record_type == 'DS' && !record_content.match(/^[0-9]+ [0-9]+ [0-9]+ [0-9A-F]+$/i)) {
		error = true;
		errorReason = 'DS record content should have the format: <keytag> <algorithm> <digesttype> <digest>';
	}

    $(element).data('validationErrorReason', errorReason.replace(/</g,'&lt;').replace(/>/g,'&gt;'));
    return !error;
}, function (params, element) {
	return $(element).data('validationErrorReason');
});

$.validator.addMethod("validatePriority", function(value, element) {
	var record = $(element).closest('tr');
	var record_name = record.find('td.name input').val();
	var record_type = record.find('td.type option:selected').val();
	var record_content = record.find('td.content input').val();
	var record_ttl = record.find('td.ttl input').val();
	var record_priority = record.find('td.priority input').val();

	var error = false;
	var errorReason = '';

	if ($.inArray(record_type, ['MX', 'SRV']) != -1 && record_priority == '') {
		error = true;
		errorReason = 'Priority is required for ' + record_type;
	}

    $(element).data('validationErrorReason', errorReason);
    return !error;
}, function (params, element) {
	return $(element).data('validationErrorReason');
});

$.validator.addClassRules('content', {
	validateContent: true,
	/* required: true, */
});

$.validator.addClassRules('priority', {
	validatePriority: true,
	digits: true,
});

$.validator.addClassRules('ttl', {
	digits: true,
});
