{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.mirror

{%- set current_date = salt['cmd.run']('date "+%Y%m%d%H%M%S"') %}

{%- for snapshot in aptly.get('snapshots', []) %}
  
  {%- set name   = snapshot['name'] if snapshot is mapping else snapshot[0] %}
  {%- set params = snapshot if snapshot is mapping else snapshot[1] %}

  {%- if params.suffix is defined %}
    {%- set snapshot_name =  name + '-' + suffix %}
  {%- else %}
    {%- set snapshot_name =  name + '-' + current_date %}
  {%- endif %}

  {%- if params.mirror is defined %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot create {{ snapshot_name }} from mirror {{ params.mirror }}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- elif params.filters is defined and params.sources is defined %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot filter {{ params.sources }} {{ snapshot_name }} "{{ filters|join(' | ') }}"
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- elif params.sources is defined %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot merge {% if params.get('latest', False) %}-latest {% endif %}{{ snapshot_name }} {{ params.sources }}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- endif %}
{%- endfor %}


