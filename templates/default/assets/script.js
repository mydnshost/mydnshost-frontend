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

{% if hasPermission(['domains_create']) %}

$('button[data-action="addUserDomain"]').click(function () {
	var okButton = $('#createUserDomain button[data-action="ok"]');
	okButton.text("Create");

	okButton.off('click').click(function () {
		$("#createUserDomainForm").submit();
	});

	$('#createUserDomain').modal({'backdrop': 'static'});
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

{% endif %}
