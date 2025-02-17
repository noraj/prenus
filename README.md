⚠️ This is a low effort update of [AsteriskLabs/prenus](https://github.com/AsteriskLabs/prenus) so it works with more modern Ruby 3.2+ ⚠️

Changes:

- File, Dir `exist?` monkey patch ([#1](https://github.com/noraj/prenus/pull/1))
- Dependency update
- Gemfile use HTTPS instead of HTTP
- Convert README to Markdown
- Lint code with default Rubocop config
- Fix the file structure and have proper `require`

Known bug:

- All hosts are well listed on `HTML` output but only the first one on the `host` output

---

# Prenus - The Pretty Nessus .. Thing

This is a quickly hacked together Ruby script that can consume version 2
nessus files (with the help of an udpated ruby-nessus gem) and allows the
output of a few different formats, including:

*   Static HTML files with jQuery Datatables and Highcharts graphs
*   XLS file (Actually a HTML Table with an .xls extension) with unique Nessus
    vulns and associated IPs
*   Afterglow (http://afterglow.sourceforge.net/), 2 column CSV files
*   Circos (http://circos.ca) tableviewer text file
*   Hosts information, formatted in a 3 column CSV output

## Installation

Install the Prenus gem:

```bash
git clone https://github.com/noraj/prenus.git && cd prenus

# to run without install
bundle install

# install globally
gem build prenus.gemspec
gem install prenus-*.gem
```

## Usage

* Download the .nessus files from Nessus you want to Prettify (make sure
    they're version 2 files, not version 1)
* Cd into the folder where the files are
* Run Prenus:
    * If installed globally
        * `prenus -t html -o output_folder ../my_export.nessus`
    * Run without install
        * `bundle exec ruby -Ilib -rprenus bin/prenus -t host -o /tmp/report.host ../my_export.nessus`

## Command Line Options

```
Usage: prenus <options> [INPUT]

Specific Options:
    -h, --help                       Display this screen
    -c, --config FILE                Load a YAML formatted config file
    -o, --ouput DIR/FILE             Defaults to '.'
    -t, --type TYPE                  Select: xls, html, glow, circos or host. Defaults to html
        --header-file FILE           Optional HTML FILE to be inserted into the top of the index.html file when using HTML output
    -s, --severity LEVEL             Defaults to 3 for High -> Critical. For large datasets 4 is saner
    -f, --filter FILTER              Only show these Nessus IDs. For multiple separate with commas 12345,23232,21212
    -d, --debug                      Displays stats and other debugging
    -v, --version                    Shows the version
```

### Config File

If you specify a config file (see the example prenus.yaml) file, this allows
you to override some host information, or skip vulns for particular hosts.

### Output

Output is handled in a few different ways, if you're running as type 'html',
then this option is a folder. If you don't specify a folder, then the HTML
files, js files, image files etc are built into the current folder. You might
not want this, so give it a folder name, such as 'tmp' to output the files to
the ./tmp sub-folder.

If the type is not 'html', then this is the file which will be used for
output, or, can be omitted to simply output to the screen (STDOUT)

### Type

Type specifies what output parser you want:

1.  html   - Outputs a number of HTML files
2.  xls    - Outputs a HTML TABLE text with an .xls extension, which can be
    opened by fairly modern versions of Excel
3.  glow   - Outputs a CSV formatted text which can be consumed by Afterglow
4.  circos - Outputs a tabular style text file which can be consumed by the
    Circos Tableviewer tool
5.  host   - Outputs a CSV formatted file with host information (just ip, os
    and hostname)

By default this is html.

### Severity

This sets the bottom severity which will be included for output. For example,
if severity is 0, then all vulnerabilities identified as informational, low,
medium, high and critical will be included. If severity is 3 then only high
and critical will be included.

By default this is 3.

### Filter

This option doesn't apply to the html output, but, for all other output types,
this allows you to output only explicitly listed Nessus Plugin IDs. For
example: 54343,34443,12345

### Debug

If flagged, then we'll output some raw data.

### Header File

If you want to add some optional branding to top of the html files (when using
HTML output type). Create a file with some HTML content, and then point this
option to the file. Voila. BRAAANDING

## Afterglow - what?

So, you're interested in creating some pretty Afterglow/Graphviz files to see
relationships between Nessus IDs and Hosts? Look no further!

Using the example colouring Afterglow properties file (prenus.properties) you
can execute this to graph critical vulns (as long as you have afterglow
working with all its dependencies, PLUS you have Graphviz installed and
working (# which neato))

This will only work if you're in Afterglow's src/perl/graph/ folder:

    prenus -t glow -s 4 /folder/where/nessus/files/are/*.nessus | ./afterglow -t -c /folder/where/prenus.properties | neato -v -Tpng -Gnormalize=true -Goutputorder=edgesfirst -o prenus.png

## Circos - huh?

What about those pretty awesome Circos graphs huh?

Well, getting GD and all the other Circos dependencies was a bit of a pain in
the butt on OS X 10.7, but after a bunch of googling and checking out the
following URLs, it seemed to work okay. (Might help, probably not:
https://gist.github.com/3214492) (I think I also had to update the #!s on top
of the .pl files :/)

You might also need to fiddle with the circos.conf file, but eventually I had
it working pretty solidly. I had circos installed in ~/circos/circos-0.62-1/
and the circos tools in ~/circos/circos-tools-0.16/

This will only work if you're in the Circos Tools tableviewer folder (in my
instance, ~/circos/circos-tools-0.16/tools/tableviewer/)

    prenus -t circos -s 4 /folder/where/nessus/files/are/*.nessus | bin/parse-table -conf samples/parse-table-01.conf | bin/make-conf -dir data
    ../../../circos-0.62-1/bin/circos -conf etc/circos.conf -outputfile prenus.png

This will dump the png into the img/ folder.

## Changes

*   Version 0.0.12 - The --header-file option now applies to all HTML files
*   Version 0.0.11 - A bunch of cosmetic changes. PLUS, a new optional command
    line flag to add HTML content to the top of the index.html file.
*   Version 0.0.10 - Added new pie graph to HTML output, and updated pie graph
    generater to allow for setting of colours
*   Version 0.0.9 - Added Nokogiri gem dep
*   Version 0.0.8 - Default HTML output directory - plus - can filter out
    severity issues for HTML. Updated gemspec, removed internal gem
*   Version 0.0.7 - Included push update for XLS output - and updated version
    statements
*   Version 0.0.6 - Updated the version in the prenus file
*   Version 0.0.5 - FUUUU Did it again. Botched the gem push #facepalm. This
    is identical to 0.0.4
*   Version 0.0.4 - Shifted my copy of ruby-nessus into my lib/gemcache folder
*   Version 0.0.3 - Botched the gem push - like a chump - this should be
    identical to 0.0.2
*   Version 0.0.2 - Updated input - handles duplicate hosts a bit nicer (but
    not much nicer)
*   Version 0.0.1 - initial release .. buggy to the max

