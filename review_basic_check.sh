#!/bin/sh
# The file is used to do TS2.0 case review automatically
if [ -z $1 ] ; then
  echo "** feature file path should be provided like '/home/cara/dev/errata-rails/features' **"
  exit
fi
echo "== checking dir =="
num=$(find $1 -name "*.feature" | wc -l)
if [ ${num} -lt 1 ] ; then
    echo "Error: No features files are found, please make sure you are on the right dir"
    exit
else
    echo "PASS: checking dir"
fi

echo "== Checking the useless comments with 'puts' and 'binding' words =="
puts_num=$(grep -r -i "puts " ${1}/step_definitions | wc -l)
if [ ${puts_num} -ge 1 ] ; then
    echo "Info: There are some 'puts' lines. Please check them whether we need to remove"
    grep -r -i "puts " ${1}/step_definitions
else
    echo "PASS: No useless 'puts' line found"
fi
binding_num=$(grep -r -i 'binding.pry' ${1}/step_definitions | wc -l)
if [ ${binding_num} -ge 1 ] ; then
    echo "Info: There are some 'binding.pry' lines. Please check them whether can be moved"
    grep -r -i 'binding.pry' ${1}/step_definitions
else
    echo "PASS: No useless 'binding.pry' line found"
fi

echo "== Reporting the other comments line =="
comment_line=$(grep -r -i "#" ${1}/step_definitions | grep -v "#{" | wc -l | grep -v "#binding.pry" | grep -v "#puts")
if [ ${comment_line} -ge 1 ]; then
    echo "Info: There are some comments in your files, please make sure they are meaningful"
    grep -r -i "#" ${1}/step_definitions | grep -v "#{" | grep -v "#binding.pry" | grep -v "#puts" | grep -v '"#' | grep -v "'#"
else
    echo "PASS: No useless comments found"
fi

echo "== Checking the elements are asserted =="
no_assert_num=$(grep -r -i "page.has_" ${1}/step_definitions | grep -v "assert" | wc -l)
if [ ${no_assert_num} -ge 1 ] ; then
    echo "Info: There are some 'page.has_' without 'assert', please confirm you do not miss your assert"
    grep -r -i "page.has_" ${1}/step_definitions | grep -v "assert"
else
    echo "PASS: no assert is missing"
fi

echo "== Checking no useless methods, useless methods will be listed below: =="
never_called_function_list=[]
reported_function_num=0
grep -r  "def " $1 | cut -d ":"  -f 2- | cut -d "(" -f 1 | sed "s/def //g" > /tmp/def.list
while read line
do
    num=$(grep -r "$line" $1 | wc -l)
    if [ ${num} -le 1 ] ; then
        never_called_function_list[${reported_function_num}]=${line}
        reported_function_num=$((${reported_function_num}+1))
    fi
done < /tmp/def.list
if [[ ${reported_function_num} -eq 1 ]] ; then
    echo "PASS: No useless functions found"
else
    echo "Info: Please whether we need to remove the following methods. It never been called."
    for function in  ${never_called_function_list[@]}
    do
        if [[ ${function} != "initialize" ]];then
            echo ${function}
        fi
    done
fi

echo "== Updating your files for useless blank lines and end points =="
remove_blank_lines_and_end_points()
{
    vim -c ':%s/\(\n\n\)\n\+/\1/' -c ":wq" ${file}
    vim -c '::%s/ \+$//' -c ":wq" ${file}
}
for file in `ls ${1}/*.feature`
do
    remove_blank_lines_and_end_points ${file}
done

for file in `ls ${1}/step_definitions/*.rb`
do
    remove_blank_lines_and_end_points ${file}
done

for file in `ls ${1}/support/*.rb`
do
    remove_blank_lines_and_end_points ${file}
done
echo "== Done for all automated checking =="
