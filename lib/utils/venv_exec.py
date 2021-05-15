import os
import sys

env_name = sys.argv[1]
command = sys.argv[2]

# source tutorial-env/bin/activate
final = f'sudo bash -c "source {env_name}/bin/activate ; {command} ; deactivate"'

os.system(final)
