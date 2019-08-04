<H1>Jobs :: {{ jobid }} :: Repeat</H1>

<a href="{{ url('/system/jobs' ) }}" class="btn btn-primary">Back</a>
<br><br>

{% if result.jobid %}
	{{ result.status }}<br>
	New Job ID: <a href="{{ url('/system/jobs/' ~ result.jobid ~ '/logs') }}">{{ result.jobid }}</a>
{% else %}
	There was an error: {{ error }}
{% endif %}

<br><br>


