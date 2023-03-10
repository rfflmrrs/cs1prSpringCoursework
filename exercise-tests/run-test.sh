#!/bin/bash

# This little script runs the tests defined in the directory test and compares
# the output of your program with the expected output.
#
# You do not need to temper with it.

if [[ "$1" == "" || "$2" == "" ]]; then
	echo "Synopsis: $0 <executable-to-test> <test-dir>"
	exit 1
fi

if [[ ${1:0:1} == "/" ]]; then
	p=$1
else
	p=./$1
fi

test="$2"

if [[ ! -e $p ]]; then
	echo "Cannot find the executable: $p"
	exit 1
fi

if [[ ! -e $test ]] ; then
	echo "Could not find the test directory!"
	exit 1
fi

if [[ $(ls $test|grep ".out$"|wc -l) == 0 ]] ; then
	echo "Could not find a test inside the test directory"
	exit 1
fi

summarks=0
totalmarks=0

for out in $test/*.out ; do
  test=${out%.out}
  base=$(basename $test)
  echo -n "Test $base "
	marks=${out%.out}.marks
	if [[ -e $marks ]]; then
		marks=$(cat $marks)
	else
		marks=1
	fi
	totalmarks=$(($totalmarks + $marks))

  in=$test.in
	param=$test.param
  if [[ -e $param ]]; then
    if [[ -e $in ]] ; then
		  cat $in | xargs $p < $param > tmp 2>&1
    else
      xargs $p < $param > tmp 2>&1
    fi
	else
    if [[ -e $in ]] ; then
      $p < $in > tmp 2>&1
    else
      $p > tmp 2>&1
    fi
	fi
	ERR=$?
	if [[ $ERR != 0 ]] ; then
          echo "ERR: $ERR returned by program did you use 'int main' as prototype and return 0 from main?"
        fi

  	diff -B -w tmp $out > /dev/null
		ERR=$?
		if [[ $ERR != 0 ]]; then
      echo "ERR: data doesn't match."
      if [[ -e $param ]]; then
        echo -n "Arguments: "
        cat $param | xargs echo
      fi
	    echo ">>> Got >>>>>>>>"
	    cat tmp
	    echo "<<<<<<<<<<<<<<<<"
			echo
	    echo ">>> Expected >>>"
	    cat $out
	    echo "<<<<<<<<<<<<<<<<"

      if [[ -e $test.explain ]]; then
        echo -n "Hint: "
        cat $test.explain
        echo
      fi
		fi
  if [[ $ERR == 0 ]]; then
    echo "OK"
		summarks=$(($summarks + $marks))
  fi
done

echo
echo "$summarks/$totalmarks marks"

if [[ -e tmp ]]; then
  rm tmp
fi
