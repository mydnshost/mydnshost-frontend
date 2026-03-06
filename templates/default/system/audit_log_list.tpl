{% set filterQS %}{% if filter.type|default('') %}&filter[type]={{ filter.type|url_encode }}{% endif %}{% if filter.actor|default('') %}&filter[actor]={{ filter.actor|url_encode }}{% endif %}{% if filter.search|default('') %}&filter[search]={{ filter.search|url_encode }}{% endif %}{% endset %}

<h1>Audit Log</h1>

<div class="card mb-3">
	<div class="card-body py-2">
		<form method="get" action="{{ url('/system/audit') }}">
			<div class="row g-2 align-items-end">
				<div class="col-auto">
					<label class="form-label mb-0"><small>Event Type</small></label>
					<input type="text" name="filter[type]" class="form-control form-control-sm" value="{{ filter.type|default('') }}" placeholder="e.g. record.add">
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Actor</small></label>
					<input type="text" name="filter[actor]" class="form-control form-control-sm" value="{{ filter.actor|default('') }}" placeholder="e.g. user@example.com">
				</div>
				<div class="col-auto">
					<label class="form-label mb-0"><small>Search Summary</small></label>
					<input type="text" name="filter[search]" class="form-control form-control-sm" value="{{ filter.search|default('') }}" placeholder="e.g. example.com">
				</div>
				<div class="col-auto">
					<button type="submit" class="btn btn-primary btn-sm">Filter</button>
					<a href="{{ url('/system/audit') }}" class="btn btn-outline-primary btn-sm">Clear</a>
				</div>
				<div class="col-auto ms-auto">
					<span class="text-muted small">{{ pagination.total }} entr{{ pagination.total != 1 ? 'ies' : 'y' }} found</span>
				</div>
			</div>
		</form>
	</div>
</div>

<input class="form-control form-control-sm mb-3" data-search-top="table#auditlog" value="" placeholder="Search within results...">

<table id="auditlog" class="table table-striped table-hover">
	<thead>
		<tr>
			<th>ID</th>
			<th>Time</th>
			<th>Actor</th>
			<th>Type</th>
			<th>Summary</th>
			<th>Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for entry in entries %}
		<tr data-searchable-value="{{ entry.actor }} {{ entry.type }} {{ entry.summary }}">
			<td><a href="{{ url('/system/audit/' ~ entry.id) }}">{{ entry.id }}</a></td>
			<td><small>{{ entry.time | date }}</small></td>
			<td><small>{{ entry.actor }}</small></td>
			<td><code>{{ entry.type }}</code></td>
			<td>
				{{ entry.summary | audit_format }}
				{% if entry.extendedsummary is defined and entry.extendedsummary %}
					<br><small class="text-muted">{{ entry.extendedsummary | audit_format }}</small>
				{% endif %}
			</td>
			<td class="text-nowrap">
				<a href="{{ url('/system/audit/' ~ entry.id) }}" class="btn btn-outline-primary btn-sm" title="View">View</a>
			</td>
		</tr>
		{% else %}
		<tr>
			<td colspan="6" class="text-center text-muted py-4">No audit log entries found matching the current filters.</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% if pagination.totalPages > 1 %}
<div class="d-flex justify-content-between align-items-center">
	<nav aria-label="Audit log pagination">
		<ul class="pagination pagination-sm mb-0">
			{# First #}
			<li class="page-item{{ pagination.page <= 1 ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/audit') }}?page=1{{ filterQS }}">First</a>
			</li>

			{# Previous #}
			<li class="page-item{{ pagination.page <= 1 ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/audit') }}?page={{ pagination.page - 1 }}{{ filterQS }}">Prev</a>
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
					<a class="page-link" href="{{ url('/system/audit') }}?page={{ p }}{{ filterQS }}">{{ p }}</a>
				</li>
			{% endfor %}

			{% if endPage < pagination.totalPages %}
				<li class="page-item disabled"><span class="page-link">&hellip;</span></li>
			{% endif %}

			{# Next #}
			<li class="page-item{{ pagination.page >= pagination.totalPages ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/audit') }}?page={{ pagination.page + 1 }}{{ filterQS }}">Next</a>
			</li>

			{# Last #}
			<li class="page-item{{ pagination.page >= pagination.totalPages ? ' disabled' }}">
				<a class="page-link" href="{{ url('/system/audit') }}?page={{ pagination.totalPages }}{{ filterQS }}">Last</a>
			</li>
		</ul>
	</nav>

	<form method="get" action="{{ url('/system/audit') }}" class="d-flex align-items-center gap-2 ms-3">
		{% if filter.type|default('') %}<input type="hidden" name="filter[type]" value="{{ filter.type }}">{% endif %}
		{% if filter.actor|default('') %}<input type="hidden" name="filter[actor]" value="{{ filter.actor }}">{% endif %}
		{% if filter.search|default('') %}<input type="hidden" name="filter[search]" value="{{ filter.search }}">{% endif %}
		<small class="text-muted text-nowrap">Page {{ pagination.page }} of {{ pagination.totalPages }}</small>
		<input type="number" name="page" class="form-control form-control-sm" style="width: 5em" min="1" max="{{ pagination.totalPages }}" placeholder="{{ pagination.page }}">
		<button type="submit" class="btn btn-outline-primary btn-sm">Go</button>
	</form>
</div>
{% endif %}
