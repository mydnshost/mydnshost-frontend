				</main>
			</div>
		</div>

		{% if hasPermission(['domains_create']) %}
			{% embed 'blocks/modal_confirm.tpl' with {'id': 'createUserDomain', 'csrftoken': csrftoken} only %}
				{% block title %}
					Create Domain
				{% endblock %}

				{% block body %}
					<form id="createUserDomainForm" method="post" action="{{ url('/domains/create') }}">
						<input type="hidden" name="csrftoken" value="{{csrftoken}}">
						{% include 'blocks/domain_create_form.tpl' with {'hide_owner': true} %}
					</form>
				{% endblock %}

				{% block buttons %}
					<button type="button" data-action="cancel" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
					<button type="button" data-action="ok" class="btn btn-success">Ok</button>
				{% endblock %}
			{% endembed %}
		{% endif %}

		{% embed 'blocks/modal_confirm.tpl' with {'id': 'findRecordsModal', 'large': true, 'csrftoken': csrftoken} only %}
		{% block title %}
			Find Domain by Records
		{% endblock %}

		{% block body %}
			<form id="findRecordsForm" method="post" action="{{ url('/domains/findRecords') }}">
				<input type="hidden" name="csrftoken" value="{{csrftoken}}">
				{% include 'blocks/find_records_form.tpl' %}
			</form>
		{% endblock %}

		{% block buttons %}
			<button type="button" data-action="cancel" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
			<button type="button" data-action="ok" class="btn btn-success">Find Domains</button>
		{% endblock %}
	{% endembed %}

	{% embed 'blocks/modal_confirm.tpl' with {'id': 'createLabelModal'} only %}
		{% block title %}
			Create Label
		{% endblock %}

		{% block body %}
			<div class="form-group row">
				<label for="createLabelName" class="col-4 col-form-label">Label Name</label>
				<div class="col-8">
					<input class="form-control" type="text" value="" id="createLabelName" name="createLabelName">
				</div>
			</div>
			<input type="hidden" id="createLabelDomain" value="">
		{% endblock %}

		{% block buttons %}
			<button type="button" data-action="cancel" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
			<button type="button" data-action="ok" class="btn btn-success">Create</button>
		{% endblock %}
	{% endembed %}

	{% embed 'blocks/modal_confirm.tpl' with {'id': 'renameLabelModal'} only %}
			{% block title %}
				Rename Label
			{% endblock %}

			{% block body %}
				<div class="form-group row">
					<label for="newLabelName" class="col-4 col-form-label">New Label Name</label>
					<div class="col-8">
						<input class="form-control" type="text" value="" id="newLabelName" name="newLabelName">
					</div>
				</div>
				<input type="hidden" id="oldLabelName" value="">
			{% endblock %}

			{% block buttons %}
				<button type="button" data-action="cancel" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
				<button type="button" data-action="ok" class="btn btn-success">Rename</button>
			{% endblock %}
		{% endembed %}

	{% if shouldShowElevateButton() %}
		{% embed 'blocks/modal_confirm.tpl' with {'id': 'elevateModal'} %}
			{% block title %}
				Admin Elevation
			{% endblock %}

			{% block body %}
				<p>Additional verification is required for admin write operations.</p>
				<form id="elevateForm" method="post" action="{{ url('/admin/elevate') }}">
					<input type="hidden" name="csrftoken" value="{{csrftoken}}">
					<input type="hidden" name="redirect" value="" id="elevateRedirect">
					{% include 'admin/blocks/elevate_form.tpl' %}
				</form>
			{% endblock %}

			{% block buttons %}
				<button type="button" data-action="cancel" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
				<button type="button" data-action="ok" class="btn btn-warning">Elevate</button>
			{% endblock %}
		{% endembed %}
	{% endif %}

		<footer class="footer">
			<div class="container-fluid">
				<hr>
				<p class="text-muted">
						<small>{% block footerdata %}<a href="https://github.com/mydnshost">mydnshost</a> - &copy; Shane 'Dataforce' Mc Cormack{% endblock %}</small>
				</p>
			</div>
		</footer>

		<script src="{{ url('/assets/script.js') }}"></script>
	</body>
</html>
