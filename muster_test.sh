#!/bin/bash

# Script to run MUSTER training set
# Usage:
# ./muster_test.sh [pairs of proteins to compare] [protein directory] [expected scores]
# - the pair of proteins has the format: [protein.pdb file 1] [protein.pdb file 2]
# - the protein directory argument must end with a /
# - the expected score document assumes that each two lines is associated with
#   a pair of proteins

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Argument missing"
    echo "Usage:"
    echo "./muster_test.sh [pairs of proteins to compare] [protein directory] [expected scores]"
    echo "- the pair of proteins has the format: [protein.pdb file 1] [protein.pdb file 2]"
    echo "- the protein directory argument must end with a /"
    echo "- the expected score document assumes that each two lines is associated with"
    echo "  a pair of proteins"
    exit
fi

if [ ! -f TMalign ]; then
    echo "Please compile TMalign first"
    exit
fi

TOLERANCE=0.01

echo "Please be aware: bash will throw a "integer expression expected" error"
echo "sometimes because the output of the comparison is, for some unknown reason"
echo "a floating point number. This is being investigated. The differences,"
echo "however, should still remain very small at near 0.0001 to 0.00001"

while read -r protein_pairs && read -r TMScore1 <&3 && read -r TMScore2 <&3; do
    
    # Get the pair of proteins and their paths
    PAIR=($protein_pairs)
    PROTEIN_1_PATH="$2${PAIR[0]}"
    PROTEIN_2_PATH="$2${PAIR[1]}"

    # Get expected and calculated scores
    EXPECTED_SCORE_1=$(echo $TMScore1 | grep -o -E "0+\.[0-9]+")
    EXPECTED_SCORE_2=$(echo $TMScore2 | grep -o -E "0+\.[0-9]+")
    CALCULATED_SCORES=$(./TMalign "$PROTEIN_1_PATH" "$PROTEIN_2_PATH" | grep -E "^TM" | grep -o -E "0+\.[0-9]+") 
    readarray -t CALCULATED_SCORE_ARR <<< "$CALCULATED_SCORES"
    CALCULATED_SCORE_1=${CALCULATED_SCORE_ARR[0]}
    CALCULATED_SCORE_2=${CALCULATED_SCORE_ARR[1]}

    # Compare the expected and calculated
    first_diff=$(echo "$CALCULATED_SCORE_1 - $EXPECTED_SCORE_1" | bc -l | awk ' { if($1>=0) { print $1} else {print $1*-1 }}')
    second_diff=$(echo "$CALCULATED_SCORE_2 - $EXPECTED_SCORE_2" | bc -l | awk ' { if($1>=0) { print $1} else {print $1*-1 }}')
    first_comparison=$(echo "$first_diff > $TOLERANCE" | bc -l)
    second_comparison=$(echo "$second_diff > $TOLERANCE" | bc -l)

    # Only print if a difference is found
    # Warning: sometimes the comparison returns floating point numbers from the
    #  comparison. Not sure why but the difference should be very small.
    if [ "$first_comparison" -ne "0" ] || [ "$second_comparison" -ne "0" ]; then
        echo "TMScore mismatch found"
        echo "Protein 1 - ${PAIR[0]}, Protein 2 - ${PAIR[1]}"
        echo "Expected: $EXPECTED_SCORE_1 $EXPECTED_SCORE_2"
        echo "Calculated: $CALCULATED_SCORES_1 $CALCULATED_SCORES_2"
        echo ""
    fi

done < "$1" 3<"$3"
