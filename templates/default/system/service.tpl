<h1>Service :: {{ service }}</h1>

<div class="mb-3">
	<a href="{{ url('/system/services') }}" class="btn btn-outline-primary btn-sm">Back to Services</a>
	<a href="{{ url('/system/services/' ~ service ~ '/logs') }}" class="btn btn-outline-secondary btn-sm">View Logs</a>
</div>
