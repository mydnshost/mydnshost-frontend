{% if not create %}
	<tr id="blockregex-id-row">
		<th>ID</th>
		<td id="blockregex-id-display">
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
	<td id="blockregex-created-display">
		{% if not create %}
			{{ blockregex.created | date }}
		{% else %}
			{{ time | date }}
		{% endif %}
	</td>
</tr>
<tr>
	<th>Signup Name</th>
	<td class="form-group">
		<input type="checkbox" name="signup_name" id="signup_name" {%if blockregex.signup_name %}checked{% endif %} class="">
	</td>
</tr>
<tr>
	<th>Signup Email</th>
	<td class="form-group">
		<input type="checkbox" name="signup_email" id="signup_email" {%if blockregex.signup_email %}checked{% endif %} class="">
	</td>
</tr>
<tr>
	<th>Domain Name</th>
	<td class="form-group">
		<input type="checkbox" name="domain_name" id="domain_name" {%if blockregex.domain_name %}checked{% endif %} class="">
	</td>
</tr>
