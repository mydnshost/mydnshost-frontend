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
}
