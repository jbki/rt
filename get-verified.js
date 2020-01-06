#!/usr/bin/env node

let fs = require('fs');

function time_sort(a, b) {
    return new Date(a.createDate).getTime() - new Date(b.createDate).getTime();
}
const results_json = JSON.parse(fs.readFileSync(process.argv[2])).sort(time_sort) //actually an array of jsons
const start = 200
const increment = 200
const max = results_json.length

for(let end = start; end < max; end += increment) { 
	let rotten = 0
	let fresh = 0
	let rotten_array = []
	let fresh_array = []
	const j = results_json.slice(0,end)
	for(let i in j) {
		if (j[i].isVerified === true) {
			if(j[i].score >= 3.5) {
				fresh_array.push(j[i])
				fresh++
			}
			else {
				rotten_array.push(j[i])
				rotten++
			}
		}
	}

	const rotten_sample_count = rotten_array.length
	const fresh_sample_count = fresh_array.length
	const total_count = 0 + rotten_sample_count + fresh_sample_count
	if(fresh !== fresh_sample_count) {
		console.err("Something wrong");
	}	
	else {
		console.log("| " + total_count + " | " + (fresh_sample_count*100.0)/total_count + " |")
	}

}
