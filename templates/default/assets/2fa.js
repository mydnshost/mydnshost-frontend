$(function() {
	$("#savedevice").change(function() {
		if (this.checked) {
			$("#devicename").show();
		} else {
			$("#devicename").hide();
		}
	});
});
