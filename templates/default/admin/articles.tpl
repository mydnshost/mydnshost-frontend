<H1>Article List</H1>

<input type="hidden" id="csrftoken" value="{{csrftoken}}">
<input class="form-control" data-search-top="table#articlelist" value="" placeholder="Search..."><br>

<div class="float-right">
	<a class="btn btn-block btn-success" href="{{ url('/admin/articles/create') }}">Add Article</a>
</div>
<br><br>

<table id="articlelist" class="table table-striped table-bordered">
	<thead>
		<tr>
			<th class="id">ID</th>
			<th class="title">Title</th>
			<th class="content">Content</th>
			<th class="visible">Visible</th>
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
				{% set visible = article.visiblefrom < time and (article.visibleuntil == -1 or article.visibleuntil > time) %}

				<span class="value badge {% if visible %}badge-success{% else %}badge-danger{% endif %}">
					{{ visible | yesno }}
				</span>
			</td>
			<td class="actions">
				{% if userinfo.email != user.email %}
					<a href="{{ url('/admin/articles/' ~ article.id) }}" class="btn btn-sm btn-success">View/Edit</a>
					<button data-action="deletearticle" data-id="{{ article.id }}" class="btn btn-sm btn-danger">Delete</a>
				{% endif %}
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
