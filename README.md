# TitanFall
The ultimate linux dropper. The idea for this is to generate one massive script
based on several smaller droppers.

## Usage
Create another repository called Titans. Clone that repository beside the TitanFall repository.
Currently my Titans repo is private but I will make it public soon.

### Generate a config
`./scripts/generate_config.sh test.yml`

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
./TitanFall.py <file>
```
