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

	// Drag-and-drop label management
	(function () {
		var sidebar = $('nav#sidebar');
		var draggableItems = sidebar.find('li[data-draggable-type="domain"]');
		if (draggableItems.length === 0) return;

		draggableItems.attr('draggable', 'true');

		// Prevent drag handle click from following the link
		sidebar.on('click', '.drag-handle', function (e) {
			e.preventDefault();
			e.stopPropagation();
		});

		var dropZone = $('#newLabelDropZone');

		dropZone.on('dragover', function (ev) {
			ev.preventDefault();
			ev.originalEvent.dataTransfer.dropEffect = 'move';
			$(this).addClass('drag-over');
		});

		dropZone.on('dragleave', function () {
			$(this).removeClass('drag-over');
		});

		dropZone.on('drop', function (ev) {
			ev.preventDefault();
			$(this).removeClass('drag-over');
			var droppedDomain = ev.originalEvent.dataTransfer.getData('text/plain');

			// Show modal to get label name
			$('#createLabelDomain').val(droppedDomain);
			$('#createLabelName').val('');

			var okButton = $('#createLabelModal button[data-action="ok"]');
			okButton.prop('disabled', false).text('Create');

			okButton.off('click').click(function () {
				var newLabel = $('#createLabelName').val().trim();
				if (!newLabel) {
					$('#createLabelModal').modal('hide');
					return;
				}

				okButton.prop('disabled', true).text('Creating...');

				setDomainLabel(droppedDomain, newLabel, function () {
					$('#createLabelModal').modal('hide');
					location.reload();
				});
			});

			$('#createLabelModal').modal({'backdrop': 'static'}).modal('show');
		});

		sidebar.on('dragstart', 'li[data-draggable-type="domain"]', function (e) {
			var domain = $(this).data('domain');
			e.originalEvent.dataTransfer.setData('text/plain', domain);
			e.originalEvent.dataTransfer.effectAllowed = 'move';
			$(this).addClass('dragging');
			dropZone.addClass('visible');
		});

		sidebar.on('dragend', 'li[data-draggable-type="domain"]', function () {
			$(this).removeClass('dragging');
			dropZone.removeClass('visible');
		});

		sidebar.on('dragover', 'ul[data-label-target]', function (e) {
			e.preventDefault();
			e.originalEvent.dataTransfer.dropEffect = 'move';
			$(this).addClass('drag-over');
		});

		sidebar.on('dragleave', 'ul[data-label-target]', function (e) {
			if (!$.contains(this, e.relatedTarget)) {
				$(this).removeClass('drag-over');
			}
		});

		sidebar.on('drop', 'ul[data-label-target]', function (e) {
			e.preventDefault();
			$(this).removeClass('drag-over');
			var domain = e.originalEvent.dataTransfer.getData('text/plain');
			var targetLabel = $(this).data('label-target');
			var targetUl = $(this);
			var draggedItem = sidebar.find('li[data-domain="' + domain + '"]');

			if (draggedItem.closest('ul').is(targetUl)) return;

			setDomainLabel(domain, targetLabel, function () {
				var sourceUl = draggedItem.closest('ul');
				targetUl.append(draggedItem);

				if (sourceUl.children('li').length <= 1 && sourceUl.data('label-target') !== undefined) {
					sourceUl.remove();
				}
			});
		});
	})();

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
