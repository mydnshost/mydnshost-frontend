{% if not create %}
	<tr id="article-id-row">
		<th>ID</th>
		<td id="article-id-display">
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
	<td id="article-created-display">
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
