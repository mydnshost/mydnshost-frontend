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
	} else if ($(this).data('action') == "cancel") {
		cancelEdit(row);

		$(this).data('action', 'edit');
		$(this).html('Edit');
		row.removeClass('edited');
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
	row += '	<td class="actions" data-value="">';
	row += '		<button class="btn btn-sm btn-danger" data-action="delete" role="button">Delete</button>';
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
		field.html(field.data('value'));
		field.data('edited-value', null);
	});

	return false;
}
