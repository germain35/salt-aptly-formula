{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.mirror

{%- set current_date = salt['cmd.run']('date "+%Y%m%d%H%M%S"') %}

{%- for snapshot, params in aptly.get('snapshots', {}).iteritems() %}
  
  {%- if params.suffix is defined %}
    {%- set snapshot_name =  snapshot + '-' + suffix %}
  {%- else %}
    {%- set snapshot_name =  snapshot + '-' + current_date %}
  {%- endif %}

  {%- if params.get('action', 'create') == 'create' %}
aptly_snapshot_{{snapshot}}:
  cmd.run:
    - name: aptly snapshot create {{ snapshot_name }} from mirror {{ params.mirror }}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- elif params.get('action', 'create') == 'filter' %}
aptly_snapshot_{{snapshot}}:
  cmd.run:
    - name: aptly snapshot filter {{ params.sources }} {{ snapshot_name }} "{{ filters|join(' | ') }}"
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- elif params.get('action', 'create') == 'merge' %}
aptly_snapshot_{{snapshot}}:
  cmd.run:
    - name: aptly snapshot merge {% if params.get('latest', False) %}-latest {% endif %}{{ snapshot_name }} {{ params.sources }}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- endif %}
{%- endfor %}


