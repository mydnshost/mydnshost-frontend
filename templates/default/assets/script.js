$(function() {
	$('a[data-action="addUserDomain"]').click(function () {
		var okButton = $('#createUserDomain button[data-action="ok"]');
		okButton.text("Create");

		okButton.off('click').click(function () {
			if ($("#createUserDomainForm").valid()) {
				$("#createUserDomainForm").submit();
				$('#createUserDomain').modal('hide');
			}
		});

		var cancelButton = $('#createUserDomain button[data-action="cancel"]');
		cancelButton.off('click').click(function () {
			$("#createUserDomainForm").validate().resetForm();
		});

		$('#createUserDomain').modal({'backdrop': 'static'}).modal('show');
		return false;
	});

	$("#createUserDomainForm").validate({
		highlight: function(element) {
			$(element).closest('.form-group').addClass('has-danger');
		},
		unhighlight: function(element) {
			$(element).closest('.form-group').removeClass('has-danger');
		},
		errorClass: 'form-control-feedback',
		rules: {
			domainname: {
				required: true
			}
		},
	});

	$(".alert").alert()

	// Generic sidebar edit link handler
	$('a.sidebar-edit-link').click(function () {
		var editableType = $(this).data('editable-type');
		var editableKey = $(this).data('editable-key');

		if (editableType === 'label') {
			$('#oldLabelName').val(editableKey);
			$('#newLabelName').val(editableKey);

			var okButton = $('#renameLabelModal button[data-action="ok"]');
			okButton.prop('disabled', false).text('Rename');
			okButton.off('click').click(function () {
				var newLabel = $('#newLabelName').val().trim();
				if (newLabel === '' || newLabel === editableKey) {
					$('#renameLabelModal').modal('hide');
					return;
				}

				okButton.prop('disabled', true).text('Renaming...');

				$.ajax({
					url: '{{ url('/domains/renameLabel.json') }}',
					method: 'POST',
					data: {
						oldLabel: editableKey,
						newLabel: newLabel,
						csrftoken: '{{ csrftoken }}'
					},
					dataType: 'json',
					success: function (data) {
						$('#renameLabelModal').modal('hide');
						location.reload();
					},
					error: function () {
						okButton.prop('disabled', false).text('Rename');
						alert('Failed to rename label. Please try again.');
					}
				});
			});

			$('#renameLabelModal').modal({'backdrop': 'static'}).modal('show');
		}

		return false;
	});

	// Label edit mode toggle (drag-and-drop)
	$('button[data-action="toggleLabelEdit"]').click(function () {
		var sidebar = $('nav#sidebar');
		var isEditing = sidebar.hasClass('label-edit-mode');

		if (isEditing) {
			exitLabelEditMode(sidebar, $(this));
		} else {
			enterLabelEditMode(sidebar, $(this));
		}

		return false;
	});

	$("input[data-search-top]").on('input', function() {
		var value = $(this).val();
		var searchTop = $(this).data('search-top');

		if (value == "") {
			$(searchTop).find("[data-searchable-value]").show();
		} else {
			var match = new RegExp('^.*' + escapeRegExp(value) + '.*$', 'i');

			$(searchTop).find("[data-searchable-value]").each(function() {
				var show = false;

				for (val in $(this).data('searchable-value').split(" ")) {
					if ($(this).data('searchable-value').match(match)) {
						show = true;
						break;
					}
				}

				if (show) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});
		}
	});
});

function enterLabelEditMode(sidebar, toggleBtn) {
	sidebar.addClass('label-edit-mode');
	toggleBtn.text('Done Editing').removeClass('btn-info').addClass('btn-warning');

	// Insert drop zone after the toggle button's container
	var dropZone = $('<div id="newLabelDropZone" class="label-drop-zone">Drop here to create new label...</div>');
	toggleBtn.closest('li').append(dropZone);

	sidebar.find('li[data-domain]').attr('draggable', 'true');

	sidebar.on('dragstart.labeledit', 'li[data-domain]', function (e) {
		var domain = $(this).data('domain');
		e.originalEvent.dataTransfer.setData('text/plain', domain);
		e.originalEvent.dataTransfer.effectAllowed = 'move';
		$(this).addClass('dragging');
	});

	sidebar.on('dragend.labeledit', 'li[data-domain]', function () {
		$(this).removeClass('dragging');
	});

	sidebar.on('dragover.labeledit', 'ul[data-label-target]', function (e) {
		e.preventDefault();
		e.originalEvent.dataTransfer.dropEffect = 'move';
		$(this).addClass('drag-over');
	});

	sidebar.on('dragleave.labeledit', 'ul[data-label-target]', function (e) {
		if (!$.contains(this, e.relatedTarget)) {
			$(this).removeClass('drag-over');
		}
	});

	sidebar.on('drop.labeledit', 'ul[data-label-target]', function (e) {
		e.preventDefault();
		$(this).removeClass('drag-over');
		var domain = e.originalEvent.dataTransfer.getData('text/plain');
		var targetLabel = $(this).data('label-target');
		var targetUl = $(this);
		var draggedItem = sidebar.find('li[data-domain="' + domain + '"]');

		if (draggedItem.closest('ul').is(targetUl)) {
			return;
		}

		setDomainLabel(domain, targetLabel, function () {
			var sourceUl = draggedItem.closest('ul');
			targetUl.append(draggedItem);

			// Remove source section if only header remains
			if (sourceUl.children('li').length <= 1 && sourceUl.data('label-target') !== undefined) {
				sourceUl.remove();
			}
		});
	});

	// "Create New Label" drop zone
	$('#newLabelDropZone').on('dragover.labeledit', function (e) {
		e.preventDefault();
		e.originalEvent.dataTransfer.dropEffect = 'move';
		$(this).addClass('drag-over');
	});

	$('#newLabelDropZone').on('dragleave.labeledit', function () {
		$(this).removeClass('drag-over');
	});

	$('#newLabelDropZone').on('drop.labeledit', function (e) {
		e.preventDefault();
		$(this).removeClass('drag-over');
		var domain = e.originalEvent.dataTransfer.getData('text/plain');
		var newLabel = prompt('Enter new label name:');
		if (!newLabel || !newLabel.trim()) {
			return;
		}
		newLabel = newLabel.trim();

		var draggedItem = sidebar.find('li[data-domain="' + domain + '"]');

		setDomainLabel(domain, newLabel, function () {
			var sourceUl = draggedItem.closest('ul');

			// Create new section
			var newSection = $('<ul class="nav nav-pills flex-column" data-label-target="' + escapeHtml(newLabel) + '"></ul>');
			var header = $('<li class="nav-item"><div class="nav-link text-black"><strong>' + escapeHtml(newLabel) + '</strong></div></li>');
			newSection.append(header);
			newSection.append(draggedItem);
			sidebar.find('ul[data-label-target]').last().after(newSection);

			// Remove source section if only header remains
			if (sourceUl.children('li').length <= 1 && sourceUl.data('label-target') !== undefined) {
				sourceUl.remove();
			}
		});
	});
}

function exitLabelEditMode(sidebar, toggleBtn) {
	sidebar.removeClass('label-edit-mode');
	toggleBtn.text('Edit Labels').removeClass('btn-warning').addClass('btn-info');

	sidebar.find('li[data-domain]').removeAttr('draggable');
	sidebar.off('.labeledit');
	$('#newLabelDropZone').off('.labeledit').remove();
}

function setDomainLabel(domain, label, onSuccess) {
	$.ajax({
		url: '{{ url('/domain/') }}' + encodeURIComponent(domain) + '/setLabel.json',
		method: 'POST',
		data: {
			label: label,
			csrftoken: '{{ csrftoken }}'
		},
		dataType: 'json',
		success: function (data) {
			if (data.error) {
				alert('Error updating label: ' + data.error);
			} else if (onSuccess) {
				onSuccess();
			}
		},
		error: function () {
			alert('Failed to update label for ' + domain + '. Please try again.');
		}
	});
}

function escapeRegExp(str) {
	return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}

var entityMap = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;',
  '`': '&#x60;',
  '=': '&#x3D;'
};

function escapeHtml (string) {
  return String(string).replace(/[&<>"'`=\/]/g, function (s) {
    return entityMap[s];
  });
}
