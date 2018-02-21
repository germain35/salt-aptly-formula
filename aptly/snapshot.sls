{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.mirror

{%- set current_date = salt['cmd.run']('date "+%Y%m%d%H%M%S"') %}

{%- for snapshot in aptly.get('snapshots', []) %}
  
  {%- if snapshot is mapping %}
    {%- set name   = snapshot.keys()[0] %}
    {%- set params = snapshot.values()[0] %}
  {%- elif snapshot is list %}
    {%- set name   = snapshot[0] %}
    {%- set params = snapshot[1] %}
  {%- else %}
    {%- set name   = snapshot %}
    {%- set params = {} %}
  {%- endif %}

  {%- set snapshot_name =  name + '-' + current_date %}

  {%- if params.mirror is defined %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot create {{ snapshot_name }} from mirror {{ params.mirror }}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- elif params.filters is defined and params.source is defined %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot filter {% if params.get('deps', False) %}-with-deps {% endif %}{{ params.source }}-{{current_date}} {{ snapshot_name }} "{{ params.filters|join(' | ') }}"
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- elif params.merge is defined %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot merge {% if params.get('latest', False) %}-latest {% endif %}{{ snapshot_name }} {% for source in params.merge %}{{ source }}-{{current_date}} {% endfor %}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- else %}
aptly_snapshot_{{snapshot_name}}:
  cmd.run:
    - name: aptly snapshot create {{ snapshot_name }} from mirror {{ name }}
    - runas: {{ aptly.user }}
    - unless: aptly snapshot show {{ snapshot_name }}
  {%- endif %}
{%- endfor %}
