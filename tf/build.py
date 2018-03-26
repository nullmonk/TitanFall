#!/usr/bin/python3
import os
import yaml
import sys
import jinja2
from .parser import parser


def render(tpl_path, context):
    path, filename = os.path.split(tpl_path)
    return jinja2.Environment(
        loader=jinja2.FileSystemLoader(path or './')
        ).get_template(filename).render(context)


def list_files(startdir):
    """
    list all the files in a directory
    """
    retval = []
    if os.path.exists(startdir):
        for root, dirs, files in os.walk(startdir):
            retval += [f for f in files]
    return retval


def create_script(config, **kwargs):
    '''
    Turn a config dictionary into a bash script
    '''
    # Get the payloads that are required for all droppers
    functions_dir = config.get("directory", "../Titans/functions")
    functions = list_files(functions_dir)

    # Render the log function based on log level
    log = render("tf/templates/log_function.j2",
                 {'LOGLEVEL': config['loglevel']})

    # The payload names to call from at the init
    script = ""
    calls = ["INIT"]
    script += log + "\n"
    for function in functions:
        with open(functions_dir+"/"+function) as funcfil:
            script += funcfil.read() + "\n"

    for payload in config['payloads']:
        with open(payload) as payfil:
            content = payfil.read()
            script += content + "\n"
            calls += [os.path.basename(payload)[:-3]]
    for call in calls:
        script += call+"\n"
    if kwargs != {}:
        script = parser.parse(script, **kwargs)
    return script


def main():
    '''
    Read the YAML configuration and convert it to a jinja template
    '''
    try:
        _conf = sys.argv[1]
    except Exception as E:
        quit()

    # Open the given config file
    fil = open(_conf)
    config = yaml.load(fil)
    fil.close()
    # Generate the script
    script = create_script(config)
    script = parser.parse(script, comments=False)
    # Save the script to an outfile
    with open(config['name'], "w") as of:
        of.write(script)


if __name__ == '__main__':
    main()
