$('button[data-action="edit"]').click(function () {
	var row = $(this).parent('td').parent('tr');
	var recordid = row.data('id');

	if ($(this).data('action') == "edit") {
		setEditable(row, recordid);

		$(this).data('action', 'cancel');
		$(this).html('Cancel');
	} else if ($(this).data('action') == "cancel") {
		cancelEdit(row);

		$(this).data('action', 'edit');
		$(this).html('Edit');
	}

});

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

function setEditable(row, recordid) {
	var name = row.find('td.name');
	var type = row.find('td.type');
	var priority = row.find('td.priority');
	var content = row.find('td.content');
	var ttl = row.find('td.ttl');

	name.html('<input type="text" class="form-control form-control-sm" name="record[' + recordid + '][name]" value="' + name.data('value') + '">');
	priority.html('<input type="text" class="form-control form-control-sm" name="record[' + recordid + '][priority]" value="' + priority.data('value') + '">');
	content.html('<input type="text" class="form-control form-control-sm" name="record[' + recordid + '][content]" value="' + content.data('value') + '">');
	ttl.html('<input type="text" class="form-control form-control-sm" name="record[' + recordid + '][ttl]" value="' + ttl.data('value') + '">');


	var select = '';
	select += '<select class="form-control form-control-sm" name="record[' + recordid + '][type]">';
	$.each(recordtypes, function(key, value) {
		select += '	<option ' + (type.data('value') == key ? 'selected' : '') + ' value="' + key + '">' + value + '</option>';
	});
	select += '</select>';

	type.html(select);

	row.addClass('form-group');
}

function cancelEdit(row) {
	var name = row.find('td.name');
	var type = row.find('td.type');
	var priority = row.find('td.priority');
	var content = row.find('td.content');
	var ttl = row.find('td.ttl');

	name.html(name.data('value'));
	type.html(type.data('value'));
	priority.html(priority.data('value'));
	content.html(content.data('value'));
	ttl.html(ttl.data('value'));
}

$('button[data-action="delete"]').click(function () {
	var row = $(this).parent('td').parent('tr');

	cancelEdit(row);
	row.find('button[data-action="edit"]').data('action', 'edit');
	row.find('button[data-action="edit"]').html('Edit');

	if ($(this).data('action') == "delete") {
		row.find('button[data-action="edit"]').hide();

		row.addClass('deleted');
		$(this).data('action', 'undelete');
		$(this).html('Undelete');
	} else if ($(this).data('action') == "undelete") {
		row.find('button[data-action="edit"]').show();

		row.removeClass('deleted');
		$(this).data('action', 'delete');
		$(this).html('Delete');
	}
});

$('button[data-action="add"]').click(function () {

	var table = $('table#records');

	var row = '';
	row += '<tr data-id="" class="new">';
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

	setEditable(row, '');

	row.find('button[data-action="delete"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		row.remove();
	});
});
