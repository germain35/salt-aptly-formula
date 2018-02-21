{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.install

aptly_conf:
  file.managed:
    - name: {{ aptly.conf_file }}
    - source: salt://aptly/files/aptly.conf.jinja
    - template: jinja
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 664
    - require:
      - file: aptly_pub_dir

aptly_api_conf:
  file.managed:
    - name: {{ aptly.api_conf_file }}
    - source: salt://aptly/files/aptly-api.conf.jinja
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 644
    - template: jinja

{% if aptly.snapshots id defined and aptly.snapshots is list %}
aptly_snpashots_conf:
  file.managed:
    - name: {{ aptly.snapshots_conf_file }}
    - contents: {{ {'snapshots': aptly.snapshots}|yaml }}
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 644
{%- endif %}
