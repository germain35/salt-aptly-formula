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

aptly_update_conf:
  file.serialize:
    - name: {{ aptly.update_conf_file }}
    - dataset: 
        snapshots: {{aptly.get('snapshots', [])}}
    - formatter: yaml
    - user: {{ aptly.user }}
    - group: {{ aptly.group }}
    - mode: 644
    - makedirs: True


{%- if aptly.cron.enabled %}

aptly_cron:
  cron.present:
    - name: "/usr/local/bin/aptly_update.py -s -p -r > {{aptly.log_dir}}/aptly_update.log 2>&1"
    - identifier: aptly_update
    - hour: "{{ aptly.cron.hour }}"
    - minute: "{{ aptly.cron.minute }}"
    - user: {{ aptly.user }}
    - require:
      - file: aptly_update_script
      - user: aptly_user

aptly_cron_path:
  cron.env_present:
    - name: PATH
    - value: "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
    - user: {{ aptly.user }}

{%- else %}

aptly_cron:
  cron.absent:
    - identifier: aptly_update
    - user: {{ aptly.user }}

{%- endif %}
