from setuptools import setup

with open('README.md', 'r') as readme:
    long_description = readme.read()

setup(
    name='gently',
    version='0.11',
    description='A tool for designing and analysing control systems',
    long_description=long_description,
    author='Celaleddin Hidayetoğlu',
    author_email='celaleddin.hidayetoglu@gmail.com',
    url='https://github.com/celaleddin/gently/',
    license='MIT',
    packages=['gently'],
    package_data={
        'gently': ['*.hy'],
    },
    install_requires=['hy', 'sympy', 'control', 'matplotlib'],
    scripts=['scripts/gently', 'scripts/gently.bat'],
)
