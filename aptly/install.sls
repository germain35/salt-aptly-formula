{%- from "aptly/map.jinja" import aptly with context %}

{%- if aptly.manage_repo %}
include:
  - aptly.repo
{%- endif %}

aptly_requisites_packages:
  pkg.installed:
    - pkgs: {{ aptly.req_pkgs }}
    - reload_modules: true

aptly_package:
  pkg.installed:
    - name: {{ aptly.pkg }}
    {%- if aptly.version is defined %}
    - version: {{ aptly.version }}
    {%- endif %}
    - refresh: True
    - require:
      - pkg: aptly_requisites_packages
    {%- if aptly.manage_repo %}
      - sls: aptly.repo
    {%- endif %}

{%- if aptly.manage_user %}

aptly_group:
  group.present:
    - name: {{ aptly.group }}
    - system: True

aptly_user:
  user.present:
    - name: {{ aptly.user }}
    - home: {{ aptly.home_dir }}
    - shell: /bin/bash
    - system: True
    - groups:
      - {{ aptly.group }}
    - require:
      - pkg: aptly_package
      - group: aptly_group
    - require_in:
      - file: aptly_home_dir
      - file: aptly_root_dir
      - file: aptly_pub_dir

{%- endif %}

aptly_home_dir:
  file.directory:
    - name: {{ aptly.home_dir }}
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 755
    - require:
      - user: aptly_user

aptly_root_dir:
  file.directory:
    - name: {{ aptly.root_dir }}
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 755
    - require:
      - user: aptly_user

aptly_log_dir:
  file.directory:
    - name: {{ aptly.log_dir }}
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 755
    - require:
      - user: aptly_user

aptly_pub_dir:
  file.directory:
    - name: {{ aptly.root_dir }}/public
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - require:
      - file: aptly_root_dir


aptly_update_script:
  file.managed:
    - name: /usr/local/bin/aptly_update.py
    {%- if aptly.publisher.get('python_version', False) %}
      {%- set string_version = aptly.publisher.python_version|string %}
      {%- set major_version  = string_version.split('.')[0]|int %}
      {%- if aptly.publisher.python_version == 3 %}
    - source: salt://aptly/files/aptly_update.py3.jinja
      {%- else %}
    - source: salt://aptly/files/aptly_update.py3.jinja
      {%- endif %}
    {%- else %}
    - source: salt://aptly/files/aptly_update.py.jinja
    {%- endif %}
    - template: jinja
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 755

{%- if aptly.manage_gpg and aptly.secure %}

{% set gpgprivfile = '{}/.gnupg/secret.gpg'.format(aptly.home_dir) %}
{% set gpgpubfile  = '{}/public/public.gpg'.format(aptly.root_dir) %}

aptly_gpg_key_dir:
  file.directory:
    - name: {{ aptly.home_dir }}/.gnupg
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 700
    - require:
      - file: aptly_home_dir

aptly_gpg_priv_key:
  file.managed:
    - name: {{ gpgprivfile }}
    - contents: {{ aptly.gpg.private_key|yaml }}
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 600
    - require:
      - file: aptly_gpg_key_dir

aptly_gpg_pub_key:
  file.managed:
    - name: {{ gpgpubfile }}
    - contents: {{ aptly.gpg.public_key|yaml }}
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 644
    - makedirs: True
    - require:
      - file: aptly_gpg_key_dir

aptly_gpg_import_key:
  module.run:
    - gpg.import_key:
      - user: {{ aptly.user }}
      {%- if aptly.gpg.homedir is defined %}
      - gnupghome: {{ aptly.gpg.homedir }}
      {%- endif %}
      - filename: {{ gpgprivfile }}
    - require:
      - file: aptly_gpg_priv_key

  {%- if aptly.gpg.trust_level is defined %}
aptly_gpg_trust_key:
  module.run:
    - gpg.trust_key:
      - user: {{ aptly.user }}
      {%- if aptly.gpg.fingerprint is defined %}
      - fingerprint: {{ aptly.gpg.fingerprint }}
      {%- else %}
      - keyid: {{ aptly.gpg.keypair_id }}
      {%- endif %}
      - trust_level: {{ aptly.gpg.trust_level }}
    - require:
      - module: aptly_gpg_import_key
  {%- endif %}

{%- endif %}
