contributors = require 'contributors'

for contrib in *contributors do
	contributors[contrib.email] = contrib

process = io.popen("git shortlog --summary --email")

emails = [ line\match("%b<>")\sub(2,-2) for line in process\lines() ]

for email in *emails do
	contributor = contributors[email]
	it "#{contributor.name} <#{email}> should agree to the license", ->
		assert.true contributor.license
