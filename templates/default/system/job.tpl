<H1>Jobs :: {{ jobid }}</H1>

<a href="{{ url('/system/jobs' ) }}" class="btn btn-primary">Back</a>
<a href="{{ url('/system/jobs/' ~ jobid ~ '/logs') }}" class="btn btn-success">Refresh</a>
<br><br>

<table id="jobinfo" class="table table-striped table-bordered">
	<tbody>
		<tr>
			<th class="id">Job ID</th>
			<td class="id">{{ job.id }}</td>
		</tr>
		<tr>
			<th class="name">Details</th>
			<td class="name">
				<strong>Name:</strong> {{ job.name }} <br>
				<strong>Payload:</strong> <span class="mono">{{ job.data }}</span>
			</td>
		</tr>
		<tr>
			<th class="times">Times</th>
			<td class="times">
				<strong>Created:</strong> {{ job.created | date }} <br>
				<strong>Started:</strong> {{ job.started | date }} <br>
				<strong>Finished:</strong> {{ job.finished | date }} <br>
			</td>
		</tr>
		<tr>
			<th class="state">State</th>
			<td class="state">{{ job.state }}</td>
		</tr>
		<tr>
			<th class="result">Result</th>
			<td class="result">{{ job.result }}</td>
		</tr>
		<tr>
			<th class="actions">Actions</th>
			<td class="actions">
				<a href="{{ url('/system/jobs/' ~ job.id ~ '/logs') }}" class="btn btn-success btn-sm">Logs</a>
			</td>
		</tr>
	</tbody>
</table>

<br><br>


