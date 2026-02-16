{% embed 'blocks/modal_confirm.tpl' with {'id': 'createJobModal'} %}
	{% block title %}
		Create Job
	{% endblock %}

	{% block body %}
		<form method="post" action="{{ url('/system/jobs/create') }}" id="createJobForm">
			<input type="hidden" name="csrftoken" value="{{ csrftoken }}">
			<div class="mb-3">
				<label for="jobName" class="form-label">Job Name</label>
				<input type="text" name="name" id="jobName" class="form-control form-control-sm" required placeholder="e.g. verify_domain">
			</div>
			<div class="mb-3">
				<label for="jobData" class="form-label">Payload (JSON)</label>
				<textarea name="data" id="jobData" class="form-control form-control-sm font-monospace" rows="5" required placeholder='{"domain": "example.com"}'></textarea>
			</div>
			<div class="mb-3">
				<label for="jobDependsOn" class="form-label">Depends On (Job ID)</label>
				<input type="number" name="dependsOn" id="jobDependsOn" class="form-control form-control-sm" min="1" placeholder="Optional — job ID that must finish first">
			</div>
		</form>
	{% endblock %}

	{% block buttons %}
		<button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
		<button type="submit" form="createJobForm" class="btn btn-primary btn-sm">Schedule Job</button>
	{% endblock %}
{% endembed %}

<script>
document.querySelectorAll('.btn-clone-job').forEach(function(btn) {
	btn.addEventListener('click', function() {
		document.getElementById('jobName').value = this.getAttribute('data-job-name');
		document.getElementById('jobData').value = this.getAttribute('data-job-data');
		document.getElementById('jobDependsOn').value = this.getAttribute('data-job-depends-on') || '';
		document.getElementById('createJobModalLabel').textContent = 'Clone Job';
		var modal = new bootstrap.Modal(document.getElementById('createJobModal'));
		modal.show();
	});
});

document.getElementById('createJobModal').addEventListener('hidden.bs.modal', function() {
	document.getElementById('createJobModalLabel').textContent = 'Create Job';
});

document.getElementById('createJobForm').addEventListener('submit', function(e) {
	e.preventDefault();
	var submitBtn = document.querySelector('button[form="createJobForm"]');
	submitBtn.disabled = true;
	submitBtn.textContent = 'Scheduling...';
	fetch(this.action, {
		method: 'POST',
		body: new FormData(this),
		redirect: 'manual'
	}).then(function() {
		location.reload();
	});
});

document.querySelectorAll('.btn-repeat-job').forEach(function(btn) {
	btn.addEventListener('click', function() {
		this.classList.add('disabled');
		this.textContent = 'Repeating...';
		fetch(this.getAttribute('data-repeat-url'), { redirect: 'manual' }).then(function() {
			location.reload();
		});
	});
});
</script>
