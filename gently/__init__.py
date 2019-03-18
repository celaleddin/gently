import sys
import io
import argparse

from hy.cmdline import run_repl, HyREPL
from hy.errors import filtered_hy_exceptions, hy_exc_handler


COMMANDLINE_USAGE = 'gently [file]'
COMMANDLINE_EPILOGUE = """
command examples:
  gently             Start the Gently shell
  gently file.hy     Run a program from a file
  gently -i file.hy  Stay in the Gently shell after running a file
"""
PREPARATION_COMMAND = """
(import [gently.language [*]])
(require [gently.language [*]])
None
"""
GREETING_COMMAND = '(print "\nWelcome to Gently!")'


def commandline_handler(arguments):
    parser = argparse.ArgumentParser(
        prog='gently',
        usage=COMMANDLINE_USAGE,
        epilog=COMMANDLINE_EPILOGUE,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument('-i', '--interactive', action='store_true',
                        help='stay in Gently shell after running a file')
    parser.add_argument('args', nargs=argparse.REMAINDER,
                        help=argparse.SUPPRESS)
    options = parser.parse_args(arguments[1:])

    repl = HyREPL()
    repl.runsource(PREPARATION_COMMAND, filename='<string>')

    if options.args:
        filename = options.args[0]
        with io.open(filename, 'r', encoding='utf-8') as f:
            source = f.read()
        with filtered_hy_exceptions():
            result = repl.runsource(source, filename=filename)

        # If the command was prematurely ended, show an error (just like Hy)
        if result:
            hy_exc_handler(sys.last_type, sys.last_value, sys.last_traceback)

        if not options.interactive:
            repl.runsource('(quit)', filename='<string>')

    repl.runsource(GREETING_COMMAND, filename='<string>')
    return run_repl(repl)


def gently_shell():
    sys.exit(commandline_handler(sys.argv))
