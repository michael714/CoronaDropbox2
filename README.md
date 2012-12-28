CoronaDropbox2
==============

Corona SDK sample code for Dropbox

This sample code is based off of the Corona SDK Twitter REST sample code.

I made some changes to oAuth.lua.  In order to make life easier, I decided to attack the Dropbox API with PLAINTEXT as the signature method.  Dropbox encourages this because it can be done with https.  Here's the Dropbox link:
https://www.dropbox.com/developers/blog/20

So, I changed oAuth.lua to use PLAINTEXT instead of HMAC1.  Also, since this requires https, I had to change rawGetRequest so that it uses network.request.  

I made many changes to the Twitter.lua file and renamed it Dropbox.lua.  The main gist of the changes include a bunch of buttons that allow the user to wait for the async network responses to all of the Dropbox API requests including:

request token

authorize

access token

and, finally, GET account info

In order for you to see the reponses on your device (and debugging print statements), you will need to open a terminal and use this command: 
adb logcat Corona:V *:S

This command allows logging from device while attached via USB cable.  At least, it works with a PC and an Android phone.  Hopefully this helps.  I will try to post updates here as they become available. 

I spent weeks getting this code to work.  If you found this to be helpful, please make a donation: 
<a href='http://www.pledgie.com/campaigns/18967'><img alt='Click here to lend your support to: Corona SDK Dropbox Sample Code and make a donation at www.pledgie.com !' src='http://www.pledgie.com/campaigns/18967.png?skin_name=chrome' border='0' /></a>
