{% set filterQS %}{% if filter.state|default('') %}&filter[state]={{ filter.state|url_encode }}{% endif %}{% if filter.name|default('') %}&filter[name]={{ filter.name|url_encode }}{% endif %}{% endset %}

<h1>Jobs</h1>

<div class="card mb-3">
	<div class="card-body py-2">
		<form method="get" action="{{ url('/system/jobs') }}">
			<div class="row g-2 align-items-end">
				<div class="col-auto">
					<label class="form-label mb-0"><small>State</small></label>
					<select name="filter[state]" class="form-select form-select-sm">
						<option value="">All</option>
						<option value="created"{{ filter.state|default('') == 'created' ? ' selected' }}>Created</option>
						<option value="started"{{ filter.state|default('') == 'started' ? ' selected' }}>Started</option>
						<option value="blocked"{{ filter.state|default('') == 'blocked' ? ' selected' }}>Blocked</option>
						<option value="finished"{{ filter.state|default('') == 'finished' ? ' selected' }}>Finished</option>
						<option value="error"{{ filter.state|default('') == 'error' ? ' selected' }}>Error</option>
						<option value="cancelled"{{ filter.state|default('') == 'cancelled' ? ' selected' }}>Cancelled</option>
					</select>
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Job Name</small></label>
					<input type="text" name="filter[name]" class="form-control form-control-sm" value="{{ filter.name|default('') }}" placeholder="e.g. publish_bind">
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
	<button class="btn btn-primary btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="#createJobForm">Create Job</button>
</div>

<div class="collapse mb-3" id="createJobForm">
	<div class="card">
		<div class="card-header">Create Job</div>
		<div class="card-body">
			<form method="post" action="{{ url('/system/jobs/create') }}">
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
				<button type="submit" class="btn btn-primary btn-sm">Schedule Job</button>
				<button type="button" class="btn btn-outline-secondary btn-sm" data-bs-toggle="collapse" data-bs-target="#createJobForm">Cancel</button>
			</form>
		</div>
	</div>
</div>

<table id="joblist" class="table table-striped table-hover">
	<thead class="table-light">
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
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/repeat') }}" class="btn btn-outline-warning btn-sm" title="Repeat">Repeat</a>
				{% if job.state in ['created', 'blocked'] %}
					<a href="{{ url('/system/jobs/' ~ job.id ~ '/cancel') }}" class="btn btn-outline-danger btn-sm" title="Cancel" onclick="return confirm('Cancel job {{ job.id }}?')">Cancel</a>
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
		{% if filter.state|default('') %}<input type="hidden" name="filter[state]" value="{{ filter.state }}">{% endif %}
		{% if filter.name|default('') %}<input type="hidden" name="filter[name]" value="{{ filter.name }}">{% endif %}
		<small class="text-muted text-nowrap">Page {{ pagination.page }} of {{ pagination.totalPages }}</small>
		<input type="number" name="page" class="form-control form-control-sm" style="width: 5em" min="1" max="{{ pagination.totalPages }}" placeholder="{{ pagination.page }}">
		<button type="submit" class="btn btn-outline-secondary btn-sm">Go</button>
	</form>
</div>
{% endif %}
