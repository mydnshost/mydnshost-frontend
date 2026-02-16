{% embed 'blocks/modal_confirm.tpl' with {'id': 'republishJobModal'} %}
	{% block title %}
		Republish Job
	{% endblock %}

	{% block body %}
		Are you sure you want to republish this job to the queue?
		<br><br>
		This will re-send the job message to RabbitMQ. Use this if the original message was lost from the queue.
	{% endblock %}

	{% block buttons %}
		<button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
		<a id="republishJobConfirm" href="#" class="btn btn-success btn-sm">Republish</a>
	{% endblock %}
{% endembed %}

<script>
document.querySelectorAll('.btn-republish-job').forEach(function(btn) {
	btn.addEventListener('click', function() {
		document.getElementById('republishJobConfirm').href = this.getAttribute('data-republish-url');
		var modal = new bootstrap.Modal(document.getElementById('republishJobModal'));
		modal.show();
	});
});
</script>
