{%- from "aptly/map.jinja" import aptly with context %}

{%- if aptly.publisher.python_install %}

aptly_publisher_python_packages:
  pkg.installed:
    - pkgs: {{ aptly.publisher_req_pkgs }}
    - reload_modules: true

aptly_publisher_package:
  pip.installed:
    {%- if aptly.publisher.get('version', False) %}
    - name: python-aptly == {{ aptly.publisher.version }}
    {%- else %}
    - name: python-aptly
    {%- endif %}
    - bin_env: {{aptly.publisher.python.pip.get('bin_env', '/usr/bin/pip3')}}
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

aptly_publisher_packages:
  pkg.installed:
  - name: {{ aptly.publisher_pkg }}

{%- endif %}
