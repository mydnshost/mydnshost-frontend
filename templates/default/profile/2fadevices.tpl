<br><br>

<H2>Known Devices</H2>
<p>
Here you can see what devices have been saved to allow logging in without 2FA.
</p>
<table id="twofactordevices" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="description">Description</th>
			<th class="lastused">Last Used</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for device,devicedata in twofactordevices %}
		<tr data-value="{{ device }}">
			<td class="description" data-text data-name="description">
				{{ devicedata.description }}
				{% if devicedata.current %}
					<small>(This device)</small>
				{% endif %}
			</td>
			<td class="lastused {% if devicedata.lastused < keyoldcutoff %}text-danger{% elseif devicedata.lastused < keycutoff %}text-warning{% endif %}">
				{% if devicedata.lastused == 0 %}
					<em>Never</em>
				{% else %}
					{{ devicedata.lastused | date }}
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="delete2fadevice" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/delete2fadevice/' ~ device) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete2FADevice'} only %}
	{% block title %}
		Delete Device
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this Device?
		<br><br>
		This will cause logins from this device to require 2FA again to login.
	{% endblock %}
{% endembed %}
