{% if create %}
<H1>Article :: Create</H1>
<form action="{{ url('/admin/articles/create') }}" method="POST" id="articleform">
{% else %}
<H1>Article :: {{ article.id }}</H1>
<form action="{{ url('/admin/articles/' ~ article.id) }}" method="POST" id="articleform">
{% endif %}
<input type="hidden" name="csrftoken" value="{{csrftoken}}">

<table id="article" class="table table-striped table-bordered table-layout-fixed">
	<colgroup>
		<col style="width: 300px;">
		<col>
	</colgroup>
	<tbody>
		{% include 'admin/blocks/article_form.tpl' %}
		<tr>
			<th>&nbsp;</th>
			<td>
				<div class="d-flex gap-2 mt-2">
					<a href="{{ url("/admin/articles") }}" class="btn btn-warning">Cancel</a>
					<button type="submit" class="btn btn-success">{% if create %}Create{% else %}Edit{% endif %} Article</button>
				</div>
			</td>
		</tr>
	</tbody>
</table>
</form>

<script src="{{ url('/assets/admin_article.js') }}"></script>
