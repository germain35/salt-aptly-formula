{%- from "aptly/map.jinja" import aptly with context %}

{%- if aptly.publisher.python_install %}

  {%- if aptly.publisher.get('python_version', False) %}

    {%- set major_version = aptly.publisher.python_version|string.split('.')[0]|int %}

aptly_publisher_python_pip:
  pkg.installed:
    - name: python{{major_version}}-pip

aptly_publisher_packages:
  pip.installed:
    {%- if aptly.publisher.get('version', False) %}
    - name: python-aptly == {{ aptly.publisher.version }}
    {%- else %}
    - name: python-aptly
    {%- endif %}
    - bin_env: /usr/bin/pip3
    - require:
      - pkg: aptly_publisher_python_pip

  {%- else %}

aptly_publisher_python_pip:
  pkg.installed:
    - name: python-pip

aptly_publisher_packages:
  pip.installed:
    - name: python-aptly
    - require:
      - pkg: aptly_publisher_python_pip

  {%- endif %}

{%- else %}

aptly_publisher_packages:
  pkg.installed:
  - pkgs: {{ aptly.publisher_pkgs }}

{%- endif %}
