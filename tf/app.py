# Create a basic Flask app
from flask import Flask, Response

app = Flask(__name__)
import yaml

from .build import create_script


@app.route("/titanfall")
def tf_deply():
    parser_conf = {
        'comments': False,
        'oneline': False
    }
    with open("test.yml") as fil:
        config = yaml.load(fil.read())
    return Response(create_script(config, **parser_conf)+"\n")
