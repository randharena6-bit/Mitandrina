import re

file_path = "/home/eric-dev/Documents/Mitandrina/frontend-mobile/src/navigation/RootNavigator.js"
with open(file_path, "r") as f:
    content = f.read()

# 1. Fix "< \n Component" and "< Component"
content = re.sub(r"<\s+([A-Za-z/])", r"<\1", content)

# 2. Fix "< / Component" -> "</Component"
content = re.sub(r"<\s+/\s+([A-Za-z])", r"</\1", content)
content = re.sub(r"</\s+([A-Za-z])", r"</\1", content)

# 3. Fix "/>" spacing
content = re.sub(r"\s+/>", r" />", content)
content = re.sub(r"/\s+>", r"/>", content)

# 4. Fix prop assignment spaces: "prop = { value }" to "prop={ value }"
content = re.sub(r"\b([A-Za-z]+)\s*=\s*(?=[{\"\'])", r"\1=", content)

with open(file_path, "w") as f:
    f.write(content)
