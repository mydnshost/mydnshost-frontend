<br><br>

<H2>API Keys</H2>

<table id="apikeys" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
			<th class="domains_read">Domain Read</th>
			<th class="domains_write">Domain Write</th>
			<th class="user_read">User Read</th>
			<th class="user_write">User Write</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for key,keydata in apikeys %}
		<tr {% if editedaccess[email] %} data-edited="true"{% endif %} data-value="{{ key }}">
			<td class="key">
				<span class="pointer" data-hiddenText="{{ key }}"><em>Hidden - click to view</em></span>
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}">
				{{ keydata.description }}
			</td>
			<td class="domains_read" data-radio data-name="domains_read" data-value="{{ keydata.domains_read | yesno }}">
				{% if keydata.domains_read == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="domains_write" data-radio data-name="domains_write" data-value="{{ keydata.domains_write | yesno }}">
				{% if keydata.domains_write == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="user_read" data-radio data-name="user_read" data-value="{{ keydata.user_read | yesno }}">
				{% if keydata.user_read == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="user_write" data-radio data-name="user_write" data-value="{{ keydata.user_write | yesno }}">
				{% if keydata.user_write == 'true' %}
					<span class="badge badge-success">Yes</span>
				{% else %}
					<span class="badge badge-danger">No</span>
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="editkey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="savekey" class="hidden btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="deletekey" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline editform" method="post" action="{{ url('/profile/editkey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/deletekey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url('/profile/addkey') }}" class="form-inline form-group" id="addkeyform">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">
	<button type="submit" class="btn btn-success" role="button">Add API Key</button>
</form>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete'} only %}
	{% block title %}
		Delete API Key
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this API Key?
		<br><br>
		Deleting this key will cause any applications using it to no longer have access to the api.
		<br><br>
		This can not be undone and any applications will need to be updated to use a new key.
	{% endblock %}
{% endembed %}
