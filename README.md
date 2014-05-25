# mapview client in PureScript

This is a rewrite of the Fay mapview code with PureScript.

## Installing

### Get dependencies

```bash
sudo yum install npm
git clone git://github.com/w8upd/mapview.git # Anonymous clone
git clone git@github.com:w8upd/mapview.git # Authorized clone
cd mapview
```

### Build mapview

```bash
npm install
export PATH=$PATH:node_modules/.bin/
bower update
grunt
firefox html/index.html
```

## License

MIT