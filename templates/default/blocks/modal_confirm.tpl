<!-- Modal -->
<div class="modal fade" id="{{ id }}" tabindex="-1" role="dialog" aria-labelledby="{{ id }}Label" aria-hidden="true" data-bs-backdrop="static">
	<div class="modal-dialog{% if large %} modal-lg{% endif %}" role="dialog">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="{{ id }}Label">{% block title %}{% endblock %}</h5>
			</div>
			<div class="modal-body">
				{% block body %}{% endblock %}
			</div>
			<div class="modal-footer">
				{% block buttons %}
					<button type="button" data-action="cancel" class="btn btn-primary" data-bs-dismiss="modal">Cancel</button>
					<button type="button" data-action="ok" class="btn btn-success" data-bs-dismiss="modal">Ok</button>
				{% endblock %}
			</div>
		</div>
	</div>
</div>
