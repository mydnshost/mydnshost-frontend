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
				<textarea id="content" name="content" class="form-control form-control-sm" rows="6">{{ article.content }}</textarea>
			</td>
		</tr>
		<tr>
			<th>Created</th>
			<td>
				{% if not create %}
					{{ article.created | date }}
				{% else %}
					{{ time | date }}
				{% endif %}
			</td>
		</tr>
		<tr>
			<th>Visible From</th>
			<td class="form-group">
				<input type="datetime-local" id="visiblefrom_picker" class="form-control form-control-sm" required>
				<div class="invalid-feedback">Please select a valid date and time.</div>
				<input type="hidden" id="visiblefrom" name="visiblefrom" value="{{ create ? time : article.visiblefrom }}">
			</td>
		</tr>
		<tr>
			<th>Visible Until</th>
			<td class="form-group">
				<div class="d-flex align-items-center gap-2">
					<div class="flex-grow-1">
						<input type="datetime-local" id="visibleuntil_picker" class="form-control form-control-sm">
						<div class="invalid-feedback">Please select a valid date and time, or tick No expiry.</div>
					</div>
					<div class="form-check text-nowrap">
						<input type="checkbox" id="visibleuntil_never" class="form-check-input">
						<label class="form-check-label" for="visibleuntil_never">No expiry</label>
					</div>
				</div>
				<input type="hidden" id="visibleuntil" name="visibleuntil" value="{{ create ? -1 : article.visibleuntil }}">
			</td>
		</tr>
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
