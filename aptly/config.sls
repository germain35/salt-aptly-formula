{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.install

aptly_conf:
  file.managed:
    - name: {{ aptly.home_dir }}/.aptly.conf
    - source: salt://aptly/files/aptly.conf.jinja
    - template: jinja
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 664
    - require:
      - file: aptly_pub_dir

aptly_api_conf:
  file.managed:
    - name: /etc/default/aptly-api
    - source: salt://aptly/files/aptly-api.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
