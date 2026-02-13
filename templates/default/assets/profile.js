$(function() {
	$('span[data-hiddenText]').click(function () {
		$(this).text($(this).attr('data-hiddenText'));
	});

	$('button[data-action="saveuser"]').click(function () {
		$('#profileinfo').submit();
	});

	$('button[data-action="edituser"]').click(function () {
		if ($(this).data('action') == "edituser") {
			setUserEditable();

			$(this).data('action', 'cancel');
			$(this).html('Cancel');
			$(this).removeClass('btn-primary');
			$(this).addClass('btn-warning');
		} else if ($(this).data('action') == "cancel") {
			cancelEditUser();

			$(this).data('action', 'edituser');
			$(this).html('Edit user details');
			$(this).addClass('btn-primary');
			$(this).removeClass('btn-warning');
		}

		return false;
	});

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
		var nextRow = row.next();
		var recordid = row.data('value');

		if ($(this).data('action') == "editkey") {
			setKeyEditable(row, recordid);
			setKeyEditable(nextRow, recordid);

			$(this).data('action', 'cancel');
			$(this).html('Cancel');
			$(this).removeClass('btn-success');
			$(this).addClass('btn-warning');
		} else if ($(this).data('action') == "cancel") {
			cancelEditKey(row);
			cancelEditKey(nextRow);

			$(this).data('action', 'editkey');
			$(this).html('Edit');
			$(this).addClass('btn-success');
			$(this).removeClass('btn-warning');
		}

		return false;
	});

	$('button[data-action="savekey"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var nextRow = row.next();
		var saveform = row.find('form.editform');

		$('input[type="text"]', row).each(function (index) {
			saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
		});
		$('input[type="radio"]:checked', row).each(function (index) {
			saveform.append('<input type="hidden" name="' + $(this).attr('name') + '" value="' + escapeHtml($(this).val()) + '">');
		});

		$('input[type="text"]', nextRow).each(function (index) {
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

		$('#confirmDelete').modal({'backdrop': 'static'}).modal('show');
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

		$('#confirmDelete2FA').modal({'backdrop': 'static'}).modal('show');
	});

	$('#add2faform select[name="type"]').change(setSecretVisibility);
	setSecretVisibility();

	function setSecretVisibility() {
		if ($('#add2faform select[name="type"]').find(':selected')[0].hasAttribute('data-need')) {
			var need = $('#add2faform select[name="type"]').find(':selected')[0].getAttribute('data-need');
			$('#add2faform input[data-provide="' + need + '"]').show();

			$('#add2faform input[data-provide][data-provide!="' + need + '"]').val("");
			$('#add2faform input[data-provide][data-provide!="' + need + '"]').hide();
		} else {
			$('#add2faform input[data-provide]').val("");
			$('#add2faform input[data-provide]').hide();
		}
	};

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
			},
			secret: {
				required: function() {
					var e = $('#add2faform select[name="type"]').find(':selected')[0];
					return e.hasAttribute('data-need') && e.getAttribute('data-need') == 'secret';
				}
			},
			countrycode: {
				required: function() {
					var e = $('#add2faform select[name="type"]').find(':selected')[0];
					return e.hasAttribute('data-need') && e.getAttribute('data-need') == 'phone';
				}
			},
			phone: {
				required: function() {
					var e = $('#add2faform select[name="type"]').find(':selected')[0];
					return e.hasAttribute('data-need') && e.getAttribute('data-need') == 'phone';
				}
			}
		},
	});

	$('button[data-action="delete2fadevice"]').click(function () {
		var row = $(this).parent('td').parent('tr');
		var deleteform = row.find('form.deleteform');

		var okButton = $('#confirmDelete2FADevice button[data-action="ok"]');
		okButton.removeClass("btn-success").addClass("btn-danger").text("Delete Device");

		okButton.off('click').click(function () {
			// TODO: Do this with AJAX.
			deleteform.submit();
		});

		$('#confirmDelete2FADevice').modal({'backdrop': 'static'}).modal('show');
	});
});

var optionsValues = {};

optionsValues['domain_defaultpage'] = {
  "details": "Domain Details",
  "records": "Domain Records"
};

optionsValues['sidebar_layout'] = {
  "access": "Access Level",
  "labels": "Label View"
};

{% set themeInfo = getThemeInformation() %}
optionsValues['sitetheme'] = {
	"__groupLabels": {{ themeInfo.groups|json_encode|raw }},
	{% for themeid, theme in themeInfo.themes %}
		{% if not theme.hidden|default(false) or sitetheme == themeid %}
			{% set label = (theme.hidden|default(false) ? '[HIDDEN] ' : '') ~ (theme.deprecated|default(false) ? '[DEPRECATED] ' : '') ~ theme.name ~ (theme.default|default(false) ? ' [Default]' : '') %}
			{% set groups = theme.groups|default('') %}
			{% if groups is not iterable %}{% set groups = [groups] %}{% endif %}
			"{{ themeid }}": {"label": "{{ label }}", "groups": {{ groups|json_encode|raw }}},
		{% endif %}
	{% endfor %}
};

optionsValues['avatar'] = {
  "gravatar": "Use Gravatar",
  "none": "No Avatar"
};

function setUserEditable() {
	$('#usercontrols a').addClass('hidden');
	$('#usercontrols button[data-action="saveuser"]').removeClass('hidden');

	$('table#profileinfo td[data-name]').each(function (index) {
		var field = $(this);
		var value = (field.data('edited-value') == undefined || field.data('edited-value') == null) ? field.data('value') : field.data('edited-value');
		var key = field.data('name');
		var fieldType = field.data('type') == undefined ? 'text' : field.data('type');

		if (field.data('rich') != undefined) {
			field.data('rich', field.html());
		}

		if (fieldType == 'option') {
			var options = optionsValues[key];
			var select = '<select class="form-control form-control-sm" name="' + key + '">';

			// Detect rich format (value is object with .label) vs simple (value is string)
			var isRich = false;
			$.each(options, function(k, v) { isRich = (typeof v === 'object'); return false; });

			if (isRich) {
				var groupLabels = options['__groupLabels'] || {};
				var groups = {};
				var groupOrder = [];
				$.each(options, function(optionkey, optiondata) {
					if (optionkey === '__groupLabels') return;
					$.each(optiondata.groups || [''], function(i, g) {
						if (!(g in groups)) { groups[g] = []; groupOrder.push(g); }
						groups[g].push('<option ' + (value == optionkey ? 'selected' : '') + ' value="' + optionkey + '">' + escapeHtml(optiondata.label) + '</option>');
					});
				});
				// Emit ungrouped options first
				if ('' in groups) {
					select += groups[''].join('');
				}
				$.each(groupOrder, function(i, g) {
					if (g === '') return;
					var displayLabel = groupLabels[g] || g;
					select += '<optgroup label="' + escapeHtml(displayLabel) + '">' + groups[g].join('') + '</optgroup>';
				});
			} else {
				$.each(options, function(optionkey, optionvalue) {
					select += '<option ' + (value == optionkey ? 'selected' : '') + ' value="' + optionkey + '">' + optionvalue + '</option>';
				});
			}

			select += '</select>';
			field.html(select);
		} else {
			field.html('<input type="' + fieldType + '" class="form-control form-control-sm" id="' + key + '" name="' + key + '" value="' + escapeHtml(value) + '">');
		}
	});
	$('table#profileinfo tr[data-hidden]').show();

}

function cancelEditUser() {
	$('#usercontrols a').removeClass('hidden');
	$('#usercontrols button[data-action="saveuser"]').addClass('hidden');

	$('table#profileinfo td[data-name]').each(function (index) {
		var field = $(this);
		if (field.data('rich') != undefined) {
			field.html(field.data('rich'));
		} else {
			field.text(field.data('value'));
		}
		field.data('edited-value', null);
	});
	$('table#profileinfo tr[data-hidden]').hide();
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

	editableYesNo(row, fieldName, recordid);
}

function cancelEditKey(row) {
	row.find('button[data-action="deletekey"]').show();
	row.find('button[data-action="savekey"]').hide();

	$('td[data-radio]', row).each(function (index) {
		var field = $(this);

		if (field.data('value') == "Yes") {
			field.html('<span class="badge bg-success">' + escapeHtml(field.data('value')) + '</span>');
		} else {
			field.html('<span class="badge bg-danger">' + escapeHtml(field.data('value')) + '</span>');
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
		radioButtons += '<div class="btn-group" data-bs-toggle="buttons">';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-success" data-inactive="btn-outline-success" data-toggle-class>';
		radioButtons += '    <input type="radio" class="btn-check" name="' + fieldName + '[' + recordid + '][' + key + ']" value="true" autocomplete="off" ' + (value == "Yes" ? 'checked' : '') + '>Yes';
		radioButtons += '  </label>';
		radioButtons += '  <label class="btn btn-sm" data-active="btn-danger" data-inactive="btn-outline-danger" data-toggle-class>';
		radioButtons += '    <input type="radio" class="btn-check" name="' + fieldName + '[' + recordid + '][' + key + ']" value="false" autocomplete="off" ' + (value == "No" ? 'checked' : '') + '>No';
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
			field.html('<span class="badge bg-success">' + escapeHtml(field.data('value')) + '</span>');
		} else {
			field.html('<span class="badge bg-danger">' + escapeHtml(field.data('value')) + '</span>');
		}
		field.data('edited-value', null);
	});

	$('td[data-text]', row).each(function (index) {
		var field = $(this);
		field.html(escapeHtml(field.data('value')));
		field.data('edited-value', null);
	});
}
