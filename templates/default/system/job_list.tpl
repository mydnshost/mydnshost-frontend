<H1>Jobs</H1>

<table id="joblist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">Job ID</th>
			<th class="name">Details</th>
			<th class="times">Times</th>
			<th class="state">State</th>
			<th class="result">Result</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for job in jobs %}
		<tr data-searchable-value="{{ job }}">
			<td class="id">{{ job.id }}</td>
			<td class="name">
				<strong>Name:</strong> {{ job.name }} <br>
				<strong>Payload:</strong> <span class="mono breakable">{{ job.data }}</span>
			</td>
			<td class="times">
				<strong>Created:</strong> {{ job.created | date }} <br>
				<strong>Started:</strong> {{ job.started | date }} <br>
				<strong>Finished:</strong> {{ job.finished | date }} <br>
			</td>
			<td class="state">{{ job.state }}</td>
			<td class="result">{{ job.result }}</td>
			<td class="actions">
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/logs') }}" class="btn btn-success btn-sm">Logs</a>
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/repeat') }}" class="btn btn-warning btn-sm">Repeat</a>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<!-- <script src="{{ url('/assets/jobs/list.js') }}"></script> -->
