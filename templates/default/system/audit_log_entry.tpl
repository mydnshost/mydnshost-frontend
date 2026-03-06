<h1>Audit Log Entry #{{ entryid }}</h1>

<div class="row mb-2">
	<div class="col">
		<a href="{{ url('/system/audit') }}" class="btn btn-outline-primary">Back to Audit Log</a>
	</div>
</div>

{% if entry %}
<div class="row">
	<div class="col-md-6">
		<div class="card mb-3">
			<div class="card-header">Details</div>
			<table class="table table-hover mb-0">
				<tbody>
					<tr>
						<th style="width: 30%">ID</th>
						<td>{{ entry.id }}</td>
					</tr>
					<tr>
						<th>Time</th>
						<td>{{ entry.time | date('Y-m-d H:i:s') }}</td>
					</tr>
					<tr>
						<th>Actor</th>
						<td>{{ entry.actor ?: '<span class="text-muted">system</span>' | raw }}</td>
					</tr>
					<tr>
						<th>Type</th>
						<td><code>{{ entry.type }}</code></td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

	<div class="col-md-6">
		<div class="card mb-3">
			<div class="card-header">Summary</div>
			<div class="card-body">
				<p class="mb-0">{{ entry.summary | audit_format }}</p>
				{% if entry.extendedsummary is defined and entry.extendedsummary %}
					<hr class="my-2">
					<small class="text-muted">{{ entry.extendedsummary | audit_format }}</small>
				{% endif %}
			</div>
		</div>
	</div>
</div>

{% if entry.args_formatted is defined %}
<div class="card mb-3">
	<div class="card-header">Event Arguments</div>
	<div class="card-body">
		<pre class="mb-0"><code>{{ entry.args_formatted | json_highlight }}</code></pre>
	</div>
</div>
{% endif %}

{% else %}
<div class="alert alert-danger">Audit log entry not found.</div>
{% endif %}
