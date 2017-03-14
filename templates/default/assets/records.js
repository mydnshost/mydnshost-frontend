var recordtypes = {
  "A": "A Record",
  "AAAA": "AAAA Record",
  "MX": "MX",
  "CNAME": "CNAME",
  "TXT": "Text",
  "NS": "Nameserver",
  "PTR": "PTR Record",
  "SRV": "Service Record"
};

var newRecordCount = 0;

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
	row += '		<button type="button" class="btn btn-sm btn-danger" data-action="delete" role="button">Delete</button>';
	row += '	</td>';
	row += '</tr>';

	row = $(row);
	table.append(row);

	setEditable(row, undefined);

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

		field.html('<input type="text" class="form-control form-control-sm" name="' + fieldName + '[' + recordid + '][' + key + ']" value="' + value + '">');
	});

	var typeValue = (type.data('edited-value') == undefined || type.data('edited-value') == null) ? type.data('value') : type.data('edited-value');
	var select = '';
	select += '<select class="form-control form-control-sm" name="' + fieldName + '[' + recordid + '][type]">';
	$.each(recordtypes, function(key, value) {
		select += '	<option ' + (typeValue == key ? 'selected' : '') + ' value="' + key + '">' + value + '</option>';
	});
	select += '</select>';
	type.html(select);

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
}

function cancelEdit(row) {
	var fields = {"name": row.find('td.name'),
	              "type": row.find('td.type'),
	              "priority": row.find('td.priority'),
	              "content": row.find('td.content'),
	              "ttl": row.find('td.ttl')
	             };

    $.each(fields, function(key, field) {
		field.text(field.data('value'));
		field.data('edited-value', null);
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
