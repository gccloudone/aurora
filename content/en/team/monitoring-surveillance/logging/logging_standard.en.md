---
title: "Access Logging Standard"
linkTitle: "Access Logging Standard"
weight: 30
type: "docs"
draft: false
lang: "en"
---

## Introduction

Access logs are beneficial to capture and log events and actions for system administrators to audit and debug potential issues. Access logs can be classified into three main categories:
1. User access
1. User activity
1. Request errors

Logs collected from web servers are very helpful to understand the incoming traffic pattern. It is important that logs can provide accurate context about what the user was doing when a specific error happened. In this way, having at least one log entry per request/result in every layer of the application is mandatory. Issues may not always be trivial, and we have to take performance issues into account.

### Event Logging Guidance

The guidance set out by TBS outlines recommendations at the application level and cloud level for logging data. CCCS’s ITSG-33 IT Security Risk Management Framework also offers related security controls that have a dependency on logging and monitoring. More details can be found [here](https://publications.gc.ca/collections/collection_2021/sct-tbs/BT39-52-2020-eng.pdf).

## Access Log Format

A common log format for the access log might look as follows:

`%h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-agent}i"`

- **%h** – Remote host (client IP address)
- **%l** – User identity, or dash, if none (often not used)
- **%u** – Username, via HTTP authentication, or dash if not used
- **%t** – Timestamp of when Web Server received the HTTP request [day/month/year:hour:minute:second zone]
- **”%r** – The actual request itself from the client
- **%>s** – The status code the Web Server returns in response to the request
- **%b** – The size of the request in bytes.
- **”%{Referer}i”** – Referrer header, or dash if not used  (In other words, did they click a URL on another site to come to your site)
- **”%{User-agent}i** – User agent (contains information about the requester’s browser/OS/etc)

This logging standard aligns with formats set out by various web servers such as [Apache](https://httpd.apache.org/docs/2.4/logs.html#accesslog) and [NGINX](http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format).

The above configuration will write log entries in a format known as the Common Log Format (CLF). This standard format can be produced by many different web servers and read by many log analysis programs. The log file entries produced in CLF will look something like this:

`[www.statcan.gc.ca] 142.206.1.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /en/sites/all/Sample-Font.woff HTTP/1.1" 404 179976 "https://www.statcan.gc.ca/sites/default/files/css/style.css" "Edg/113.0.1774.57"`

> Note that a hyphen in the output indicates that the requested piece of information is not available

## Customizing Logging Settings

Each web server or service mesh allows users to enable and customize the logging settings and change the format of logged messages. By default these access logs are outputted in TEXT format. Alternatively, logs may be outputted as JSON.

Note that it is possible to have the time displayed in another format by specifying %{format} in the log format string, where format is either in strftime(3) from the C standard library, or one of the supported special tokens. For details see the mod_log_config format strings.
