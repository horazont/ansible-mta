#!/bin/bash
/usr/bin/spamc | /usr/bin/sendmail "$@"
exit $?
