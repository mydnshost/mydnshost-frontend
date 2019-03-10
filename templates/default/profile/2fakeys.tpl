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
			<th class="type">Type</th>
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
							{% if keydata.type == 'rfc6238' %}
								<br>
								<img src="{{ keydata.key | getRFC6238QRCode }}" alt="{{ keydata.key }}">
							{% endif %}
						</div>
						<div class="verifykey">
							{% if keydata.type == 'rfc6238' or keydata.type == 'yubikeyotp' %}
								<em>This key is not yet active, please activate the key by submitting a valid code from it</em>
								<br><br>
								<form class="verifyform" method="post" action="{{ url('/profile/verify2fakey/' ~ key) }}">
									<input type="hidden" name="csrftoken" value="{{csrftoken}}">
									<input type="text" name="code" placeholder="000000">
									<br><br>
									<button type="submit" class="btn btn-sm btn-success" role="button">Activate Key</button>
								</form>
							{% else %}
								<em>This key is not yet active.</em>
								<br><br>
								<form class="verifyform" method="post" action="{{ url('/profile/verify2fakey/' ~ key) }}">
									<input type="hidden" name="csrftoken" value="{{csrftoken}}">
									<input type="hidden" name="code" value="{{ keydata.key }}">
									<button type="submit" class="btn btn-sm btn-success" role="button">Activate Key</button>
								</form>
							{% endif %}
						</div>
					</div>
				{% elseif not keydata.usable %}
					<em>Hidden. (Key has expired)</em>
				{% else %}
					<em>Hidden. (Key is active)</em>
				{% endif %}
			</td>
			<td class="type" data-text data-name="type" data-value="{{ keydata.type }}">
				{% if keydata.onetime %}
					One Time
				{% endif %}
				{{ keydata.type | capitalize }}
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
	<select class="form-control col-2 mb-2 mr-sm-2 mb-sm-0" name="type">
		<option value="rfc6238" selected>TOTP (RFC 6238)</option>
		<option value="onetime">One Time</option>
		{% if 'yubikeyotp' in twoFactorKeyTypes %}
			<option value="yubikeyotp" data-need="secret">Yubikey OTP</option>
		{% endif %}
		{% if 'authy' in twoFactorKeyTypes %}
			<option value="authy" data-need="phone">Authy Push</option>
		{% endif %}
	</select>
	<input class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="description" value="" placeholder="Key description...">

	<input data-provide="secret" class="form-control col-3 mb-2 mr-sm-2 mb-sm-0" type="text" name="secret" value="" placeholder="Key data">
	<input data-provide="phone" class="form-control col-1 mb-2 mr-sm-2 mb-sm-0" type="text" name="countrycode" value="" placeholder="Country Code">
	<input data-provide="phone" class="form-control col-2 mb-2 mr-sm-2 mb-sm-0" type="text" name="phone" value="" placeholder="Phone Number">

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
