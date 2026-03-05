$(function() {
	// Add Block Regex - show modal with empty form
	$('a[data-action="addblockregex"]').click(function() {
		$('#blockregexform').attr('action', "{{ url('/admin/blockregexes/create') }}");
		$('#regex').val('');
		$('#comment').val('');
		$('#signup_name').prop('checked', false);
		$('#signup_email').prop('checked', false);
		$('#domain_name').prop('checked', false);
		$('#blockregex-id-row').remove();
		$('#blockregex-created-display').text(new Date().toLocaleString());

		$('#editBlockRegex .modal-title').text('Block Regex :: Create');
		var okButton = $('#editBlockRegex button[data-action="ok"]');
		okButton.text('Create Block Regex');
		okButton.off('click').click(function() {
			if ($('#blockregexform').valid()) {
				$('#blockregexform').submit();
			}
		});

		$('#editBlockRegex').modal('show');
		return false;
	});

	// Edit Block Regex - fetch data via AJAX, populate form, show modal
	$('a[data-action="editblockregex"]').click(function() {
		var blockregexId = $(this).data('id');

		$.getJSON("{{ url('/admin/blockregexes') }}/" + blockregexId + ".json", function(blockregex) {
			$('#blockregexform').attr('action', "{{ url('/admin/blockregexes') }}/" + blockregex.id);
			$('#regex').val(blockregex.regex);
			$('#comment').val(blockregex.comment);
			$('#signup_name').prop('checked', !!blockregex.signup_name);
			$('#signup_email').prop('checked', !!blockregex.signup_email);
			$('#domain_name').prop('checked', !!blockregex.domain_name);

			// Show ID row or create it if it was removed
			if ($('#blockregex-id-row').length) {
				$('#blockregex-id-display').text(blockregex.id);
				$('#blockregex-id-row').show();
			} else {
				$('#blockregexform tbody').prepend(
					'<tr id="blockregex-id-row"><th>ID</th><td id="blockregex-id-display">' + blockregex.id + '</td></tr>'
				);
			}
			$('#blockregex-created-display').text(new Date(blockregex.created * 1000).toLocaleString());

			$('#editBlockRegex .modal-title').text('Block Regex :: ' + blockregex.id);
			var okButton = $('#editBlockRegex button[data-action="ok"]');
			okButton.text('Edit Block Regex');
			okButton.off('click').click(function() {
				if ($('#blockregexform').valid()) {
					$('#blockregexform').submit();
				}
			});

			$('#editBlockRegex').modal('show');
		});

		return false;
	});

	// Delete Block Regex
	$('button[data-action="deleteblockregex"]').click(function () {
		var blockregex = $(this).data('id');
		var row = $(this).closest('tr');

		var okButton = $('#confirmDelete button[data-action="ok"]');
		okButton.removeClass("btn-success").addClass("btn-danger").text("Delete BlockRegex");

		okButton.off('click').click(function () {
			$.ajax({
				url: "{{ url('/admin/blockregexes') }}/" + blockregex + "/delete",
				data: {'csrftoken': $('#csrftoken').val()},
				method: "POST",
			}).done(function(data) {
				if (data['error'] !== undefined) {
					alert('There was an error: ' + data['error']);
				} else if (data['response'] !== undefined) {
					row.fadeOut(500, function(){ $(this).remove(); });
				}
			}).fail(function(data) {
				alert('There was an error: ' + data.responseText);
			});
		});

		$('#confirmDelete').modal('show');
	});
});
