{%- from "aptly/map.jinja" import aptly with context %}

{%- if aptly.publisher.pip_install %}

aptly_publisher_python_pip:
  pkg.installed:
    - name: python-pip

aptly_publisher_packages:
  pip.installed:
    - name: python-aptly
    - require:
      - pkg: aptly_publisher_python_pip

{%- else %}

aptly_publisher_packages:
  pkg.installed:
  - pkgs: {{ aptly.publisher_pkgs }}

{%- endif %}

aptly_publish_script:
  file.managed:
    - name: /usr/local/bin/aptly_publish_update.sh
    - source: salt://aptly/files/aptly_publish_update.sh.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 755
