#!/bin/bash
pip install codespell &> tmp.log

function check_coding() {
    list_file="$1"
    ABS_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"/.. ; pwd -P )
    UNCRUSTIFY_PATH=$ABS_PATH/tools/uncrustify/uncrustify_0_79_0_linux/uncrustify
    CFG_PATH=$ABS_PATH/tools/uncrustify/uncrustify.cfg
    chmod +x $UNCRUSTIFY_PATH

    $UNCRUSTIFY_PATH -c $CFG_PATH -l C --replace -F $list_file &> debug.log
    git diff --name-only > uncrustify_formatted_list.txt

    # Failing build, we will send logs and the formatted files to output
    if [ -s uncrustify_formatted_list.txt ]; then
        mkdir uncrustify_formatted_files
        git diff > uncrustify_formatted_files/code-fix.patch
        
        lines=$(cat uncrustify_formatted_list.txt)
        for line in $lines
        do
            git --no-pager diff $line > $line.log
            echo "$line.log" >> uncrustify_log_list.txt
        done
        xargs -a uncrustify_formatted_list.txt cp --parents -n -t uncrustify_formatted_files/ &>> debug.log
        xargs -a uncrustify_log_list.txt cp --parents -n -t uncrustify_formatted_files/ &>> debug.log
        jar -cvf uncrustify_formatted_files.zip uncrustify_formatted_files/ &>> debug.log
        
    fi
}

# Generate report
printf '''<!DOCTYPE html>
<html>
<head><style>
body {
font-family: Helvetica, sans-serif;
font-size: 0.9em;
color: black;
padding: 6px;
}
h2 {
font-size: 1.2em;
}
h3 {
font-size: 1.1em;
}
</style></head>
<body>
<h1>Coding Style Report</h1>
<p><a href="https://github.com/uncrustify/uncrustify"> The Uncrustify</a> is used to check the coding standard.</p>
<p>The developer should ensure that their code follows all of the <a href="https://github.com/SiliconLabs/training_examples_staging/wiki/coding-standard"> 32-bit coding standard.
</a></p>
'''
# Get the source files in the changed projects
file="$1"
xargs -a "$file" -I{} find "{}" -type f \( -name "*.c" -o -name "*.h" -o -name "*.cpp" \) > list_files.txt

# Ignore check coding style if PR only have _config.h files
check=0
while read line; do
  if { [[ "$line" == *".c"* ]] || [[ "$line" == *".cpp"* ]]; } && [[ "$line" != *"/config/"* ]]; then
    (( check += 1 ))
  fi
done < list_files.txt
if [ $check -gt 0 ]; then
    check=0
else
    printf '<h2>Only config .h files. Ignored check coding style.</h2>'
    exit 0
fi

# Skip check _config.h files
grep -v "/config/\\|application_ui" list_files.txt > uncrustify_list.txt
printf '<h2>Coding Convention Information</h2>\n'

if ! [ -s uncrustify_list.txt ]; then
    printf '<ul><li><p><span style="color:red; !important">Some tests failed</span>. No source files found.</p></li>\n</ul>\n</body></html>\n'
    # exit 1; 
fi

# Found any source files here. We run uncrustify to check coding style
check_coding uncrustify_list.txt

if ! [ -s uncrustify_formatted_list.txt ]; then
    printf '<ul><li><p style="color:green; !important">All tests passed</p></li>\n</ul>\n'
else
    printf '<ul><li><p><span style="color:red; !important">Some tests failed.</span> See <strong>Check logs</strong> for details.</p></li></ul>\n'
fi

# Print code spell
# Dont use -w because, sometime tool not correct. If use -w, it will auto update wrong code.
# Code spell check
git_diff=$WORKSPACE/projects/git_diff.txt
while IFS= read -r line; do
    codespell $line --config $ABS_PATH/tools/codespell/.codespellrc &>> result_codespell.log 2>/dev/null
    let status+=$?
done < $git_diff
    
printf '<h2>Code Spell Check</h2>\n'
echo "dir: $(pwd)"
if [ $status -gt 0 ]; then
    printf '<ul><li><p style="color:red; !important">Result: failed</p></li>\n</ul>'
    echo "<p><b>**NOTE**</b> The tool may not detect abbreviation words correctly.</p>"
    echo "If you notice any incorrect detections, please contact me so I can add those words to the ignore list: silabs-CongD"
    echo "<p>Here is the list of failed files:</p>"
else
    printf '<ul><li><p style="color:green; !important">Result: success</p></li>\n</ul>\n'
fi
echo "<pre>"
cat result_codespell.log
echo "</pre>"

printf '<h3>Source files are found:</h3>\n<ul>\n'
lines=$(cat uncrustify_list.txt)
for line in $lines
do
    printf "<li>$line</li>\n"
done
printf '</ul>\n'

if ! [ -s uncrustify_formatted_list.txt ]; then
    printf '</body></html>\n'
    exit 0; 
fi

printf '<h3>Source files are failed:</h3>\n<ul>\n<span style="color:red; !important">\n'
lines=$(cat uncrustify_formatted_list.txt)
for line in $lines
do
    printf "<li>$line</li>\n"
done
printf '</span></ul>\n'

# Find all .log files and print their contents in HTML format
find "./uncrustify_formatted_files" -type f -name "*.log" | while read -r file; do
    echo "<h4>Failed of $file</h4>"
    echo "<pre>"
    cat "$file"
    echo "</pre>"
done

printf '</body></html>\n'
