$(function() {
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

		$('#confirmDelete').modal({'backdrop': 'static'}).modal('show');
	});
});
