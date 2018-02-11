{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.install
  - aptly.config

aptly_api_service_file:
  file.managed:
    - name: /etc/systemd/system/aptly-api.service
    - source: salt://aptly/files/aptly-api.service.jinja
    - template: jinja
    - user: root
    - group: root

{%- if aptly.api.service.enabled %}
aptly_api_service:
  service.running:
    - name: aptly-api
    - enable: True
    - watch:
      - file: aptly_api_service_file
      - file: aptly_api_conf
      - file: aptly_conf
{%- else %}
aptly_api_service:
  service.dead:
    - name: aptly-api
    - enable: False
    - require:
      - file: aptly_api_service_file
      - file: aptly_api_conf
      - file: aptly_conf
{%- endif %}