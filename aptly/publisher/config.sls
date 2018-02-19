{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.publisher.install

publisher_yaml:
  file.managed:
    - name: {{ aptly.publisher_conf_file }}
    - source: salt://aptly/files/aptly-publisher.yaml.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 664
    - makedirs: True

