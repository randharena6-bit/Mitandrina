import os

directory = '/home/eric-dev/Documents/Mitandrina/frontend-jsp/src/main/webapp/WEB-INF/views'

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.jsp'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            if 'href="/assets/css/custom.css"' in content:
                content = content.replace('href="/assets/css/custom.css"', 'href="/assets/css/custom.css?v=' + str(os.urandom(4).hex()) + '"')
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Updated {filepath}")

