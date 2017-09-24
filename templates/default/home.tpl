<H1>Home</H1>
{% embed '@default/index.tpl' with {'id': 'deleteModal'} %}
	{% block containerwrapper %}<div class="container-fluid">{% endblock %}
	{% block jumbotron %}
	<div class="row jumbotron news">
      <div class="col">
        <h2>News</h2>
        <p>
          <strong>2017-09-24 - Domain display default page.</strong>
          <br>
          A new setting has been added to the user-profile to change the default
          page displayed when viewing a domain to be either the "Records" or
          "Zone Details" page.
        </p>
        <p>
          <strong>2017-09-13 - DNSSEC Support is now live.</strong>
          <br>
          Zones are automatically signed, with DS records available in the zone
          details section.
        </p>
        <p>
		  <strong>2017-09-10 - Domain Statistics.</strong>
		  <br>
		  Domain query statistics are now available from the API and from the
		  zone details section.
        </p>
      </div>
     </div>
	{% endblock %}
{% endembed %}
