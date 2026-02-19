<h1>Job {{ jobid }}</h1>

<div class="row mb-2">
	<div class="col">
		<a href="{{ url('/system/jobs') }}" class="btn btn-outline-primary">Back to Jobs</a>
		<a href="{{ url('/system/jobs/' ~ jobid) }}" class="btn btn-outline-secondary">Refresh</a>

		<div class="float-end">
			<button type="button" class="btn btn-outline-warning btn-repeat-job" data-repeat-url="{{ url('/system/jobs/' ~ jobid ~ '/repeat') }}">Repeat</button>
			<button type="button" class="btn btn-outline-info btn-clone-job" data-job-name="{{ job.name }}" data-job-data="{{ (job.data_formatted|default(job.data))|e('html_attr') }}" data-job-depends-on="{{ job.dependsOn|first|default('') }}">Clone</button>
			{% if job.state == 'created' %}
				<button type="button" class="btn btn-outline-success btn-republish-job" data-republish-url="{{ url('/system/jobs/' ~ jobid ~ '/republish') }}">Republish</button>
			{% endif %}
			{% if job.state in ['created', 'blocked'] %}
				<button type="button" class="btn btn-outline-danger btn-cancel-job" data-cancel-url="{{ url('/system/jobs/' ~ jobid ~ '/cancel') }}">Cancel</button>
			{% endif %}
		</div>
	</div>
</div>

<div class="row">
	<div class="col-md-6">
		<div class="card mb-3">
			<div class="card-header">Details</div>
			<table class="table table-hover mb-0">
				<tbody>
					<tr>
						<th style="width: 30%">Job ID</th>
						<td>{{ job.id }}</td>
					</tr>
					<tr>
						<th>Name</th>
						<td><code>{{ job.name }}</code></td>
					</tr>
					<tr>
						<th>Reason</th>
						<td>{{ job.reason|default('-') }}</td>
					</tr>
					{% if job.created_by_job %}
					<tr>
						<th>Created By</th>
						<td><a href="{{ url('/system/jobs/' ~ job.created_by_job) }}">#{{ job.created_by_job }}</a></td>
					</tr>
					{% endif %}
					<tr>
						<th>State</th>
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
					</tr>
					<tr>
						<th>Result</th>
						<td>{{ job.result|default('-') }}</td>
					</tr>
					{% if job.dependsOn %}
					<tr>
						<th>Depends On</th>
						<td>
							{% for dep in job.dependsOn %}
								<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
							{% endfor %}
						</td>
					</tr>
					{% endif %}
					{% if job.dependants %}
					<tr>
						<th>Dependants</th>
						<td>
							{% for dep in job.dependants %}
								<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
							{% endfor %}
						</td>
					</tr>
					{% endif %}
				</tbody>
			</table>
		</div>
	</div>

	<div class="col-md-6">
		<div class="card mb-3">
			<div class="card-header">Timing</div>
			<table class="table table-hover mb-0">
				<tbody>
					<tr>
						<th style="width: 30%">Created</th>
						<td>{{ job.created | date }}</td>
					</tr>
					<tr>
						<th>Started</th>
						<td>{% if job.started > 0 %}{{ job.started | date }}{% else %}<span class="text-muted">Not started</span>{% endif %}</td>
					</tr>
					<tr>
						<th>Finished</th>
						<td>{% if job.finished > 0 %}{{ job.finished | date }}{% else %}<span class="text-muted">Not finished</span>{% endif %}</td>
					</tr>
					{% if job.finished > 0 and job.started > 0 %}
					<tr>
						<th>Duration</th>
						<td>{{ (job.finished - job.started) }}s</td>
					</tr>
					{% endif %}
				</tbody>
			</table>
		</div>
	</div>
</div>

<div class="card mb-3">
	<div class="card-header">Payload</div>
	<div class="card-body p-0">
		<pre class="mb-0 p-3"><code>{{ job.data_formatted|default(job.data) }}</code></pre>
	</div>
</div>

{% macro jobTreeRow(rj, currentJobId, allJobs, depth, isLast, continuations) %}
{% set children = allJobs|filter(j => j.created_by_job == rj.id)|sort((a, b) => a.id <=> b.id) %}
<tr class="{{ rj.id == currentJobId ? 'table-active fw-bold' : '' }}">
	<td><a href="{{ url('/system/jobs/' ~ rj.id) }}">{{ rj.id }}</a></td>
	<td>
		<span class="text-nowrap">{% if depth > 0 %}{% for cont in continuations %}<span class="tree-guide text-muted">{{ cont ? '│' : '' }}</span>{% endfor %}<span class="tree-guide text-muted">{{ isLast ? '└─' : '├─' }}</span> {% endif %}<code>{{ rj.name }}</code></span>{% if rj.reason %} <small class="text-muted fst-italic">({{ rj.reason }})</small>{% endif %}
		{% if rj.data %}
			<br>{% if depth > 0 %}{% for cont in continuations %}<span class="tree-guide text-muted">{{ cont ? '│' : '' }}</span>{% endfor %}<span class="tree-guide text-muted">{{ (not isLast) ? '│' : '' }}</span> {% endif %}<small><code class="text-muted">{{ rj.data_formatted|default(rj.data) }}</code></small>
		{% endif %}
		{% if rj.dependsOn %}
			<br><small class="text-muted">{% if depth > 0 %}{% for cont in continuations %}<span class="tree-guide">{{ cont ? '│' : '' }}</span>{% endfor %}<span class="tree-guide">{{ (not isLast) ? '│' : '' }}</span> {% endif %}Depends on:
			{% for dep in rj.dependsOn %}
				<a href="{{ url('/system/jobs/' ~ dep) }}">{{ dep }}</a>{{ not loop.last ? ', ' }}
			{% endfor %}
			</small>
		{% endif %}
	</td>
	<td>
		{% if rj.state == 'finished' %}
			<span class="badge bg-success">Finished</span>
		{% elseif rj.state == 'error' %}
			<span class="badge bg-danger">Error</span>
		{% elseif rj.state == 'started' %}
			<span class="badge bg-info text-dark">Started</span>
		{% elseif rj.state == 'blocked' %}
			<span class="badge bg-warning text-dark">Blocked</span>
		{% elseif rj.state == 'created' %}
			<span class="badge bg-secondary">Created</span>
		{% elseif rj.state == 'cancelled' %}
			<span class="badge bg-dark">Cancelled</span>
		{% else %}
			<span class="badge bg-secondary">{{ rj.state }}</span>
		{% endif %}
	</td>
	<td><small>{{ rj.created | date }}</small></td>
	<td>
		{% if rj.finished > 0 and rj.started > 0 %}
			<small>{{ (rj.finished - rj.started) }}s</small>
		{% elseif rj.started > 0 %}
			<small class="text-muted">Running...</small>
		{% else %}
			<small class="text-muted">-</small>
		{% endif %}
	</td>
	<td><small>{{ rj.result|default('-') }}</small></td>
</tr>
{% for child in children %}
{{ _self.jobTreeRow(child, currentJobId, allJobs, depth + 1, loop.last, continuations|merge([not isLast])) }}
{% endfor %}
{% endmacro %}

{% if job.relatedJobs is defined and job.relatedJobs|length > 1 %}
{% set relatedIds = job.relatedJobs|map(j => j.id) %}
<div class="card mb-3">
	<div class="card-header">Related Jobs <small class="text-muted">({{ job.relatedJobs|length }})</small></div>
	<table class="table table-sm table-hover mb-0">
		<thead>
			<tr>
				<th style="width: 100px">ID</th>
				<th>Name</th>
				<th style="width: 100px">State</th>
				<th style="width: 250px">Created</th>
				<th style="width: 100px">Duration</th>
				<th style="width: 100px">Result</th>
			</tr>
		</thead>
		<tbody>
			{% set roots = job.relatedJobs|filter(rj => rj.created_by_job is null or rj.created_by_job not in relatedIds)|sort((a, b) => a.id <=> b.id) %}
			{% for root in roots %}
			{{ _self.jobTreeRow(root, job.id, job.relatedJobs, 0, loop.last, []) }}
			{% endfor %}
		</tbody>
	</table>
</div>
{% endif %}

<style>
.tree-guide { display: inline-block; width: 1.5em; }
.log-prefix-header { color: #0d6efd; font-weight: 700; }
.log-prefix-result { color: #198754; font-weight: 700; }
.log-prefix-skip { color: #fd7e14; font-weight: 700; }
.log-error td:last-child { color: #dc3545; }
.log-lock td:last-child { opacity: 0.45; }
.log-cmd-sep td:last-child { opacity: 0.3; }
.log-cmd td:last-child { font-weight: 600; }
.log-schedule td:last-child { color: #6c757d; font-style: italic; }
</style>

<div class="card mb-3">
	<div class="card-header">Logs</div>
	{% if job.logs is defined and job.logs %}
	<table class="table table-borderless table-sm my-2 font-monospace" style="font-size: 0.8rem;">
		<tbody>
			{% for log in job.logs %}
			{% if log.data starts with 'JOB ' or log.data starts with 'FUNCTION ' or log.data starts with 'PAYLOAD ' %}
				{% set logClass = 'log-header' %}
			{% elseif log.data starts with 'RESULT ' %}
				{% set logClass = 'log-result' %}
			{% elseif log.data starts with '# STDERR:' or log.data starts with 'EXCEPTION' or log.data starts with 'ERR ' or log.data starts with 'TRACE ' %}
				{% set logClass = 'log-error' %}
			{% elseif log.data starts with 'SKIP ' %}
				{% set logClass = 'log-skip' %}
			{% elseif log.data starts with 'acquireLock(' or log.data starts with 'releaseLock(' or log.data starts with 'Lock for ' %}
				{% set logClass = 'log-lock' %}
			{% elseif log.data starts with '=====' %}
				{% set logClass = 'log-cmd-sep' %}
			{% elseif log.data starts with '$ Running Command:' %}
				{% set logClass = 'log-cmd' %}
			{% elseif log.data starts with 'Scheduling background job:' or log.data starts with 'Scheduled as:' or log.data starts with 'Scheduled and finished as:' or log.data starts with 'Running foreground job:' %}
				{% set logClass = 'log-schedule' %}
			{% else %}
				{% set logClass = '' %}
			{% endif %}
			<tr class="{{ logClass }}">
				<td class="text-nowrap text-muted py-0 ps-3 pe-2" style="width: 250px">{{ log.time | date }}</td>
				<td class="py-0">
					{% if logClass in ['log-header', 'log-result', 'log-skip'] %}
						{% set parts = log.data|split(' ', 2) %}
						<span class="log-prefix-{{ logClass|slice(4) }}">{{ parts[0] }}</span> {{ parts[1]|default('') }}
					{% else %}
						{{ log.data }}
					{% endif %}
				</td>
			</tr>
			{% endfor %}
		</tbody>
	</table>
	{% else %}
	<div class="card-body text-muted">
		No logs available. Either the job didn't produce any output, or the JobLogger service is not running.
	</div>
	{% endif %}
</div>

{% include 'system/job_create_modal.tpl' %}
{% include 'system/job_republish_modal.tpl' %}
{% include 'system/job_cancel_modal.tpl' %}
