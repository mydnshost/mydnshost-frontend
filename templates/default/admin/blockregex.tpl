{% if create %}
<H1>Block Regex :: Create</H1>
<form action="{{ url('/admin/blockregexes/create') }}" method="POST" id="blockregexform">
{% else %}
<H1>BlockRegex :: {{ blockregex.id }}</H1>
<form action="{{ url('/admin/blockregexes/' ~ blockregex.id) }}" method="POST" id="blockregexform">
{% endif %}
<input type="hidden" name="csrftoken" value="{{csrftoken}}">

<table id="blockregex" class="table table-striped table-bordered table-layout-fixed">
	<colgroup>
		<col style="width: 300px;">
		<col>
	</colgroup>
	<tbody>
		{% include 'admin/blocks/blockregex_form.tpl' %}
		<tr>
			<th>&nbsp;</th>
			<td>
				<div class="d-flex gap-2 mt-2">
					<a href="{{ url("/admin/blockregexes") }}" class="btn btn-warning">Cancel</a>
					<button type="submit" class="btn btn-success">{% if create %}Create{% else %}Edit{% endif %} BlockRegex</button>
				</div>
			</td>
		</tr>
	</tbody>
</table>
</form>

<script src="{{ url('/assets/admin_blockregex.js') }}"></script>
