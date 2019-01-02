<div class="container">
{% block contenttop %}{% endblock %}
<form class="form-signin small" method="post" action="{{ url('/login') }}">
  <h1 class="form-signin-heading">2FA Required</h1>
  <label for="input2FAKey" class="sr-only">2FA Code</label>
  <input type="text" name="2fakey" id="input2FAKey" class="form-control" placeholder="2FA Code" autofocus autocomplete="off">
  <div class="form-check">
    <label class="form-check-label">
      <input type="checkbox" name="savedevice" id="savedevice" class="form-check-input"">
      Remember this device
    </label>
  </div>
  <input type="text" name="devicename" id="devicename" class="form-control hidden" placeholder="Device Name" value="{{devicename}}">

  <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
</form>
</div>

<script src="{{ url('/assets/2fa.js') }}"></script>
