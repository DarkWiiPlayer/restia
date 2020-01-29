#!/bin/sh

version=$(find restia-*-*.rockspec | head -1 | sed -e 's/^.\+\-\(.*\-.*\)\.rockspec$/\1/')

contributors=$(lua -e '
local function map(t,f) local r={}; for k,v in ipairs(t) do r[k]=f(v) end; return r; end
print(table.concat(map(require "contributors", function(c) return string.format("\\fB%s\\fR <%s>", c.name, c.email) end), ",\n"))
')

cat <<EOF
.TH restia 1 "" ""  "Restia web framework"

.SH NAME
.\" ####

\fBrestia\fR - commandline utility for the restia framework

.SH SYNOPSIS
.\" ########

\fBrestia\fR \fBnew\fR [\fIdirectory\fR]
.br
\fBrestia\fR \fBtest\fR [\fIlua\fR [\fIconfiguration\fR]]
.br
\fBrestia\fR \fBrun\fR [\fIconfiguration\fR]
.br
\fBrestia\fR \fBreload\fR [\fIconfiguration\fR]
.br
\fBrestia\fR \fBhelp\fR

.SH DESCRIPTION
.\" ###########

Commandline utility for the restia framework

.SH COMMANDS
.\" ########

\fBnew\fR [\fIdirectory\fR]
.br
Creates a new project in the directory \fIdirectory\fR
The default directory is \fBapplication\fR.

\fBtest\fR [\fIlua\fR [\fIconfiguration\fR]]
.br
Runs a list of tests on the web application in the current directory.

\fBrun\fR [\fIconfiguration\fR]
.br
Runs a restia application in the current directory.

\fBreload\fR [\fIconfiguration\fR]
.br
Reloads an already running restia application.

The default \fIconfiguration\fR for the three commands above is \fBopenresty.conf\fR

\fBhelp\fR
.br
Displays help for the different commands and exit.

.SH VERSION
.\" #######

\fBrestia\fR $version

.SH AUTHORS
.\" #######

$contributors

.SH SEE ALSO
.\" ########

\fBnginx\fR(1)
EOF
