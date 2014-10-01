CRD Rare bird alert Twitter Bot
=================

Fetches recent rare bird sightings submitted to [eBird](http://www.ebird.org) 
in the Capital Regional District of Vancouver Island, British Columbia, using 
the [ropensci](http://ropensci.org/) R package 
[rebird](http://ropensci.org/tutorials/rebird_tutorial.html).

The sightings are then tweeted from the [CRD Rare Bird Bot](https://twitter.com/crd_rare_bird) twitter account using the R package 
[twitteR](https://github.com/geoffjentry/twitteR).

This is automatically run three times a day, which I figured out following the 
tutorial [here](http://ricardianambivalence.com/2013/03/13/scheduling-tasks-with-macs-launchd-moving-on-from-cron/).
