<br><br>

<H2>2FA Keys</H2>

Here you can see what 2FA Keys have been added to your account. If you have an active 2FA key assigned, you will need to provide the code from at least one of the active keys when ever you log in with a username and password.
<br><br>
You will only be able to see the key and associated QR code for any keys that have not yet been activated.
<br><br>
<table id="twofactorkeys" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="key">Key</th>
			<th class="description">Description</th>
			<th class="lastused">Last Used</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for key,keydata in twofactorkeys %}
		<tr data-value="{{ key }}">
			<td class="key">
				{% if keydata.key %}
					<div class="inactive">
						<div class="key">
							<strong>{{ keydata.key }}</strong>
							<br>
							<img src="{{ keydata.key | get2FAQRCode }}" alt="{{ keydata.key }}">
						</div>
						<div class="verifykey">
							<em>This key is not yet active, please activate the key by submitting a valid code from it</em>
							<br><br>
							<form class="verifyform" method="post" action="{{ url('/profile/verify2fakey/' ~ key) }}">
								<input type="hidden" name="csrftoken" value="{{csrftoken}}">
								<input type="text" name="code" placeholder="000000">
								<br><br>
								<button type="submit" class="btn btn-sm btn-success" role="button">Activate Key</button>
							</form>
						</div>
					</div>
				{% else %}
					<em>Hidden - key is active</em>
				{% endif %}
			</td>
			<td class="description" data-text data-name="description" data-value="{{ keydata.description }}">
				{{ keydata.description }}
			</td>
			<td class="lastused">
				{% if keydata.lastused == 0 %}
					<em>Never</em>
				{% else %}
					{{ keydata.lastused | date }}
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="edit2fakey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="save2fakey" class="hidden btn btn-sm btn-success" role="button">Save</button>
				<button type="button" data-action="delete2fakey" class="btn btn-sm btn-danger" role="button">Delete</button>

				<form class="d-inline form-inline editform" method="post" action="{{ url('/profile/edit2fakey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
				<form class="d-inline form-inline deleteform" method="post" action="{{ url('/profile/delete2fakey/' ~ key) }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				</form>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

<form method="post" action="{{ url('/profile/add2fakey') }}" class="form-inline form-group" id="add2faform">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">
	<button type="submit" class="btn btn-success" role="button">Add 2FA Key</button>
</form>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete2FA'} only %}
	{% block title %}
		Delete 2FA Key
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this 2FA Key?
		<br><br>
		Deleting this key will prevent logins using this device.
		<br><br>
		This can not be undone and you will need to re-enroll your device again.
	{% endblock %}
{% endembed %}
