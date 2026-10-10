<H1>
	Domain :: {{ domain.domain }} :: Import
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

Import records from zone file.
<br><br>
<div class="alert alert-danger" role="alert">
	<strong>Warning:</strong> This will replace all existing records for this domain with the records provided in the zone file.
</div>
<form method="post">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<div class="form-group">
		<textarea rows="20" class="form-control mono" name="zone" id="zone">{{ zone | join("\n") }}</textarea>
	</div>
	{% if importTypes and importTypes|length > 1 %}
		<div class="form-group">
			Zone Format: <select name="type" class="form-control">
				{% for importType in importTypes %}
					<option value="{{ importType }}" {% if importType == type %}selected{% endif %}>
						{{ importType }}{% if descriptions[importType] %} - {{ descriptions[importType] }}{% endif %}
					</option>
				{% endfor %}
			</select>
		</div>
	{% endif %}
	{% if defaultNS %}
		<div class="form-check mt-2">
			<input class="form-check-input" type="checkbox" name="replaceNameservers" value="true" id="replaceNameservers" {% if replaceNameservers %}checked{% endif %}>
			<label class="form-check-label" for="replaceNameservers">
				Replace the nameservers in the zone file with ours (<code>{{ defaultNS | join(', ') }}</code>)
			</label>
			<div class="form-text">
				Zone files exported from another DNS provider will usually list that provider's nameservers. Domain-level <code>NS</code> records in the zone file will be replaced with ours, and the primary nameserver in the <code>SOA</code> will be updated to match. <code>NS</code> records for sub-domains are not changed.
			</div>
		</div>
	{% endif %}
	<div class="form-group">
		<div class="d-grid mt-2 gap-2">
			<button type="submit" class="btn btn-primary" data-needs-elevation>Import Zone</button>
		</div>
	</div>
</form>

<div class="d-grid mt-2 gap-2">
	<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-warning" role="button">Cancel</a>
</div>
