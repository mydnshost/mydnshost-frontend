$('button[data-user-action]').click(function () {
	var action = $(this).data('user-action');
	var user = $(this).data('user');
	var col = $(this).closest('td');
	var row = col.closest('tr');
	var value = col.find('span.value');

	$.ajax({
		url: "{{ url('/admin/users/action') }}/" + action + "/" + user,
		method: "POST",
	}).done(function(data) {
		if (data['error'] !== undefined) {
			alert('There was an error: ' + data['error']);
		} else if (data['response'] !== undefined) {
			var newVal = data['response'][value.data('field')] == 'true' ? "Yes" : "No";
			value.text(newVal);

			col.find('span.action[data-value]').each(function() {
				if ($(this).data('value') == newVal) {
					$(this).show();
				} else {
					$(this).hide();
				}
			});

			row.fadeOut(100).fadeIn(100);
		}
	});
});


$('button[data-action="deleteuser"]').click(function () {
	var user = $(this).data('id');
	var row = $(this).closest('tr');

	var okButton = $('#confirmDelete button[data-action="ok"]');
	okButton.removeClass("btn-success").addClass("btn-danger").text("Delete User");

	okButton.off('click').click(function () {
		$.ajax({
			url: "{{ url('/admin/users/delete') }}/" + user,
			method: "POST",
		}).done(function(data) {
			if (data['error'] !== undefined) {
				alert('There was an error: ' + data['error']);
			} else if (data['response'] !== undefined) {
				row.fadeOut(500, function(){ $(this).remove(); });
			}
		});
	});

	$('#confirmDelete').modal({'backdrop': 'static'});
});




$("#adduser").validate({
	highlight: function(element) {
		$(element).closest('.form-group').addClass('has-danger');
	},
	unhighlight: function(element) {
		$(element).closest('.form-group').removeClass('has-danger');
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
