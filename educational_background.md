---
layout: default_timeline
title: Educational Background
permalink: /educationals/
---

<div class="container row">
  <h1 class="cv-title">
    <a href="/">
      <span class="black white-text">{{ site.title }}</span>
    </a>
  </h1>
  {% assign steps = site.steps | sort: 'date' %}
  {% for step in steps %}
    <div class="item">
      <i class="vertical-line"></i>
      <h2 class="item-date">{{ step.date | date: '%m/%Y' }}{% if step.enddate %} - {{ step.enddate | date: '%m/%Y' }}{% endif %}</h2>
      <div class="card-panel">
        <h3 class="card-title">
          {{ step.title }}
        </h3>
        <p>
          {{ step.content }}
        </p>
      </div>
    </div>
  {% endfor %}
  <div class="last-item">
    <i class="vertical-line"></i>
  </div>
</div>