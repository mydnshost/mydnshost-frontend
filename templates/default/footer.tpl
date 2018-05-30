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
						<div class="form-group row">
							<label for="domainname" class="col-4 col-form-label">Domain Name</label>
							<div class="col-8">
								<input class="form-control" type="text" value="" id="domainname" name="domainname">
							</div>
						</div>
					</form>
				{% endblock %}

				{% block buttons %}
					<button type="button" data-action="cancel" class="btn btn-primary" data-dismiss="modal">Cancel</button>
					<button type="button" data-action="ok" class="btn btn-success">Ok</button>
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
