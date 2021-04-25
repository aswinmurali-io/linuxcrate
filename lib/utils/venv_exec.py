import os
import sys

env_name = sys.argv[1]
command = sys.argv[2]

# source tutorial-env/bin/activate
final = f'source {env_name}/bin/activate ; {command}'

os.system(final)
