#!/bin/bash
find /home/eric-dev/Documents/Mitandrina/frontend-jsp/src/main/webapp/WEB-INF/views -name "*.jsp" -type f | while read file; do
  if ! grep -q 'href="/assets/css/custom.css"' "$file"; then
    sed -i 's|</head>|    <link rel="stylesheet" href="/assets/css/custom.css">\n</head>|g' "$file"
  fi
done
