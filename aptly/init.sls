{%- from "aptly/map.jinja" import aptly with context %}

include:
  - aptly.install
  - aptly.config
  - aptly.service
  {%- if aptly.publisher.enabled %}
  - aptly.publisher
  {%- endif %}