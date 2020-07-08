ERROR = "Error: Force Exit\n\n"

try:
  print(OOPS)
except:
  with open('python.output', 'a') as f:
    f.write(ERROR)
  exit()

