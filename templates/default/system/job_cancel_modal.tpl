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
		<button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">No, go back</button>
		<a id="cancelJobConfirm" href="#" class="btn btn-danger btn-sm">Cancel Job</a>
	{% endblock %}
{% endembed %}

<script>
document.querySelectorAll('.btn-cancel-job').forEach(function(btn) {
	btn.addEventListener('click', function() {
		document.getElementById('cancelJobConfirm').href = this.getAttribute('data-cancel-url');
		var modal = new bootstrap.Modal(document.getElementById('cancelJobModal'));
		modal.show();
	});
});
</script>
