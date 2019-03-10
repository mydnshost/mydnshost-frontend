<H1>Article :: {{ article.id }}</H1>

<input type="hidden" id="csrftoken" value="{{csrftoken}}">

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
			<td>
				<input type="text" name="title" value="{{ article.title }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>Content</th>
			<td>
				<textarea name="content" class="form-control form-control-sm">{{ article.content }}</textarea>
			</td>
		</tr>
		<tr>
			<th>Full Content</th>
			<td>
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
			<td>
				<input type="text" name="visiblefrom" value="{{ article.visiblefrom }}" class="form-control form-control-sm">
			</td>
		</tr>
		<tr>
			<th>Visible Until</th>
			<td>
				<input type="text" name="visibleuntil" value="{{ article.visibleuntil }}" class="form-control form-control-sm">
			</td>
		</tr>
	</tbody>
</table>

<script src="{{ url('/assets/admin_article.js') }}"></script>
