<br><br>

<H2>2FA Keys</H2>
<p>
Here you can see what 2FA Keys have been added to your account. If you have an active 2FA key assigned, you will need to provide the code from at least one of the active keys when ever you log in with a username and password.
</p><p>
You will only be able to see the key and associated QR code for any keys that have not yet been activated.
</p>
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
			<td class="lastused {% if keydata.lastused < keyoldcutoff %}text-danger{% elseif keydata.lastused < keycutoff %}text-warning{% endif %}">
				{% if keydata.lastused == 0 %}
					<em>Never</em>
				{% else %}
					{{ keydata.lastused | date }}
				{% endif %}
			</td>
			<td class="actions">
				<button type="button" data-action="edit2fakey" class="btn btn-sm btn-success" role="button">Edit</button>
				<button type="button" data-action="save2fakey" class="d-none btn btn-sm btn-success" role="button">Save</button>
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


<button type="button" id="showadd2fa" class="btn btn-success mt-3" role="button">Add 2FA Key</button>

<div class="card mt-3 d-none" id="add2facard">
	<div class="card-header">Add 2FA Key</div>
	<div class="card-body">
		<form method="post" action="{{ url('/profile/add2fakey') }}" id="add2faform">
			<input type="hidden" name="csrftoken" value="{{csrftoken}}">
			<div class="row g-3">
				<div class="col-md-4">
					<label for="add2fa_type" class="form-label">Type</label>
					<select class="form-control" name="type" id="add2fa_type">
						<option value="rfc6238" selected>TOTP (RFC 6238)</option>
						<option value="onetime">One Time</option>
						{% if 'yubikeyotp' in twoFactorKeyTypes %}
							<option value="yubikeyotp" data-need="secret">Yubikey OTP</option>
						{% endif %}
						{% if 'authy' in twoFactorKeyTypes %}
							<option value="authy" data-need="phone">Authy</option>
						{% endif %}
					</select>
				</div>
				<div class="col-md-8">
					<label for="add2fa_description" class="form-label">Description</label>
					<input class="form-control" type="text" name="description" id="add2fa_description" value="" placeholder="Key description...">
				</div>
				<div class="col-md-12">
					<label data-provide="secret" for="add2fa_secret" class="form-label">Key Data</label>
					<input data-provide="secret" class="form-control" type="text" name="secret" id="add2fa_secret" value="" placeholder="Key data">
				</div>
				<div class="col-md-4">
					<label data-provide="phone" for="add2fa_countrycode" class="form-label">Country Code</label>
					<input data-provide="phone" class="form-control" type="text" name="countrycode" id="add2fa_countrycode" value="" placeholder="+44">
				</div>
				<div class="col-md-8">
					<label data-provide="phone" for="add2fa_phone" class="form-label">Phone Number</label>
					<input data-provide="phone" class="form-control" type="text" name="phone" id="add2fa_phone" value="" placeholder="Phone number">
				</div>
			</div>
			<div class="mt-3">
				<button type="submit" class="btn btn-success" role="button">Add</button>
				<button type="button" id="canceladd2fa" class="btn btn-warning" role="button">Cancel</button>
			</div>
		</form>
	</div>
</div>

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
