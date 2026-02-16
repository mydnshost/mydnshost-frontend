<H1>Article List</H1>

<input type="hidden" id="csrftoken" value="{{csrftoken}}">
<input class="form-control" data-search-top="table#articlelist" value="" placeholder="Search..."><br>

<div class="row mb-2">
	<div class="col">
		<div class="float-end">
			<a class="btn btn-success" href="{{ url('/admin/articles/create') }}">Add Article</a>
		</div>
	</div>
</div>

<table id="articlelist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">ID</th>
			<th class="title">Title</th>
			<th class="content">Content</th>
			<th class="visible text-nowrap">Visible From</th>
			<th class="visible text-nowrap">Visible Until</th>
			<th class="actions">Actions</th>
		</tr>
	</thead>
	<tbody>
		{% for article in articles %}
		<tr data-searchable-value="{{ article.title }}">
			<td class="id">
				{{ article.id }}
			</td>
			<td class="title">
				{{ article.title }}
			</td>
			<td class="content">
				{{ article.content }}
			</td>
			<td class="visible">
				{% if article.visiblefrom < time %}
					<span class="badge bg-success">{{ article.visiblefrom | date }}</span>
				{% else %}
					<span class="badge bg-warning">{{ article.visiblefrom | date }}</span>
				{% endif %}
			</td>
			<td class="visible">
				{% if article.visibleuntil == -1 %}
					<span class="badge bg-success">No expiry</span>
				{% elseif article.visibleuntil > time %}
					<span class="badge bg-success">{{ article.visibleuntil | date }}</span>
				{% else %}
					<span class="badge bg-danger">{{ article.visibleuntil | date }}</span>
				{% endif %}
			</td>
			<td class="actions text-nowrap">
				<a href="{{ url('/admin/articles/' ~ article.id) }}" class="btn btn-sm btn-success">View/Edit</a>
				<button data-action="deletearticle" data-id="{{ article.id }}" class="btn btn-sm btn-danger">Delete</button>
			</td>
		</tr>
		{% endfor %}
	</tbody>
</table>

{% embed 'blocks/modal_confirm.tpl' with {'id': 'confirmDelete'} only %}
	{% block title %}
		Delete Article
	{% endblock %}

	{% block body %}
		Are you sure you want to delete this Article?
	{% endblock %}
{% endembed %}

<script src="{{ url('/assets/admin_articles.js') }}"></script>
