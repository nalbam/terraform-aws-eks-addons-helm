alertmanager:
  enabled: true
  config:
    global:
      resolve_timeout: 5m
      slack_api_url: "${SLACK_API_URL}"
      # slack_channel: ""
    route:
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
      receiver: "slack"
      routes:
        # - match:
        #     alertname: Watchdog
        #   receiver: "null"
        - match:
          receiver: "slack"
          continue: false
    receivers:
      # - name: "null"
      - name: "slack"
        slack_configs:
          - channel: "${SLACK_CHANNEL}"
            color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
            icon_url: https://avatars3.githubusercontent.com/u/3380462
            send_resolved: true
            title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] Monitoring Event Notification'
            text: |
              {{ range .Alerts }}
              *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`

              *Cluster:* :flag-${COUNTRY}: `${CLUSTER_NAME}`

              *Description:* {{ .Annotations.description }}

              *Details:*
                {{ range .Labels.SortedPairs }} • *{{ .Name }}:* {{ .Value }}
                {{ end }}
              {{ end }}

  alertmanagerSpec:
    alertmanagerConfigNamespaceSelector:
      matchLabels:
        alertmanagerconfig: enabled
