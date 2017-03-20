				</main>
			</div>
		</div>

		{% if hasPermission(['domains_create']) %}
			{% embed 'blocks/modal_confirm.tpl' with {'id': 'createUserDomain'} only %}
				{% block title %}
					Create Domain
				{% endblock %}

				{% block body %}
					<form id="createUserDomainForm" method="post" action="{{ url('/domains/create') }}">
						<div class="form-group row">
							<label for="domainname" class="col-4 col-form-label">Domain Name</label>
							<div class="col-8">
								<input class="form-control" type="text" value="" id="domainname" name="domainname">
							</div>
						</div>
					</form>
				{% endblock %}
			{% endembed %}
		{% endif %}

		<script src="{{ url('/assets/script.js') }}"></script>
	</body>
</html>
