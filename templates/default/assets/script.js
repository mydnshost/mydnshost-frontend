$(function() {
	$('a[data-action="addUserDomain"]').click(function () {
		var actionUrl = $(this).attr('href');
		$('#createUserDomainForm').attr('action', actionUrl);
		$('#domainname').val('');
		$('#owner').val('');

		var ownerRow = $('#domainOwnerRow');
		if (ownerRow.length) {
			if ($(this).data('show-owner')) {
				ownerRow.removeClass('d-none');
			} else {
				ownerRow.addClass('d-none');
			}
		}

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

		$('#createUserDomain').modal('show');
		return false;
	});

	$('a[data-action="findRecords"]').click(function () {
		var actionUrl = $(this).attr('href');
		$('#findRecordsForm').attr('action', actionUrl);
		$('#recordContent').val('');

		var okButton = $('#findRecordsModal button[data-action="ok"]');
		okButton.off('click').click(function () {
			if ($("#findRecordsForm").valid()) {
				$("#findRecordsForm").submit();
				$('#findRecordsModal').modal('hide');
			}
		});

		var cancelButton = $('#findRecordsModal button[data-action="cancel"]');
		cancelButton.off('click').click(function () {
			$("#findRecordsForm").validate().resetForm();
		});

		$('#findRecordsModal').modal('show');
		return false;
	});

	$("#findRecordsForm").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
		rules: {
			recordContent: {
				required: true
			}
		},
	});

	$("#createUserDomainForm").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
		rules: {
			domainname: {
				required: true
			},
			owner: {
				email: true
			}
		},
	});

	$(".alert").alert();

	// Admin elevation: shared disable/enable logic.
	var $elevateModal = $('#elevateModal');
	var $elevationControl = $('#elevationControl');
	var btnColorRe = /\bbtn-(?:outline-)?(?:primary|success|danger|warning|info|dark|light)\b/g;
	var elevationTimerId = null;
	var elevationChannel = (typeof BroadcastChannel !== 'undefined') ? new BroadcastChannel('admin_elevation') : null;

	function disableElevationButtons() {
		$('[data-needs-elevation]').each(function() {
			var $el = $(this);

			// Store original state for later restoration.
			if (!$el.data('elevation-original-class')) {
				$el.data('elevation-original-class', $el.attr('class') || '');
				$el.data('elevation-original-title', $el.attr('title') || '');
				if ($el.is('a')) {
					$el.data('elevation-original-action', $el.attr('data-action') || '');
					$el.data('elevation-original-bs-toggle', $el.attr('data-bs-toggle') || '');
					$el.data('elevation-original-bs-target', $el.attr('data-bs-target') || '');
				}
			}

			if ($el.is('input')) {
				$el.prop('disabled', true);
			} else if ($el.is('a')) {
				$el.addClass('disabled').attr('aria-disabled', 'true');
				$el.removeAttr('data-action data-bs-toggle data-bs-target');
				$el.on('click.elevation', function(e) {
					e.preventDefault();
					e.stopImmediatePropagation();
					$elevateModal.modal('show');
				});
			} else {
				$el.prop('disabled', true);
			}
			$el.attr('title', 'Admin elevation required');

			// Grey out the button.
			var classes = $el.attr('class') || '';
			$el.attr('class', classes.replace(btnColorRe, 'btn-outline-secondary'));
		});
	}

	function enableElevationButtons() {
		$('[data-needs-elevation]').each(function() {
			var $el = $(this);
			var origClass = $el.data('elevation-original-class');
			if (!origClass) return;

			$el.attr('class', origClass);
			var origTitle = $el.data('elevation-original-title');
			if (origTitle) { $el.attr('title', origTitle); } else { $el.removeAttr('title'); }

			if ($el.is('input')) {
				$el.prop('disabled', false);
			} else if ($el.is('a')) {
				$el.removeClass('disabled').removeAttr('aria-disabled');
				$el.off('click.elevation');
				var origAction = $el.data('elevation-original-action');
				var origToggle = $el.data('elevation-original-bs-toggle');
				var origTarget = $el.data('elevation-original-bs-target');
				if (origAction) $el.attr('data-action', origAction);
				if (origToggle) $el.attr('data-bs-toggle', origToggle);
				if (origTarget) $el.attr('data-bs-target', origTarget);
			} else {
				$el.prop('disabled', false);
			}

			$el.removeData('elevation-original-class elevation-original-title elevation-original-action elevation-original-bs-toggle elevation-original-bs-target');
		});
	}

	function showElevateButton() {
		$elevationControl.html(
			'<a href="{{ url("/admin/elevate") }}" class="btn btn-outline-warning my-2 my-sm-0 me-sm-2" data-bs-toggle="modal" data-bs-target="#elevateModal">Elevate</a>'
		);
	}

	function showElevatedButton(expires) {
		var isImpersonating = $elevationControl.data('impersonating') == '1';
		if (isImpersonating) {
			$elevationControl.html(
				'<span class="btn btn-warning my-2 my-sm-0 me-sm-2" style="cursor: default;">Elevated <span class="badge bg-light text-dark" id="elevationTimer"></span></span>'
			);
		} else {
			$elevationControl.html(
				'<a href="{{ url("/admin/elevate") }}" class="btn btn-warning my-2 my-sm-0 me-sm-2" id="deelevateBtn">Elevated <span class="badge bg-light text-dark" id="elevationTimer"></span></a>'
			);
			$('#deelevateBtn').on('click', deelevate);
		}
		startElevationTimer(expires);
	}

	function startElevationTimer(expires) {
		if (elevationTimerId) clearTimeout(elevationTimerId);
		function tick() {
			var $timers = $('#elevationTimer, .elevation-timer');
			var remaining = expires - Math.floor(Date.now() / 1000);
			if (remaining <= 0) {
				$timers.text('Expired');
				disableElevationButtons();
				showElevateButton();
				return;
			}
			var mins = Math.floor(remaining / 60);
			var secs = remaining % 60;
			$timers.text(mins + ':' + (secs < 10 ? '0' : '') + secs);
			elevationTimerId = setTimeout(tick, 1000);
		}
		tick();
	}

	function deelevate(e) {
		if (e) e.preventDefault();
		$.ajax({
			url: '{{ url("/admin/deelevate.json") }}',
			method: 'POST',
			data: { csrftoken: '{{ csrftoken }}' },
			dataType: 'json',
			success: function() {
				if (elevationTimerId) { clearTimeout(elevationTimerId); elevationTimerId = null; }
				disableElevationButtons();
				showElevateButton();
				if (elevationChannel) elevationChannel.postMessage({ type: 'deelevated' });
			}
		});
	}

	if ($elevateModal.length) {
		// Set redirect to current page so user returns here after elevating.
		$('#elevateRedirect').val(window.location.href);

		// Check elevation status before showing modal (handles elevation in another tab).
		var skipStatusCheck = false;
		$elevateModal.on('show.bs.modal', function(e) {
			if (skipStatusCheck) {
				skipStatusCheck = false;
				return;
			}
			e.preventDefault();
			$.ajax({
				url: '{{ url("/admin/elevate/status.json") }}',
				method: 'GET',
				dataType: 'json',
				success: function(data) {
					if (data.elevated) {
						enableElevationButtons();
						showElevatedButton(data.expires);
					} else {
						skipStatusCheck = true;
						$elevateModal.modal('show');
					}
				},
				error: function() {
					skipStatusCheck = true;
					$elevateModal.modal('show');
				}
			});
		});

		// Wire up modal OK button to submit via AJAX.
		$('#elevateModal button[data-action="ok"]').off('click').click(function() {
			var $btn = $(this);
			$btn.prop('disabled', true).text('Elevating...');
			$.ajax({
				url: $('#elevateForm').attr('action') + '.json',
				method: 'POST',
				data: $('#elevateForm').serialize(),
				dataType: 'json',
				success: function(data) {
					if (data.success) {
						$elevateModal.modal('hide');
						enableElevationButtons();
						showElevatedButton(data.expires);
						if (elevationChannel) elevationChannel.postMessage({ type: 'elevated', expires: data.expires });
					} else {
						alert(data.error || 'Elevation failed.');
					}
				},
				error: function() {
					alert('Elevation request failed.');
				},
				complete: function() {
					$btn.prop('disabled', false).text('Elevate');
					$('#elevateForm')[0].reset();
				}
			});
		});

		// Wire up de-elevate button if present on page load.
		$('#deelevateBtn').on('click', deelevate);

		// Listen for elevation changes from other tabs.
		if (elevationChannel) {
			elevationChannel.onmessage = function(e) {
				if (e.data.type === 'elevated') {
					enableElevationButtons();
					showElevatedButton(e.data.expires);
				} else if (e.data.type === 'deelevated') {
					if (elevationTimerId) { clearTimeout(elevationTimerId); elevationTimerId = null; }
					disableElevationButtons();
					showElevateButton();
				}
			};
		}

		// Admin elevation timer countdown (for page-load elevated state).
		var $timer = $('#elevationTimer');
		if ($timer.length) {
			startElevationTimer(parseInt($timer.data('expires'), 10));
		} else {
			// Not elevated - disable all elements that need elevation.
			disableElevationButtons();
		}
	}

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

			$('#renameLabelModal').modal('show');
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

			$('#createLabelModal').modal('show');
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

// Scroll to top when sidebar is shown on mobile
$('#sidebar').on('show.bs.collapse', function() {
	window.scrollTo(0, 0);
});

// Dynamically adjust body/sidebar spacing when navbar wraps to multiple lines
(function() {
	var navbar = document.querySelector('nav.navbar.fixed-top');
	if (!navbar) return;

	function updateNavbarHeight() {
		document.documentElement.style.setProperty('--navbar-height', navbar.offsetHeight + 'px');
	}

	if (typeof ResizeObserver !== 'undefined') {
		new ResizeObserver(updateNavbarHeight).observe(navbar);
	} else {
		window.addEventListener('resize', updateNavbarHeight);
	}

	updateNavbarHeight();
})();

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
