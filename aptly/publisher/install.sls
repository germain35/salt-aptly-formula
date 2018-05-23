{%- from "aptly/map.jinja" import aptly with context %}

{%- if aptly.publisher.python_install %}

  {%- if aptly.publisher.get('python_version', False) %}

    {%- set string_version = aptly.publisher.python_version|string %}
    {%- set major_version  = string_version.split('.')[0]|int %}

aptly_publisher_python_packages:
  pkg.installed:
    - pkgs: 
      - python{{major_version}}-pip
      - python{{major_version}}-setuptools

aptly_publisher_packages:
  pip.installed:
    {%- if aptly.publisher.get('version', False) %}
    - name: python-aptly == {{ aptly.publisher.version }}
    {%- else %}
    - name: python-aptly
    {%- endif %}
    - bin_env: /usr/bin/pip3
    {%- if aptly.publisher.python.pip.get('no_index', False) %}
    - no_index: True
    {%- endif %}
    {%- if aptly.publisher.python.pip.get('index_url', False) %}
    - index_url: {{ aptly.publisher.python.pip.index_url }}
      {%- if aptly.publisher.python.pip.get('trusted_host', False) %}
    - trusted_host: {{ aptly.publisher.python.pip.trusted_host }}
      {%- endif %}
    {%- endif %}
    {%- if aptly.publisher.python.pip.get('find_links', False) %}
    - find_links: {{ aptly.publisher.python.pip.find_links }}
    {%- endif %}
    - require:
      - pkg: aptly_publisher_python_packages

  {%- else %}

aptly_publisher_python_packages:
  pkg.installed:
    - pkgs: 
      - python-pip
      - python-setuptools

aptly_publisher_packages:
  pip.installed:
    {%- if aptly.publisher.get('version', False) %}
    - name: python-aptly == {{ aptly.publisher.version }}
    {%- else %}
    - name: python-aptly
    {%- endif %}
    {%- if aptly.publisher.python.pip.get('no_index', False) %}
    - no_index: True
    {%- endif %}
    {%- if aptly.publisher.python.pip.get('index_url', False) %}
    - index_url: {{ aptly.publisher.python.pip.index_url }}
      {%- if aptly.publisher.python.pip.get('trusted_host', False) %}
    - trusted_host: {{ aptly.publisher.python.pip.trusted_host }}
      {%- endif %}
    {%- endif %}
    {%- if aptly.publisher.python.pip.get('find_links', False) %}
    - find_links: {{ aptly.publisher.python.pip.find_links }}
    {%- endif %}
    - require:
      - pkg: aptly_publisher_python_packages

  {%- endif %}

{%- else %}

aptly_publisher_packages:
  pkg.installed:
  - pkgs: {{ aptly.publisher_pkgs }}

{%- endif %}
