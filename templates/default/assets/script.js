$(".alert").alert()

$("input[data-search-top]").on('input', function() {
	var value = $(this).val();
	var searchTop = $(this).data('search-top');

	if (value == "") {
		$(searchTop).find("[data-searchable-value]").show();
	} else {
		var match = new RegExp('^.*' + escapeRegExp(value) + '.*$', 'i');

		$(searchTop).find("[data-searchable-value]").each(function() {
			if ($(this).data('searchable-value').match(match)) {
				$(this).show();
			} else {
				$(this).hide();
			}
		});
	}
});

function escapeRegExp(str) {
	return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}
