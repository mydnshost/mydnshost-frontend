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
					<option value="{{ importType }}" {% if importType == type %}selected{% endif %}>{{ importType }}</option>
				{% endfor %}
			</select>
		</div>
	{% endif %}
	<div class="form-group">
		<button type="submit" class="btn btn-primary btn-block">Import Zone</button>
	</div>
</form>

<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-warning btn-block" role="button">Cancel</a>
