{%- from "aptly/map.jinja" import aptly with context %}

include:
  {%- if aptly.manage_repo %}
  - aptly.repo
  {%- endif %}
  - aptly.install
  - aptly.config
  - aptly.service
  {%- if aptly.mirrors is defined and aptly.mirrors is mapping %}
  - aptly.mirror
  {%- endif %}
  {%- if aptly.publisher.enabled %}
  - aptly.publisher
  {%- endif %}
