## How to install Gently?

Gently requires Python 3. It is recommended to install Gently inside a Python virtual environment using pip (package installer for Python). You can follow the steps below to check for requirements, create a virtual environment and install Gently.


### Is Python 3 installed on your system?

You can run `python --version` and `python3 --version` on your command line to see if you have Python 3.

    $ python3 --version
    Python 3.5.2

It must print something like `Python 3.x.x` (not `Python 2.x.x` or `python: command not found`). If it doesn't, install [Python 3](https://www.python.org/downloads/ "Download Python 3").


### Is pip installed on your system?

You can run `pip --version` and `pip3 --version` to check if pip is installed on your system. It is important that the installed pip belongs to Python 3.

    $ pip3 --version
    pip 8.1.1 from /usr/lib/python3/dist-packages (python 3.5)

You can see which Python does pip belong to at the end of the output. If pip is not available for Python 3, install [pip](https://pip.pypa.io/en/latest/installing/#installing-with-get-pip-py "Installing pip").


### How to create a virtual environment?

Virtual environments provide a self-contained and isolated Python installation. This makes things cleaner and manageable. You can create a virtual environment using the command below.

    python3 -m venv gently-env

It will create a directory named `gently-env` in your working directory and set up a virtual environment inside. You can activate the virtual environment on GNU/Linux and macOS with the command:

    source gently-env/bin/activate

...and on Windows:

    gently-env/Scripts/activate.bat


### How to finally install and run Gently?

You can now install Gently to the activated virtual environment with the following command:

    pip install https://github.com/celaleddin/gently/archive/master.zip

Type `gently` and press <kbd>Enter</kbd> to start the Gently shell. Enjoy!

#### Note:

Since you've installed Gently inside the virtual environment, you must activate it to run Gently. So, the next time you want to use Gently, you must first activate the virtual environment `gently-env` in order to run Gently.

    source gently-env/bin/activate
    gently
