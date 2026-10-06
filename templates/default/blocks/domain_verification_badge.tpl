<span class="badge verificationstate state-{{ domain.verification.state }}" title="Verification state: {{ domain.verification.state }} as of {{ domain.verification.time | date }}">
	{%- if domain.verification.state == 'valid' -%}
		✓
	{%- elseif domain.verification.state == 'invalid' -%}
		X
	{%- else -%}
		?
	{%- endif -%}
</span>
