import sys

from hy.cmdline import cmdline_handler


def gently_shell():
    sys.exit(cmdline_handler('hy', sys.argv))
