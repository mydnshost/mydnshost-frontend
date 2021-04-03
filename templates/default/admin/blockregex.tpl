{% if create %}
<H1>Block Regex :: Create</H1>
<form action="{{ url('/admin/blockregexes/create') }}" method="POST" id="blockregexform">
{% else %}
<H1>BlockRegex :: {{ blockregex.id }}</H1>
<form action="{{ url('/admin/blockregexes/' ~ blockregex.id) }}" method="POST" id="blockregexform">
{% endif %}
<input type="hidden" name="csrftoken" value="{{csrftoken}}">

<table id="blockregex" class="table table-striped table-bordered">
	<tbody>
		{% if not create %}
			<tr>
				<th>ID</th>
				<td>
					{{ blockregex.id }}
				</td>
			</tr>
		{% endif %}
		<tr>
			<th>Regex</th>
			<td class="form-group">
				<input type="text" id="regex" name="regex" value="{{ blockregex.regex }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>Comment</th>
			<td class="form-group">
				<input type="text" id="comment" name="comment" value="{{ blockregex.comment }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>Created</th>
			<td>
				{% if not create %}
					{{ blockregex.created }} ({{ blockregex.created | date }})
				{% else %}
					{{ time }} ({{ time | date }})
				{% endif %}
			</td>
		</tr>
		<tr>
			<th>Signup Name</th>
			<td class="form-group">
				<input type="checkbox" name="signup_name" id="signup_name" {%if blockregex.signup_name %}checked{% endif %} class="form-check-input">
			</td>
		</tr>
		<tr>
			<th>Signup Email</th>
			<td class="form-group">
				<input type="checkbox" name="signup_email" id="signup_email" {%if blockregex.signup_email %}checked{% endif %} class="form-check-input">
			</td>
		</tr>
		<tr>
			<th>Domain Name</th>
			<td class="form-group">
				<input type="checkbox" name="domain_name" id="domain_name" {%if blockregex.domain_name %}checked{% endif %} class="form-check-input">
			</td>
		</tr>
		<tr>
			<th>&nbsp;</th>
			<td>
				<a href="{{ url("/admin/blockregexes") }}" class="btn btn-block btn-warning">Cancel</a>
				<button type="submit" class="btn btn-block btn-success">{% if create %}Create{% else %}Edit{% endif %} BlockRegex</button>
			</td>
		</tr>
	</tbody>
</table>
</form>

<script src="{{ url('/assets/admin_blockregex.js') }}"></script>
