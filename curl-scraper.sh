#!/usr/bin/env bash
#download audience review data from rotten tomatoes.
#this one has hardcoded query string to the rest api
#for TRoS
#
#install jq before using this: https://stedolan.github.io/jq/
#

trap exit 6 SIGINT SIGTERM SIGHUP #just random number

HOST='https://www.rottentomatoes.com'
DIRECTION='next' #which way we paging
#input is:
#
#/napi/movie/8ef022ef-f88a-33c8-8f6e-ab87f5039eea/reviews/user?direction=next&endCursor=eyJyZWFsbV91c2VySWQiOiJSVF85Nzg0ODkzMDIiLCJlbXNJZCI6IjhlZjAyMmVmLWY4OGEtMzNjOC04ZjZlLWFiODdmNTAzOWVlYSIsImVtc0lkX2hhc1Jldmlld0lzVmlzaWJsZSI6IjhlZjAyMmVmLWY4OGEtMzNjOC04ZjZlLWFiODdmNTAzOWVlYV9UIiwiY3JlYXRlRGF0ZSI6IjIwMTktMTItMjlUMTA6MzE6MDIuMDUyWiJ9&startCursor= infinity war

DIRECTION='next' #which way we paging
while read line
do
	QUERY=$(echo "$line" | cut -d' ' -f1)
	TITLE=$(echo "$line" | cut -d' ' -f2-)
	OUTDIR=${TITLE// /-}
	endCursor="$(echo "$QUERY" | tr '&?' '\n' | grep 'endCursor')"
	endCursor="${endCursor#endCursor=}"
	
	startCursor="$(echo "$QUERY" | tr '&?' '\n' | grep 'startCursor')"
	startCursor="${startCursor#startCursor=}"
	PARAM_PAT='\?.\+$'
	ENDP=$(echo "$QUERY" | cut -d'?' -f1)
	mkdir --parents $OUTDIR || { errc=$?; echo "something wrong creating directory $PWD/OUTDIR"; exit $errc; }

	hasNext='true'
	set -C
	while [[ "$hasNext" = 'true' ]]
	do
		filename="${endCursor:0:250}.json" #using cursor node as output file name
		set -x
		curl --silent --show-error "${HOST}${ENDP}?direction=next&endCursor=${endCursor}&startCursor=${startCursor}" > $OUTDIR/$filename
		set +x
		startCursor=$(jq -r .pageInfo.startCursor $OUTDIR/$filename)
		endCursor=$(jq -r .pageInfo.endCursor $OUTDIR/$filename)
		hasNext=$(jq -r .pageInfo.hasNextPage $OUTDIR/$filename)
	done
done<urls &
