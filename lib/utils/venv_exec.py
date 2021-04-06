import os
import sys

env_name = sys.argv[1]
command = sys.argv[2]

final = f'{env_name}\\Scripts\\activate && {command}'

os.system(final)
