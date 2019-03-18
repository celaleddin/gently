## How to install Gently?

Gently requires Python 3.5 or higher. It is recommended to install Gently inside a Python virtual environment using pip (package installer for Python).

You can follow the steps below to check for requirements, create a virtual environment and install Gently.


### Is Python installed on your system?

You can run `python --version` and `python3 --version` on your command line (terminal on GNU/Linux and macOS, cmd or Powershell on Windows) to see if you have Python installed and configured on your computer.

    $ python3 --version
    Python 3.5.2

It must print something like `Python 3.x.x` (not `Python 2.x.x` or `python: command not found`). If it doesn't, install the latest version of [Python 3](https://www.python.org/downloads/ "Download Python 3").

Note the command corresponding to Python 3, you will use that command in the next steps.

**Note for Windows users:** While installing Python, make sure to check the checkbox related to adding Python to PATH. If you don't add Python to PATH, you can't reach it on command line. If you have Python installed on your computer and the command line doesn't recognize it, you need to configure your PATH.


### Is pip installed on your system?

You can run `pip --version` and `pip3 --version` to check if pip is installed on your system. It is important that the installed pip belongs to the Python version you noted in the first step.

    $ pip3 --version
    pip 8.1.1 from /usr/lib/python3/dist-packages (python 3.5)

You can see which Python does pip belong to at the end of the output. If pip is not available for your Python version, install [pip](https://pip.pypa.io/en/latest/installing/#installing-with-get-pip-py "Installing pip") using the Python command you noted.


### How to create a virtual environment?

Virtual environments provide a self-contained and isolated Python installation. This makes things cleaner and manageable. You can create a virtual environment using the command below.

    python3 -m venv gently-env

It will create a directory named `gently-env` in your working directory and set up a virtual environment inside. You can activate the virtual environment on GNU/Linux and macOS with the command:

    source gently-env/bin/activate

...and on Windows:

    gently-env\Scripts\activate.bat  :: on cmd
    gently-env\Scripts\activate.ps1  :: on powershell 


### How to finally install and run Gently?

You can now install Gently to the activated virtual environment with the following command.

    pip install gently

Run `gently` on your command line to start the Gently shell. Enjoy!

**Note:** Since you've installed Gently inside the virtual environment, the next time you want to use it, you must first activate the virtual environment `gently-env`.

    source gently-env/bin/activate  # or the Windows variants
    gently
    
    
### Further help

If you experience problems with installing Gently, feel free to open an issue describing your situation on [GitHub](https://github.com/celaleddin/gently/issues "GitHub Issues").
