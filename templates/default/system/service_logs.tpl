{% set filterQS %}{% if filterStream %}&stream={{ filterStream|url_encode }}{% endif %}{% if filterSearch %}&search={{ filterSearch|url_encode }}{% endif %}{% endset %}

<h1>Service :: {{ service }} :: Logs</h1>

<div class="mb-3">
	<a href="{{ url('/system/services') }}" class="btn btn-outline-primary btn-sm">Back to Services</a>
	<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-outline-secondary btn-sm">Refresh</a>
</div>

<div class="card mb-3">
	<div class="card-body py-2">
		<form method="get" action="{{ url('/system/services/' ~ service ~ '/logs') }}">
			<div class="row g-2 align-items-end">
				<div class="col-auto">
					<label class="form-label mb-0"><small>Stream</small></label>
					<select name="stream" class="form-select form-select-sm">
						<option value="">All</option>
						<option value="stdout"{{ filterStream == 'stdout' ? ' selected' }}>stdout</option>
						<option value="stderr"{{ filterStream == 'stderr' ? ' selected' }}>stderr</option>
					</select>
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Search</small></label>
					<input type="text" name="search" class="form-control form-control-sm" value="{{ filterSearch }}" placeholder="Search in messages...">
				</div>
				<div class="col-auto">
					<button type="submit" class="btn btn-primary btn-sm">Filter</button>
					<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-outline-secondary btn-sm">Clear</a>
				</div>
				<div class="col-auto ms-auto">
					<span class="text-muted small">{{ pagination.total }} log entr{{ pagination.total != 1 ? 'ies' : 'y' }}</span>
				</div>
			</div>
		</form>
	</div>
</div>

<div class="card mb-3">
	{% if logs %}
	<table class="table table-borderless table-sm my-2 font-monospace" style="font-size: 0.8rem;">
		<tbody>
			{% for log in logs %}
			<tr>
				<td class="text-nowrap py-0 ps-3 pe-1{{ log['stream'] == 'stderr' ? ' text-danger' : ' text-muted' }}" style="width: 1%; white-space: nowrap">{{ log['timestamp'] }}</td>
				<td class="text-nowrap py-0 pe-1" style="width: 1%; white-space: nowrap"><span class="badge border{{ log['stream'] == 'stderr' ? ' border-danger text-danger' : ' border-secondary text-secondary' }}">{{ log['docker']['name'] }} :: {{ log['stream'] }}</span></td>
				<td class="py-0{{ log['stream'] == 'stderr' ? ' text-danger' : '' }}" style="width: 100%">{{ log['message'] }}</td>
			</tr>
			{% endfor %}
		</tbody>
	</table>
	{% else %}
	<div class="card-body text-muted">
		No logs to show.
	</div>
	{% endif %}
</div>

{% if pagination.totalPages > 1 %}
<div class="d-flex justify-content-between align-items-center">
	<nav aria-label="Log pagination">
		<ul class="pagination pagination-sm mb-0">
			<li class="page-item{{ pagination.page <= 1 ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/services/' ~ service ~ '/logs') }}?page=1{{ filterQS }}">First</a>
			</li>

			<li class="page-item{{ pagination.page <= 1 ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/services/' ~ service ~ '/logs') }}?page={{ pagination.page - 1 }}{{ filterQS }}">Prev</a>
			</li>

			{% set startPage = max(1, pagination.page - 2) %}
			{% set endPage = min(pagination.totalPages, startPage + 4) %}
			{% set startPage = max(1, endPage - 4) %}

			{% if startPage > 1 %}
				<li class="page-item disabled"><span class="page-link">&hellip;</span></li>
			{% endif %}

			{% for p in startPage..endPage %}
				<li class="page-item{{ p == pagination.page ? ' active' }}">
					<a class="page-link" href="{{ url('/system/services/' ~ service ~ '/logs') }}?page={{ p }}{{ filterQS }}">{{ p }}</a>
				</li>
			{% endfor %}

			{% if endPage < pagination.totalPages %}
				<li class="page-item disabled"><span class="page-link">&hellip;</span></li>
			{% endif %}

			<li class="page-item{{ pagination.page >= pagination.totalPages ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/services/' ~ service ~ '/logs') }}?page={{ pagination.page + 1 }}{{ filterQS }}">Next</a>
			</li>

			<li class="page-item{{ pagination.page >= pagination.totalPages ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/services/' ~ service ~ '/logs') }}?page={{ pagination.totalPages }}{{ filterQS }}">Last</a>
			</li>
		</ul>
	</nav>

	<form method="get" action="{{ url('/system/services/' ~ service ~ '/logs') }}" class="d-flex align-items-center gap-2 ms-3">
		{% if filterStream %}<input type="hidden" name="stream" value="{{ filterStream }}">{% endif %}
		{% if filterSearch %}<input type="hidden" name="search" value="{{ filterSearch }}">{% endif %}
		<small class="text-muted text-nowrap">Page {{ pagination.page }} of {{ pagination.totalPages }}</small>
		<input type="number" name="page" class="form-control form-control-sm" style="width: 5em" min="1" max="{{ pagination.totalPages }}" placeholder="{{ pagination.page }}">
		<button type="submit" class="btn btn-outline-secondary btn-sm">Go</button>
	</form>
</div>
{% endif %}
