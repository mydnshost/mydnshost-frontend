{% if domain.dnssec.state is defined and domain.dnssec.state in ['signed', 'signed_extra_keys'] %}
	<span class="badge dnssecstate state-signed" title="DNSSEC: {{ domain.dnssec.state }}"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2m3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2"/></svg></span>
{% elseif domain.dnssec.state is defined and domain.dnssec.state == 'broken_signature' %}
	<span class="badge dnssecstate state-broken" title="DNSSEC: broken signature"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M11 1a2 2 0 0 0-2 2v4a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2h5V3a3 3 0 0 1 6 0v4a.5.5 0 0 1-1 0V3a2 2 0 0 0-2-2"/></svg></span>
{% else %}
	<span class="badge dnssecstate state-none" title="DNSSEC: {{ domain.dnssec.state is defined ? domain.dnssec.state : 'unknown' }}"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2m3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2"/></svg></span>
{% endif %}
