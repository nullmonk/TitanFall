#!/usr/bin/env python3
import sys


def startFlask(port):
    from tf.app import app
    import logging
    log = logging.getLogger('werkzeug')
    log.setLevel(logging.DEBUG)
    # Set to false to hide debug log info
    app.config['DEBUG'] = True
    log.debug("[+] Listening on port {}".format(port))
    app.run(host="0.0.0.0", port=port)


def renderConfig(filename):
    import yaml
    from tf.build import create_script
    parser_conf = {
        'comments': False,
        'oneline': False
    }
    with open(filename) as fil:
        config = yaml.load(fil.read())
    print(create_script(config, **parser_conf))


if __name__ == '__main__':
    try:
        port = int(sys.argv[1])
        startFlask(port)
    except ValueError as E:
        renderConfig(sys.argv[1])
    except Exception as E:
        startFlask(80)
