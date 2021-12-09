{% if create %}
<H1>Article :: Create</H1>
<form action="{{ url('/admin/articles/create') }}" method="POST" id="articleform">
{% else %}
<H1>Article :: {{ article.id }}</H1>
<form action="{{ url('/admin/articles/' ~ article.id) }}" method="POST" id="articleform">
{% endif %}
<input type="hidden" name="csrftoken" value="{{csrftoken}}">

<table id="article" class="table table-striped table-bordered">
	<tbody>
		{% if not create %}
			<tr>
				<th>ID</th>
				<td>
					{{ article.id }}
				</td>
			</tr>
		{% endif %}
		<tr>
			<th>Title</th>
			<td class="form-group">
				<input type="text" id="title" name="title" value="{{ article.title }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>Content</th>
			<td class="form-group">
				<textarea id="content" name="content" class="form-control form-control-sm">{{ article.content }}</textarea>
			</td>
		</tr>
		<tr>
			<th>Full Content</th>
			<td class="form-group">
				<textarea name="contentfull" class="form-control form-control-sm">{{ article.contentfull }}</textarea>
			</td>
		</tr>
		<tr>
			<th>Created</th>
			<td>
				{% if not create %}
					{{ article.created }} ({{ article.created | date }})
				{% else %}
					{{ time }} ({{ time | date }})
				{% endif %}
			</td>
		</tr>
		<tr>
			<th>Visible From</th>
			<td class="form-group">
				<input type="text" id="visiblefrom" name="visiblefrom" value="{{ article.visiblefrom }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>Visible Until</th>
			<td class="form-group">
				<input type="text" id="visibleuntil" name="visibleuntil" value="{{ article.visibleuntil }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>&nbsp;</th>
			<td>
				<div class="d-grid mt-2 gap-2">
					<a href="{{ url("/admin/articles") }}" class="btn btn-warning">Cancel</a>
					<button type="submit" class="btn btn-success">{% if create %}Create{% else %}Edit{% endif %} Article</button>
				</div>
			</td>
		</tr>
	</tbody>
</table>
</form>

<script src="{{ url('/assets/admin_article.js') }}"></script>
