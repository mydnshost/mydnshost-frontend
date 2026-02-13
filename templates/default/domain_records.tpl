{% if not hasNS %}
<div class="alert alert-danger alert-dismissible fade show" role="alert">
	<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
	<h4 class="alert-heading">Domain Error</h4>
	<p>
		This domain does not have any valid nameservers and will not currently be served. Please add at least 1 valid NS record.
	</p>
	{% if defaultNS %}
	<p>
		Our nameserver records are:
		<ul>
			{% for ns in defaultNS %}
				<li>{{ ns }}</li>
			{% endfor %}
		</ul>
	</p>
	{% endif %}
</div>
{% endif %}
<H1>
	Domain :: {{ domain.domain }} :: Records
	{% if subtitle %}<small class="subtitle">({{ subtitle }})</small>{% endif %}
</H1>
<p>
This is where you can add/edit/remove records for the domain.
</p>
<p>
Please note that all record names will have '<code>.{{ domain.domain }}</code>' appended to them, and all content will be saved as-is without anything appended, so you do not need to add a trailing '<code>.</code>' to content.
</p>

<div class="row">
	<div class="col">
		<div class="float-end">
			<a href="{{ url("#{pathprepend}/domain/#{domain.domain}") }}" class="btn btn-primary" role="button">Zone details</a>
			<br>
			<br>
		</div>
	</div>
</div>

{% if has_domain_write %}
<form method="post" id="recordsform">
<input type="hidden" name="csrftoken" value="{{csrftoken}}">
{% endif %}
<table id="soainfo" class="table table-striped table-bordered form-group">
	<tbody>
		<tr>
			<th>Serial Number</th>
			<td class="mono">{{ domain.SOA.serial }}</td>
		</tr>
	</tbody>
</table>

<table id="records" class="table table-striped table-bordered" data-default-rr="{% if rdns %}PTR{% else %}A{% endif %}">
	<thead>
		<tr>
			<th class="name">Name</th>
			<th class="type">Type</th>
			<th class="priority">Priority</th>
			<th class="content">Content</th>
			<th class="ttl">TTL</th>
			<th class="state">Disabled</th>
			{% if has_domain_write %}
			<th class="actions">Actions</th>
			{% endif %}
		</tr>
		<tr class="filter-row">
			<th><input type="text" class="form-control form-control-sm" data-filter="name" placeholder="Filter..."></th>
			<th id="typeFilterCell"></th>
			<th><input type="number" class="form-control form-control-sm" data-filter="priority" placeholder="Filter..." min="0"></th>
			<th><input type="text" class="form-control form-control-sm" data-filter="content" placeholder="Filter..."></th>
			<th><input type="number" class="form-control form-control-sm" data-filter="ttl" placeholder="Filter..." min="0"></th>
			<th><input type="text" class="form-control form-control-sm" data-filter="state" placeholder="Filter..."></th>
			{% if has_domain_write %}
			<th><button type="button" class="btn btn-sm btn-outline-light d-none" id="clearFilters">Clear</button></th>
			{% endif %}
		</tr>
	</thead>
	<tbody>
		{% for record in records %}
		<tr data-id="{{ record.id }}" class="{% if record.disabled == 'true' or record.edited.disabled == 'true' %}disabled{% endif %}"
			{% if record.edited %}data-edited="true"{% endif %}
			{% if record.deleted %}data-deleted="true"{% endif %}
			{% if record.errorData %}data-error-data="{{ record.errorData }}"{% endif %}
			>

			<td class="name mono" data-value="{{ record.name }}" data-comment="{{ record.comment }}" data-subtitle="{{ record.subtitle }}" {% if record.edited %}data-edited-value="{{ record.edited.name }}"  data-edited-comment="{{ record.edited.comment }}"{% endif %}
				{% if endsWith(record.name, '.' ~ domain.domain) %}data-warning-data="You probably do not need to include '.{{domain.domain}}' here."{% endif %}
				{% if record.name == domain.domain %}data-warning-data="You probably want to use '@' not '{{domain.domain}}' here."{% endif %}
				>
				{% if record.name == '' %}
					@
				{% else %}
					{{ record.name }}
				{% endif %}
				{% if record.comment != '' %}
					<span class="badge bg-info comment-badge" title="{{ record.comment }}">!</span>
				{% endif %}
				{% if record.subtitle != '' %}
					<br><small><em>{{ record.subtitle }}</em></small>
				{% endif %}
			</td>
			<td class="type mono" data-value="{{ record.type }}" {% if record.edited %}data-edited-value="{{ record.edited.type }}"{% endif %}>
				{{ record.type }}
			</td>
			<td class="priority mono" data-value="{{ record.priority }}" {% if record.edited %}data-edited-value="{{ record.edited.priority }}"{% endif %}>
				{{ record.priority }}
			</td>
			<td class="content mono" data-value="{{ record.content }}" {% if record.edited %}data-edited-value="{{ record.edited.content }}"{% endif %}>
				{{ record.content }}
			</td>
			<td class="ttl mono" data-value="{{ record.ttl }}" {% if record.edited %}data-edited-value="{{ record.edited.ttl }}"{% endif %}>
				{{ record.ttl }}
			</td>
			<td class="state" data-value="{{ record.disabled | yesno }}" {% if record.edited %}data-edited-value="{{ record.edited.disabled | yesno }}"{% endif %}>
				{% if record.disabled == 'true' or record.edited.disabled == 'true' %}
					<span class="badge bg-danger">
				{% else %}
					<span class="badge bg-success">
				{% endif %}
					{{ record.disabled | yesno }}
				</span>
			</td>
			{% if has_domain_write %}
				<td class="actions">
					<button type="button" class="btn btn-sm btn-success" data-action="edit" role="button">Edit</button>
					<button type="button" class="btn btn-sm btn-danger" data-action="delete" role="button">Delete</button>
				</td>
			{% endif %}
		</tr>
		{% endfor %}


		{% if has_domain_write %}
			{% for id,record in newRecords %}
			<tr class="new form-group" data-edited="true" {% if record.errorData %}data-error-data="{{ record.errorData }}"{% endif %}>
				<td class="name" data-edited-value="{{record.name }}" data-edited-comment="{{ record.comment }}"></td>
				<td class="type" data-edited-value="{{record.type }}"></td>
				<td class="priority" data-edited-value="{{record.priority }}"></td>
				<td class="content" data-edited-value="{{record.content }}"></td>
				<td class="ttl" data-edited-value="{{record.ttl }}"></td>
				<td class="ttl" data-edited-value="No"></td>
				<td class="actions">
					<button type="button" class="btn btn-sm btn-success" data-action="edit" role="button">Edit</button>
					<button type="button" class="btn btn-sm btn-warning" data-action="deletenew" role="button">Cancel</button>
				</td>
			</tr>
			{% endfor %}
		{% endif %}

	</tbody>
</table>

<script>$(function() { $('#records .comment-badge').tooltip({placement: 'right'}); });</script>

{% if has_domain_write %}
<div id="actionbuttonsfiller" class="row"></div>
<div id="actionbuttons" class="row">
    {% if nosidebar is defined and nosidebar %}
      {% set showsidebar = false %}
    {% elseif user %}
      {% set showsidebar = true %}
    {% else %}
      {% set showsidebar = false %}
    {% endif %}

	{% if showsidebar %}
		<div class="col-sm-9 col-md-10 pt-3">
	{% else %}
		<div class="col-sm-12 pt-3">
	{% endif %}
		<div class="d-grid mt-2 gap-2">
			<button type="button" class="btn btn-primary" data-action="add" role="button">Add Record</button>
			<br>
			<button type="button" class="btn btn-warning" data-action="reset" role="button">Reset Changes</button>
			<button type="submit" class="btn btn-success" role="button">Save Changes</button>
		</div>
	</div>
</div>
</form>

<script src="{{ url('/assets/records.js') }}"></script>
{% endif %}

<script src="{{ url('/assets/record_types.js') }}"></script>
<script src="{{ url('/assets/records_filter.js') }}"></script>
