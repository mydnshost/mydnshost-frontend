<H1>Block Regex List</H1>

<input type="hidden" id="csrftoken" value="{{csrftoken}}">
<input class="form-control" data-search-top="table#blockregexlist" value="" placeholder="Search..."><br>

<div class="float-end">
	<div class="d-grid mt-2 gap-2">
		<a class="btn btn-success" href="{{ url('/admin/blockregexes/create') }}">Add Block Regex</a>
	</div>
</div>
<br><br>

<table id="articlelist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">ID</th>
			<th class="regex">Regex</th>
			<th class="comment">Comment</th>
			<th class="signupname">Signup Name</th>
			<th class="signupemail">Signup Email</th>
			<th class="domainname">Domain Name</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for blockregex in blockregexes %}
		<tr data-searchable-value="{{ blockregex.comment }}">
			<td class="id">
				{{ blockregex.id }}
			</td>
			<td class="regex">
				<pre>{{ blockregex.regex }}</pre>
			</td>
			<td class="comment">
				{{ blockregex.comment }}
			</td>
			<td class="signupname">
				<span class="value badge {% if blockregex.signup_name %}bg-success{% else %}bg-danger{% endif %}">
					{{ blockregex.signup_name | yesno }}
				</span>
			</td>
			<td class="signupemail">
				<span class="value badge {% if blockregex.signup_email %}bg-success{% else %}bg-danger{% endif %}">
					{{ blockregex.signup_email | yesno }}
				</span>
			</td>
			<td class="domainname">
				<span class="value badge {% if blockregex.domain_name %}bg-success{% else %}bg-danger{% endif %}">
					{{ blockregex.domain_name | yesno }}
				</span>
			</td>

			<td class="actions">
				<a href="{{ url('/admin/blockregexes/' ~ blockregex.id) }}" class="btn btn-sm btn-success">View/Edit</a>
				<button data-action="deleteblockregex" data-id="{{ blockregex.id }}" class="btn btn-sm btn-danger">Delete</a>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete'} only %}
	{% block title %}
		Delete Block Regex
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this Block Regex?
	{% endblock %}
{% endembed %}

<script src="{{ url('/assets/admin_blockregexes.js') }}"></script>
