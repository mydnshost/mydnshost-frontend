{% embed 'blocks/modal_confirm.tpl' with {'id': 'cancelJobModal'} %}
	{% block title %}
		Cancel Job
	{% endblock %}

	{% block body %}
		Are you sure you want to cancel this job?
		<br><br>
		This will also cancel any dependant jobs that are still waiting.
	{% endblock %}

	{% block buttons %}
		<button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">No, go back</button>
		<button type="button" id="cancelJobConfirm" class="btn btn-danger">Cancel Job</button>
	{% endblock %}
{% endembed %}

<script>
var cancelActionUrl = '';

document.querySelectorAll('.btn-cancel-job').forEach(function(btn) {
	btn.addEventListener('click', function() {
		cancelActionUrl = this.getAttribute('data-cancel-url');
		var modal = new bootstrap.Modal(document.getElementById('cancelJobModal'));
		modal.show();
	});
});

document.getElementById('cancelJobConfirm').addEventListener('click', function() {
	this.disabled = true;
	this.textContent = 'Cancelling...';
	fetch(cancelActionUrl, { redirect: 'manual' }).then(function() {
		location.reload();
	});
});
</script>
