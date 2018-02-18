{%- from "aptly/map.jinja" import aptly with context %}

{%- set osfamily   = salt['grains.get']('os_family') %}
{%- set os         = salt['grains.get']('os') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- if aptly.manage_repo %}
  {%- if osfamily == 'Debian' %}
aptly_gnupg_pkg:
  pkg.installed:
    - name: gnupg
    - require_in:
      - pkgrepo: aptly_repo
  {%- endif %}
  
  {%- if 'repo' in aptly and aptly.repo is mapping %}
aptly_repo:
  pkgrepo.managed:
    {%- for k, v in aptly.repo.iteritems() %}
    - {{k}}: {{v}}
    {%- endfor %}
  {%- endif %}
{%- endif %}
