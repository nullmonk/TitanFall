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

def parse_payload(filename):
    '''
    Parse a module file and turn it into useful data
    '''
    def find_comment_key(string, key):
        '''
        Search for a value specified in the comment of the file
        E.x. '# WEIGHT: 50'
        '''
        search = "# {}: ".format(key)
        start = script.find(search)
        if start == -1:
            search = "# {} ".format(key)
            start = script.find(search)
        if start != -1:
            try:
                value = script[start+len(search):script.find("\n",start)]
                return value
            except Exception as E:
                return None

    data = {}
    with open(filename) as fil:
        script = fil.read()

    # Get the weight, default to 50
    try:
        value = find_comment_key(script, "WEIGHT")
        data['weight'] = int(value)
    except Exception as E:
        data['weight'] = 50
    # Get the starting function
    value = find_comment_key(script, "RUN")
    if value:
        data['run'] = value
    else:
        data['run'] = os.path.basename(filename)[:-3]
    data['script'] = script
    return data


def create_script(config, **kwargs):
    '''
    Turn a config dictionary into a bash script
    '''
    # Get the payloads that are required for all droppers
    functions_dir = config.get("directory", "../Titans/functions")
    functions = list_files(functions_dir)

    script = ""
    # The payload names to call
    calls = ["INIT"]

    # Render the log function based on log level
    log = render("tf/templates/log_function.j2",
                 {'LOGLEVEL': config['loglevel']})
    script += log + "\n"
    # Read and add each function
    for function in functions:
        with open(functions_dir+"/"+function) as funcfil:
            script += funcfil.read() + "\n"
    # Get the payloads and sort them by weight
    payloads = []
    for payload in config['payloads']:
        payloads += [parse_payload(payload)]
    payloads.sort(key=lambda x: x['weight'], reverse=True)

    for payload in payloads:
        script += payload['script'] + '\n'
        calls += [payload['run']]


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
