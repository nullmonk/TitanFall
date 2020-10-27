# TitanFall
The ultimate linux dropper. The idea for this is to generate one massive script
based on several smaller droppers.

## Usage
TitanFall requires module in order to be used. These modules are called Titans. You can find an example of some Titans [here](https://github.com/RITRedteam/TrainingWheelsProtocol)

### Get the repositories
```
git clone --recursive https://github.com/micahjmartin/TitanFall
git clone https://github.com/RITRedteam/TrainingWheelsProtocol Titans
cd TitanFall
```

### Generate a config
`./scripts/generate-config.sh test.yml`

Follow the TUI to generate a new config file for TitanFall.

### Build a config
You may either stand up TitanFall as a flask server to quickly deploy the script on the fly, or build the config file in place.

**Server Usage**

Run the server, you may specify the port number
```
./TitanFall.py [port]
```
Get the script
```
curl localhost/titanfall
```

**Inplace Usage**

To build a config file inplace
```
./TitanFall.py test.yml
```
