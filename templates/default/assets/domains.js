$('button[data-action="savesoa"]').click(function () {
	$('#editsoaform').submit();
});

$('button[data-action="editsoa"]').click(function () {
	if ($(this).data('action') == "editsoa") {
		setSOAEditable();

		$(this).data('action', 'cancel');
		$(this).html('Cancel');
	} else if ($(this).data('action') == "cancel") {
		cancelEditSOA();

		$(this).data('action', 'editsoa');
		$(this).html('Edit SOA');
	}

	return false;
});

function setSOAEditable() {
	$('#domaincontrols a').addClass('hidden');
	$('#domaincontrols button[data-action="savesoa"]').removeClass('hidden');

	$('table#soainfo td[data-name]').each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');

		field.html('<input type="text" class="form-control form-control-sm" name="soa[' + key + ']" value="' + value + '">');
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
		field.html(field.data('value'));
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

$('button[data-action="editaccess"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var person = row.find('td.who').data('value');

	if ($(this).data('action') == "editaccess") {
		setEditAccess(row, person);

		$(this).data('action', 'cancel');
		$(this).html('Cancel');
	} else if ($(this).data('action') == "cancel") {
		cancelEditAccess(row);

		$(this).data('action', 'editaccess');
		$(this).html('Edit');
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


$('tr[data-edited="true"]').each(function (index) {
	$(this).find('button[data-action="editaccess"]').click();
});

$('button[data-action="addaccess"]').click(function () {
	var table = $('table#accessinfo');

	var row = '';
	row += '<tr class="new">';
	row += '	<td class="who" data-value=""></td>';
	row += '	<td class="access" data-value="read"></td>';
	row += '	<td class="actions" data-value="">';
	row += '		<button type="button" class="btn btn-sm btn-danger" data-action="deleteaccess" role="button">Cancel</button>';
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
		whoField.html('<input type="text" class="form-control form-control-sm" name="' + fieldName + '[' + fieldID + '][who]" value="' + whoValue + '">');
	}

	var accessValue = (access.data('edited-value') == undefined || access.data('edited-value') == null) ? access.data('value') : access.data('edited-value');

	var select = '';
	select += '<select class="form-control form-control-sm" name="' + fieldName + '[' + fieldID + '][level]">';
	$.each(accessLevels, function(key, value) {
		select += '	<option ' + (accessValue == value ? 'selected' : '') + ' value="' + value + '">' + value + '</option>';
	});
	select += '</select>';
	access.html(select);

	row.addClass('form-group');
}
