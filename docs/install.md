## How to install Gently?

Gently requires Python 3. It is recommended to install Gently inside a Python virtual environment using pip (package installer for Python). You can follow the steps below to check for requirements, create a virtual environment and install Gently.

1. You can run `python -V` and `python3 -V` on your command line to see if you have Python 3.
```
$ python3 -V
Python 3.5.2
```
It must print something like `Python 3.x.x` (not `Python 2.x.x` or `python: command not found`). If it doesn't, install [Python 3](https://www.python.org/downloads/ "Download Python 3").

2. You can run `pip -V` and `pip3 -V` to check if pip is installed on your system. It is important that the installed pip belongs to Python 3.
```
$ pip3 -V
pip 8.1.1 from /usr/lib/python3/dist-packages (python 3.5)
```
You can see which Python does pip belong to at the end of the output. If pip is not available for Python 3, install [pip](https://pip.pypa.io/en/latest/installing/#installing-with-get-pip-py "Installing pip").

3. Virtual environments provide a self-contained and isolated Python installation. This makes things cleaner and manageable. You can create a virtual environment using the command below.
```python3 -m venv gently-env```
It will create a directory named `gently-env` in your working directory and set up a virtual environment inside. You can activate the virtual environment on GNU/Linux and MacOS with `source gently-env/bin/activate`, and on Windows with `gently-env/Scripts/activate.bat`.

4. You can now install Gently to the activated virtual environment with the following command:
```pip install https://github.com/celaleddin/gently/archive/master.zip```
