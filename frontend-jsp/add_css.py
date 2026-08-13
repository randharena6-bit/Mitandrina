import os

directory = '/home/eric-dev/Documents/Mitandrina/frontend-jsp/src/main/webapp/WEB-INF/views'
css_link = '    <link rel="stylesheet" href="/assets/css/custom.css">\n'

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.jsp'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'href="/assets/css/custom.css"' not in content and '</head>' in content:
                content = content.replace('</head>', css_link + '</head>')
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Added to {filepath}")

