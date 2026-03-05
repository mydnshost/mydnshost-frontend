$(function() {
	// Add Article - show modal with empty form
	$('a[data-action="addarticle"]').click(function() {
		$('#articleform').attr('action', "{{ url('/admin/articles/create') }}");
		$('#title').val('');
		$('#content').val('');
		$('#visiblefrom').val(Math.floor(Date.now() / 1000));
		$('#visibleuntil').val('-1');
		$('#article-id-row').remove();
		$('#article-created-display').text(new Date().toLocaleString());

		$('#editArticle .modal-title').text('Article :: Create');
		var okButton = $('#editArticle button[data-action="ok"]');
		okButton.text('Create Article');
		okButton.off('click').click(function() {
			if ($('#articleform').valid()) {
				$('#articleform').submit();
			}
		});

		window.initArticleForm();
		$('#editArticle').modal('show');
		return false;
	});

	// Edit Article - fetch data via AJAX, populate form, show modal
	$('a[data-action="editarticle"]').click(function() {
		var articleId = $(this).data('id');

		$.getJSON("{{ url('/admin/articles') }}/" + articleId + ".json", function(article) {
			$('#articleform').attr('action', "{{ url('/admin/articles') }}/" + article.id);
			$('#title').val(article.title);
			$('#content').val(article.content);
			$('#visiblefrom').val(article.visiblefrom);
			$('#visibleuntil').val(article.visibleuntil);

			// Show ID row or create it if it was removed
			if ($('#article-id-row').length) {
				$('#article-id-display').text(article.id);
				$('#article-id-row').show();
			} else {
				$('#articleform tbody').prepend(
					'<tr id="article-id-row"><th>ID</th><td id="article-id-display">' + article.id + '</td></tr>'
				);
			}
			$('#article-created-display').text(new Date(article.created * 1000).toLocaleString());

			$('#editArticle .modal-title').text('Article :: ' + article.id);
			var okButton = $('#editArticle button[data-action="ok"]');
			okButton.text('Edit Article');
			okButton.off('click').click(function() {
				if ($('#articleform').valid()) {
					$('#articleform').submit();
				}
			});

			window.initArticleForm();
			$('#editArticle').modal('show');
		});

		return false;
	});

	// Delete Article
	$('button[data-action="deletearticle"]').click(function () {
		var article = $(this).data('id');
		var row = $(this).closest('tr');

		var okButton = $('#confirmDelete button[data-action="ok"]');
		okButton.removeClass("btn-success").addClass("btn-danger").text("Delete Article");

		okButton.off('click').click(function () {
			$.ajax({
				url: "{{ url('/admin/articles') }}/" + article + "/delete",
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
