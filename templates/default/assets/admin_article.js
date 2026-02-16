$(function() {
	// Convert unix timestamp to datetime-local input value (local timezone)
	function timestampToDatetimeLocal(ts) {
		if (!ts || ts < 0) return '';
		var d = new Date(ts * 1000);
		var pad = function(n) { return n < 10 ? '0' + n : n; };
		return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) +
			'T' + pad(d.getHours()) + ':' + pad(d.getMinutes());
	}

	// Convert datetime-local input value back to unix timestamp, or NaN if invalid
	function datetimeLocalToTimestamp(val) {
		if (!val) return NaN;
		var ts = Math.floor(new Date(val).getTime() / 1000);
		return isNaN(ts) ? NaN : ts;
	}

	// Populate datetime pickers from hidden timestamp fields
	var fromTs = parseInt($('#visiblefrom').val(), 10) || 0;
	$('#visiblefrom_picker').val(timestampToDatetimeLocal(fromTs));

	var untilTs = parseInt($('#visibleuntil').val(), 10) || 0;
	if (untilTs < 0) {
		$('#visibleuntil_never').prop('checked', true);
		$('#visibleuntil_picker').prop('disabled', true).val('');
	} else {
		$('#visibleuntil_picker').val(timestampToDatetimeLocal(untilTs));
	}

	// Sync picker changes back to hidden fields (only if valid)
	$('#visiblefrom_picker').on('change', function() {
		var ts = datetimeLocalToTimestamp($(this).val());
		if (!isNaN(ts)) {
			$('#visiblefrom').val(ts);
			$(this).removeClass('is-invalid');
		}
	});

	$('#visibleuntil_picker').on('change', function() {
		var ts = datetimeLocalToTimestamp($(this).val());
		if (!isNaN(ts)) {
			$('#visibleuntil').val(ts);
			$(this).removeClass('is-invalid');
		}
	});

	// No-expiry checkbox toggle
	$('#visibleuntil_never').on('change', function() {
		if ($(this).is(':checked')) {
			$('#visibleuntil_picker').prop('disabled', true).val('').removeClass('is-invalid');
			$('#visibleuntil').val('-1');
		} else {
			$('#visibleuntil_picker').prop('disabled', false);
			$('#visibleuntil').val('0');
		}
	});

	// Block submission if datetime pickers are incomplete
	$('#articleform').on('submit', function(e) {
		var valid = true;

		var fromVal = $('#visiblefrom_picker').val();
		if (!fromVal || isNaN(datetimeLocalToTimestamp(fromVal))) {
			$('#visiblefrom_picker').addClass('is-invalid');
			valid = false;
		}

		if (!$('#visibleuntil_never').is(':checked')) {
			var untilVal = $('#visibleuntil_picker').val();
			if (!untilVal || isNaN(datetimeLocalToTimestamp(untilVal))) {
				$('#visibleuntil_picker').addClass('is-invalid');
				valid = false;
			}
		}

		if (!valid) {
			e.preventDefault();
			$('.is-invalid').first().focus();
			return false;
		}
	});

	$("#articleform").validate({
		highlight: function(element) {
			$(element).addClass('is-invalid');
		},
		unhighlight: function(element) {
			$(element).removeClass('is-invalid');
		},
		errorClass: 'invalid-feedback',
		rules: {
			title: {
				required: true
			},
			content: {
				required: true
			}
		},
	});
});
