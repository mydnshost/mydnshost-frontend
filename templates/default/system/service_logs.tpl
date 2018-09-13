<H1>Service :: {{ service }} :: Logs</H1>

<a href="{{ url('/system/services/' ~ name ) }}" class="btn btn-success">Back</a>

<pre class="logs">
	{{ logs }}
</pre>
