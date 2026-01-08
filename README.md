# Family Info

Project to create a single page of useful info for the family.

## Proposed Features

- Weather
- Train Departures (with delays if possible)
- Bindicator
- Which restaurants are open
- Chads theatre
- Calendar of family events

## How It Works

The project is build using Ruby. To work locally, you can run this command:

```bash
./build.sh
```

This will generate an `index.html` file that you can open in your browser.

Alternatively you can use this command to automatically rebuild the file when changes are made:

```bash
bin/watcher
```

Once you've made the changes, push to GitHub and GitHub Pages will host the site for you, rebuilding the page
every hour automatically.