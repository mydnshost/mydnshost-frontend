<H1>Home</H1>
{% embed '@default/index.tpl' with {'id': 'deleteModal'} %}
  {% block containerwrapper %}<div class="container-fluid">{% endblock %}
  {% block jumbotron %}
    {% if articles is not empty %}
      <div class="row jumbotron news">
        <div class="col">
          <h2>News</h2>
          {% for article in articles %}
          <p>
            <strong>{{ article.title }}</strong>
            <br>
            {{ article.content }}
            </p>
          {% endfor %}
        </div>
      </div>
    {% endif %}
  {% endblock %}
{% endembed %}
