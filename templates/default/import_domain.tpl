<H1>
	Domain :: {{ domain.domain }} :: Import
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>

Import records from bind zone file.
<br><br>
<div class="alert alert-danger" role="alert">
	<strong>Warning:</strong> This will replace all existing records for this domain with the records provided in the zone file.
</div>
<form method="post">
	<input type="hidden" name="csrftoken" value="{{csrftoken}}">
	<div class="form-group">
		<textarea rows="20" class="form-control mono" name="zone" id="zone">{{ zone | join("\n") }}</textarea>
	</div>
	<div class="form-group">
		<button type="submit" class="btn btn-primary btn-block">Import Zone</button>
	</div>
</form>

<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-warning btn-block" role="button">Cancel</a>
