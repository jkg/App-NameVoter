App::NameVoter
==============

This ironically terribly named tool will take some pairs of words and present them in batches for users to vote +1, -1 or neutral on. It's mostly a toy, although I think it might be interesting for naming a project I'm involved with...

`bin/getpairs` -- trivial script, takes a word list from `data/wordlist` and creates `data/pairs` (random-ish order)

`bin/app.pl` -- Perl Dancer application to display these pairs for voting

Any prettiness I inadvertently achieve is entirely due to Twitter Bootstrap
