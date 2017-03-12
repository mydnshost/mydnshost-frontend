$(".alert").alert()

$("#sidebarsearch").on('input', function() {
	var value = $(this).val();

	if (value == "") {
		$("nav#sidebar li[data-value]").show();
	} else {
		var match = new RegExp('^.*' + escapeRegExp(value) + '.*$', 'i');

		$("nav#sidebar li[data-value]").each(function() {
			if ($(this).data('value').match(match)) {
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
