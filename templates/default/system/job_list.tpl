{% set filterStates = filter.state|default([]) is iterable ? filter.state|default([]) : (filter.state|default('') ? [filter.state] : []) %}
{% if filterStates|length == 6 %}{% set filterStates = [] %}{% endif %}
{% set filterQS %}{% for s in filterStates %}&filter[state][]={{ s|url_encode }}{% endfor %}{% if filter.name|default('') %}&filter[name]={{ filter.name|url_encode }}{% endif %}{% for dk, dv in filter.data|default({}) %}&filter[data][{{ dk|url_encode }}]={{ dv|url_encode }}{% endfor %}{% endset %}

<h1>Jobs</h1>

<div class="card mb-3">
	<div class="card-body py-2">
		<form method="get" action="{{ url('/system/jobs') }}">
			<div class="row g-2 align-items-end">
				<div class="col-auto">
					<label class="form-label mb-0"><small>State</small></label>
					<div class="dropdown" id="stateFilterDropdown">
						<button class="form-control form-control-sm dropdown-toggle text-start" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
							{% if filterStates|length > 0 %}{% for s in filterStates %}{{ {created: 'Created', started: 'Started', blocked: 'Blocked', finished: 'Finished', error: 'Error', cancelled: 'Cancelled'}[s]|default(s) }}{{ not loop.last ? ', ' }}{% endfor %}{% else %}All{% endif %}
						</button>
						<div class="dropdown-menu">
							{% for value, label in {created: 'Created', started: 'Started', blocked: 'Blocked', finished: 'Finished', error: 'Error', cancelled: 'Cancelled'} %}
								<label class="dropdown-item"><input type="checkbox" class="form-check-input me-1" name="filter[state][]" value="{{ value }}"{{ value in filterStates ? ' checked' }}> {{ label }}</label>
							{% endfor %}
						</div>
					</div>
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Job Name</small></label>
					<input type="text" name="filter[name]" class="form-control form-control-sm" value="{{ filter.name|default('') }}" placeholder="e.g. verify_domain">
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Payload Key</small></label>
					<input type="text" name="filter_data_key" class="form-control form-control-sm" value="{{ (filter.data|default({}))|keys|first|default('') }}" placeholder="e.g. domain">
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Payload Value</small></label>
					<input type="text" name="filter_data_value" class="form-control form-control-sm" value="{{ (filter.data|default({}))|first|default('') }}" placeholder="e.g. example.com">
				</div>
				<div class="col-auto">
					<button type="submit" class="btn btn-primary btn-sm">Filter</button>
					<a href="{{ url('/system/jobs') }}" class="btn btn-outline-secondary btn-sm">Clear</a>
				</div>
				<div class="col-auto ms-auto">
					<span class="text-muted small">{{ pagination.total }} job{{ pagination.total != 1 ? 's' }} found</span>
				</div>
			</div>
		</form>
	</div>
</div>

<input class="form-control form-control-sm mb-3" data-search-top="table#joblist" value="" placeholder="Search within results...">

<div class="mb-3 text-end">
	<button class="btn btn-primary btn-sm" type="button" data-bs-toggle="modal" data-bs-target="#createJobModal">Create Job</button>
</div>

<table id="joblist" class="table table-striped table-hover">
	<thead>
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>State</th>
			<th>Created</th>
			<th>Duration</th>
			<th>Result</th>
			<th>Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for job in jobs %}
		<tr data-searchable-value="{{ job.name }} {{ job.id }} {{ job.data }}">
			<td><a href="{{ url('/system/jobs/' ~ job.id) }}">{{ job.id }}</a></td>
			<td>
				<code>{{ job.name }}</code>
				<br><small class="mono breakable text-muted">{{ job.data }}</small>
				{% if job.dependsOn %}
					<br><small class="text-muted">Depends on:
					{% for dep in job.dependsOn %}
						<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
					{% endfor %}
					</small>
				{% endif %}
				{% if job.dependants %}
					<br><small class="text-muted">Dependants:
					{% for dep in job.dependants %}
						<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
					{% endfor %}
					</small>
				{% endif %}
			</td>
			<td>
				{% if job.state == 'finished' %}
					<span class="badge bg-success">Finished</span>
				{% elseif job.state == 'error' %}
					<span class="badge bg-danger">Error</span>
				{% elseif job.state == 'started' %}
					<span class="badge bg-info text-dark">Started</span>
				{% elseif job.state == 'blocked' %}
					<span class="badge bg-warning text-dark">Blocked</span>
				{% elseif job.state == 'created' %}
					<span class="badge bg-secondary">Created</span>
				{% elseif job.state == 'cancelled' %}
					<span class="badge bg-dark">Cancelled</span>
				{% else %}
					<span class="badge bg-secondary">{{ job.state }}</span>
				{% endif %}
			</td>
			<td><small>{{ job.created | date }}</small></td>
			<td>
				{% if job.finished > 0 and job.started > 0 %}
					<small>{{ (job.finished - job.started) }}s</small>
				{% elseif job.started > 0 %}
					<small class="text-muted">Running...</small>
				{% else %}
					<small class="text-muted">-</small>
				{% endif %}
			</td>
			<td><small>{{ job.result }}</small></td>
			<td class="text-nowrap">
				<a href="{{ url('/system/jobs/' ~ job.id) }}" class="btn btn-outline-primary btn-sm" title="View">View</a>
				<button type="button" class="btn btn-outline-warning btn-sm btn-repeat-job" title="Repeat" data-repeat-url="{{ url('/system/jobs/' ~ job.id ~ '/repeat') }}">Repeat</button>
				<button type="button" class="btn btn-outline-info btn-sm btn-clone-job" title="Clone" data-job-name="{{ job.name }}" data-job-data="{{ job.data|e('html_attr') }}" data-job-depends-on="{{ job.dependsOn|first|default('') }}">Clone</button>
				{% if job.state == 'created' %}
					<button type="button" class="btn btn-outline-success btn-sm btn-republish-job" title="Republish" data-republish-url="{{ url('/system/jobs/' ~ job.id ~ '/republish') }}">Republish</button>
				{% endif %}
				{% if job.state in ['created', 'blocked'] %}
					<button type="button" class="btn btn-outline-danger btn-sm btn-cancel-job" title="Cancel" data-cancel-url="{{ url('/system/jobs/' ~ job.id ~ '/cancel') }}">Cancel</button>
				{% endif %}
			</td>
		</tr>
		{% else %}
		<tr>
			<td colspan="7" class="text-center text-muted py-4">No jobs found matching the current filters.</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% if pagination.totalPages > 1 %}
<div class="d-flex justify-content-between align-items-center">
	<nav aria-label="Job pagination">
		<ul class="pagination pagination-sm mb-0">
			{# First #}
			<li class="page-item{{ pagination.page <= 1 ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/jobs') }}?page=1{{ filterQS }}">First</a>
			</li>

			{# Previous #}
			<li class="page-item{{ pagination.page <= 1 ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/jobs') }}?page={{ pagination.page - 1 }}{{ filterQS }}">Prev</a>
			</li>

			{# Page numbers: show up to 5 pages around current #}
			{% set startPage = max(1, pagination.page - 2) %}
			{% set endPage = min(pagination.totalPages, startPage + 4) %}
			{% set startPage = max(1, endPage - 4) %}

			{% if startPage > 1 %}
				<li class="page-item disabled"><span class="page-link">&hellip;</span></li>
			{% endif %}

			{% for p in startPage..endPage %}
				<li class="page-item{{ p == pagination.page ? ' active' }}">
					<a class="page-link" href="{{ url('/system/jobs') }}?page={{ p }}{{ filterQS }}">{{ p }}</a>
				</li>
			{% endfor %}

			{% if endPage < pagination.totalPages %}
				<li class="page-item disabled"><span class="page-link">&hellip;</span></li>
			{% endif %}

			{# Next #}
			<li class="page-item{{ pagination.page >= pagination.totalPages ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/jobs') }}?page={{ pagination.page + 1 }}{{ filterQS }}">Next</a>
			</li>

			{# Last #}
			<li class="page-item{{ pagination.page >= pagination.totalPages ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/jobs') }}?page={{ pagination.totalPages }}{{ filterQS }}">Last</a>
			</li>
		</ul>
	</nav>

	<form method="get" action="{{ url('/system/jobs') }}" class="d-flex align-items-center gap-2 ms-3">
		{% for s in filterStates %}<input type="hidden" name="filter[state][]" value="{{ s }}">{% endfor %}
		{% if filter.name|default('') %}<input type="hidden" name="filter[name]" value="{{ filter.name }}">{% endif %}
		{% for dk, dv in filter.data|default({}) %}<input type="hidden" name="filter[data][{{ dk }}]" value="{{ dv }}">{% endfor %}
		<small class="text-muted text-nowrap">Page {{ pagination.page }} of {{ pagination.totalPages }}</small>
		<input type="number" name="page" class="form-control form-control-sm" style="width: 5em" min="1" max="{{ pagination.totalPages }}" placeholder="{{ pagination.page }}">
		<button type="submit" class="btn btn-outline-secondary btn-sm">Go</button>
	</form>
</div>
{% endif %}

{% include 'system/job_create_modal.tpl' %}
{% include 'system/job_republish_modal.tpl' %}
{% include 'system/job_cancel_modal.tpl' %}

<script>
(function() {
	var dropdown = document.getElementById('stateFilterDropdown');
	var btn = dropdown.querySelector('.dropdown-toggle');
	var checkboxes = dropdown.querySelectorAll('input[type="checkbox"]');
	function updateLabel() {
		var names = [];
		checkboxes.forEach(function(cb) {
			if (cb.checked) names.push(cb.parentElement.textContent.trim());
		});
		btn.textContent = (names.length > 0 && names.length < checkboxes.length) ? names.join(', ') : 'All';
	}
	checkboxes.forEach(function(cb) {
		cb.addEventListener('change', updateLabel);
	});
	dropdown.closest('form').addEventListener('submit', function() {
		var allChecked = true;
		checkboxes.forEach(function(cb) { if (!cb.checked) allChecked = false; });
		if (allChecked) {
			checkboxes.forEach(function(cb) { cb.checked = false; });
		}
	});
})();
</script>
